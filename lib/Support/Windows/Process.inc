//===- Win32/Process.cpp - Win32 Process Implementation ------- -*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file provides the Win32 specific implementation of the Process class.
//
//===----------------------------------------------------------------------===//
#include "llvm/ADT/Hashing.h"
#include "llvm/Support/Allocator.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/WindowsError.h"
#include <malloc.h>

// The Windows.h header must be after LLVM and standard headers.
#include "WindowsSupport.h"
#include <direct.h>
#include <io.h>
#include <psapi.h>
#include <shellapi.h>

#ifdef __MINGW32__
 #if (HAVE_LIBPSAPI != 1)
  #error "libpsapi.a should be present"
 #endif
 #if (HAVE_LIBSHELL32 != 1)
  #error "libshell32.a should be present"
 #endif
#else
 #pragma comment(lib, "psapi.lib")
 #pragma comment(lib, "shell32.lib")
#endif

//===----------------------------------------------------------------------===//
//=== WARNING: Implementation here must contain only Win32 specific code
//===          and must not be UNIX code
//===----------------------------------------------------------------------===//

#ifdef __MINGW32__
// This ban should be lifted when MinGW 1.0+ has defined this value.
#define _HEAPOK(-2)
#endif
using namespace llvm;
using namespace sys;

static TimeValue getTimeValueFromFILETIME(FILETIME Time)
{
	ULARGE_INTEGER TimeInteger;
	TimeInteger.LowPart = Time.dwLowDateTime;
	TimeInteger.HighPart = Time.dwHighDateTime;
	// FILETIME's are # of 100 nanosecond ticks (1/10th of a microsecond)
	return TimeValue(		static_cast<TimeValue::SecondsType > (TimeInteger.QuadPart / 10000000),
		static_cast<TimeValue::NanoSecondsType > (			(TimeInteger.QuadPart % 10000000) *100));
}

// This function retrieves the page size using GetNativeSystemInfo() and is
// present solely so it can be called once to initialize the self_process member
// below.
static unsigned computePageSize()
{
	// GetNativeSystemInfo() provides the physical page size which may differ
	// from GetSystemInfo() in 32-bit applications running under WOW64.
	SYSTEM_INFO info;
	GetNativeSystemInfo(&info);
	// FIXME: FileOffset in MapViewOfFile() should be aligned to not dwPageSize,
	// but dwAllocationGranularity.
	return static_cast<unsigned> (info.dwPageSize);
}

unsigned Process::getPageSize()
{
	static unsigned Ret = computePageSize();
	return Ret;
}

size_t
Process::GetMallocUsage()
{
	_HEAPINFO hinfo;
	hinfo._pentry = NULL;
	size_t size = 0;
	while (_heapwalk(&hinfo) == _HEAPOK)
		size += hinfo._size;
	return size;
}

void Process::GetTimeUsage(TimeValue &elapsed, TimeValue &user_time,
	TimeValue &sys_time)
{
	elapsed = TimeValue::now();
	FILETIME ProcCreate, ProcExit, KernelTime, UserTime;
	if (GetProcessTimes(GetCurrentProcess(), &ProcCreate, &ProcExit, &KernelTime, &UserTime) == 0)
		return;
	user_time = getTimeValueFromFILETIME(UserTime);
	sys_time = getTimeValueFromFILETIME(KernelTime);
}

// Some LLVM programs such as bugpoint produce core files as a normal part of
// their operation. To prevent the disk from filling up, this configuration
// item does what's necessary to prevent their generation.
void Process::PreventCoreFiles()
{
	// Windows does have the concept of core files, called minidumps.  However,
	// disabling minidumps for a particular application extends past the lifetime
	// of that application, which is the incorrect behavior for this API.
	// Additionally, the APIs require elevated privileges to disable and re-
	// enable minidumps, which makes this untenable. For more information, see
	// WerAddExcludedApplication and WerRemoveExcludedApplication (Vista and
	// later).
	//
	// Windows also has modal pop-up message boxes.  As this method is used by
	// bugpoint, preventing these pop-ups is additionally important.
	SetErrorMode(SEM_FAILCRITICALERRORS |
		SEM_NOGPFAULTERRORBOX |
		SEM_NOOPENFILEERRORBOX);
}

/// Returns the environment variable \arg Name's value as a string encoded in
/// UTF-8. \arg Name is assumed to be in UTF-8 encoding.
Optional<std::string > Process::GetEnv(StringRef Name)
{
	// Convert the argument to UTF-16 to pass it to _wgetenv().
	SmallVector<wchar_t, 128> NameUTF16;
	if (windows::UTF8ToUTF16(Name, NameUTF16))
		return None;
	// Environment variable can be encoded in non-UTF8 encoding, and there's no
	// way to know what the encoding is. The only reliable way to look up
	// multibyte environment variable is to use GetEnvironmentVariableW().
	SmallVector<wchar_t, MAX_PATH> Buf;
	size_t Size = MAX_PATH;
	do {
		Buf.reserve(Size);
		Size =
			GetEnvironmentVariableW(NameUTF16.data(), Buf.data(), Buf.capacity());
		if (Size == 0)
			return None;
		// Try again with larger buffer.
	} while (Size > Buf.capacity());
	Buf.set_size(Size);
	// Convert the result from UTF-16 to UTF-8.
	SmallVector<char, MAX_PATH> Res;
	if (windows::UTF16ToUTF8(Buf.data(), Size, Res))
		return None;
	return std::string(Res.data());
}

static std::error_code windows_error(DWORD E)
{
	return mapWindowsError(E);
}

static void AllocateAndPush(const SmallVectorImpl<char> &S,
	SmallVectorImpl<const char*> &Vector,
		SpecificBumpPtrAllocator<char> &Allocator)
{
	char *Buffer = Allocator.Allocate(S.size() + 1);::memcpy(Buffer, S.data(), S.size());
	Buffer[S.size()] = '\0';
	Vector.push_back(Buffer);
}

/// Convert Arg from UTF-16 to UTF-8 and push it onto Args.
static std::error_code
ConvertAndPushArg(const wchar_t *Arg, SmallVectorImpl<const char*> &Args,
		SpecificBumpPtrAllocator<char> &Allocator)
{
	SmallVector<char, MAX_PATH> ArgString;
	if (std::error_code ec = windows::UTF16ToUTF8(Arg, wcslen(Arg), ArgString))
		return ec;
	AllocateAndPush(ArgString, Args, Allocator);
	return std::error_code();
}

/// \brief Perform wildcard expansion of Arg, or just push it into Args if it
/// doesn't have wildcards or doesn't match any files.
static std::error_code
WildcardExpand(const wchar_t *Arg, SmallVectorImpl<const char*> &Args,
		SpecificBumpPtrAllocator<char> &Allocator)
{
	if (!wcspbrk(Arg, L "*?"))
	{
		// Arg does not contain any wildcard characters. This is the common case.
		return ConvertAndPushArg(Arg, Args, Allocator);
	}

	if (wcscmp(Arg, L "/?") == 0 || wcscmp(Arg, L "-?") == 0)
	{
		// Don't wildcard expand /?. Always treat it as an option.
		return ConvertAndPushArg(Arg, Args, Allocator);
	}

	// Extract any directory part of the argument.
	SmallVector<char, MAX_PATH> Dir;
	if (std::error_code ec = windows::UTF16ToUTF8(Arg, wcslen(Arg), Dir))
		return ec;
	sys::path::remove_filename(Dir);
	const int DirSize = Dir.size();
	// Search for matching files.
	WIN32_FIND_DATAW FileData;
	HANDLE FindHandle = FindFirstFileW(Arg, &FileData);
	if (FindHandle == INVALID_HANDLE_VALUE)
	{
		return ConvertAndPushArg(Arg, Args, Allocator);
	}

	std::error_code ec;
	do {
		SmallVector<char, MAX_PATH> FileName;
		ec = windows::UTF16ToUTF8(FileData.cFileName, wcslen(FileData.cFileName),
			FileName);
		if (ec)
			break;
		// Push the filename onto Dir, and remove it afterwards.
		llvm::sys::path::append(Dir, StringRef(FileName.data(), FileName.size()));
		AllocateAndPush(Dir, Args, Allocator);
		Dir.resize(DirSize);
	} while (FindNextFileW(FindHandle, &FileData));
	FindClose(FindHandle);
	return ec;
}

std::error_code
Process::GetArgumentVector(SmallVectorImpl<const char*> &Args,
		ArrayRef<const char*>, 			SpecificBumpPtrAllocator<char> &ArgAllocator)
{
	int ArgCount;
	wchar_t **UnicodeCommandLine =
		CommandLineToArgvW(GetCommandLineW(), &ArgCount);
	if (!UnicodeCommandLine)
		return windows_error(::GetLastError());
	Args.reserve(ArgCount);
	std::error_code ec;
	for (int i = 0; i < ArgCount; ++i)
	{
		ec = WildcardExpand(UnicodeCommandLine[i], Args, ArgAllocator);
		if (ec)
			break;
	}

	LocalFree(UnicodeCommandLine);
	return ec;
}

std::error_code Process::FixupStandardFileDescriptors()
{
	return std::error_code();
}

std::error_code Process::SafelyCloseFileDescriptor(int FD)
{
	if (::close(FD) < 0)
		return std::error_code(errno, std::generic_category());
	return std::error_code();
}

bool Process::StandardInIsUserInput()
{
	return FileDescriptorIsDisplayed(0);
}

bool Process::StandardOutIsDisplayed()
{
	return FileDescriptorIsDisplayed(1);
}

bool Process::StandardErrIsDisplayed()
{
	return FileDescriptorIsDisplayed(2);
}

bool Process::FileDescriptorIsDisplayed(int fd)
{
	DWORD Mode;	// Unused
	return (GetConsoleMode((HANDLE) _get_osfhandle(fd), &Mode) != 0);
}

unsigned Process::StandardOutColumns()
{
	unsigned Columns = 0;
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi))
		Columns = csbi.dwSize.X;
	return Columns;
}

unsigned Process::StandardErrColumns()
{
	unsigned Columns = 0;
	CONSOLE_SCREEN_BUFFER_INFO csbi;
	if (GetConsoleScreenBufferInfo(GetStdHandle(STD_ERROR_HANDLE), &csbi))
		Columns = csbi.dwSize.X;
	return Columns;
}

// The terminal always has colors.
bool Process::FileDescriptorHasColors(int fd)
{
	return FileDescriptorIsDisplayed(fd);
}

bool Process::StandardOutHasColors()
{
	return FileDescriptorHasColors(1);
}

bool Process::StandardErrHasColors()
{
	return FileDescriptorHasColors(2);
}

static bool UseANSI = false;
void Process::UseANSIEscapeCodes(bool enable)
{
	UseANSI = enable;
}

namespace
{
	class DefaultColors
	{
		private:
			WORD defaultColor;
		public:
			DefaultColors(): defaultColor(GetCurrentColor()) {}

		static unsigned GetCurrentColor()
		{
			CONSOLE_SCREEN_BUFFER_INFO csbi;
			if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &csbi))
				return csbi.wAttributes;
			return 0;
		}

		WORD operator()() const
		{
			return defaultColor;
		}
	};

	DefaultColors defaultColors;
	WORD fg_color(WORD color)
	{
		return color &(FOREGROUND_BLUE | FOREGROUND_GREEN |
			FOREGROUND_INTENSITY | FOREGROUND_RED);
	}

	WORD bg_color(WORD color)
	{
		return color &(BACKGROUND_BLUE | BACKGROUND_GREEN |
			BACKGROUND_INTENSITY | BACKGROUND_RED);
	}
}

bool Process::ColorNeedsFlush()
{
	return !UseANSI;
}

const char *Process::OutputBold(bool bg)
{
	if (UseANSI) return "\033[1m";
	WORD colors = DefaultColors::GetCurrentColor();
	if (bg)
		colors |= BACKGROUND_INTENSITY;
	else
		colors |= FOREGROUND_INTENSITY;
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), colors);
	return 0;
}

const char *Process::OutputColor(char code, bool bold, bool bg)
{
	if (UseANSI) return colorcodes[bg ? 1 : 0][bold ? 1 : 0][code & 7];
	WORD current = DefaultColors::GetCurrentColor();
	WORD colors;
	if (bg)
	{
		colors = ((code & 1) ? BACKGROUND_RED : 0) |
			((code & 2) ? BACKGROUND_GREEN : 0) |
			((code & 4) ? BACKGROUND_BLUE : 0);
		if (bold)
			colors |= BACKGROUND_INTENSITY;
		colors |= fg_color(current);
	}
	else
	{
		colors = ((code & 1) ? FOREGROUND_RED : 0) |
			((code & 2) ? FOREGROUND_GREEN : 0) |
			((code & 4) ? FOREGROUND_BLUE : 0);
		if (bold)
			colors |= FOREGROUND_INTENSITY;
		colors |= bg_color(current);
	}

	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), colors);
	return 0;
}

static WORD GetConsoleTextAttribute(HANDLE hConsoleOutput)
{
	CONSOLE_SCREEN_BUFFER_INFO info;
	GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info);
	return info.wAttributes;
}

const char *Process::OutputReverse()
{
	if (UseANSI) return "\033[7m";
	const WORD attributes = GetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE));
	const WORD foreground_mask = FOREGROUND_BLUE | FOREGROUND_GREEN |
		FOREGROUND_RED | FOREGROUND_INTENSITY;
	const WORD background_mask = BACKGROUND_BLUE | BACKGROUND_GREEN |
		BACKGROUND_RED | BACKGROUND_INTENSITY;
	const WORD color_mask = foreground_mask | background_mask;
	WORD new_attributes =
		((attributes & FOREGROUND_BLUE) ? BACKGROUND_BLUE : 0) |
		((attributes & FOREGROUND_GREEN) ? BACKGROUND_GREEN : 0) |
		((attributes & FOREGROUND_RED) ? BACKGROUND_RED : 0) |
		((attributes & FOREGROUND_INTENSITY) ? BACKGROUND_INTENSITY : 0) |
		((attributes & BACKGROUND_BLUE) ? FOREGROUND_BLUE : 0) |
		((attributes & BACKGROUND_GREEN) ? FOREGROUND_GREEN : 0) |
		((attributes & BACKGROUND_RED) ? FOREGROUND_RED : 0) |
		((attributes & BACKGROUND_INTENSITY) ? FOREGROUND_INTENSITY : 0) |
		0;
	new_attributes = (attributes &~color_mask) | (new_attributes & color_mask);
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), new_attributes);
	return 0;
}

const char *Process::ResetColor()
{
	if (UseANSI) return "\033[0m";
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), defaultColors());
	return 0;
}

static unsigned GetRandomNumberSeed()
{
	// Generate a random number seed from the millisecond-resolution Windows
	// system clock and the current process id.
	FILETIME Time;
	GetSystemTimeAsFileTime(&Time);
	DWORD Pid = GetCurrentProcessId();
	return hash_combine(Time.dwHighDateTime, Time.dwLowDateTime, Pid);
}

static unsigned GetPseudoRandomNumber()
{
	// Arrange to call srand once when this function is first used, and
	// otherwise (if GetRandomNumber always succeeds in using
	// CryptGenRandom) don't bother at all.
	static int x = (static_cast<void> (::srand(GetRandomNumberSeed())), 0);
	(void) x;
	return ::rand();
}

unsigned Process::GetRandomNumber()
{
	// Try to use CryptGenRandom.
	HCRYPTPROV HCPC;
	if (::CryptAcquireContextW(&HCPC, NULL, NULL, PROV_RSA_FULL,
			CRYPT_VERIFYCONTEXT))
	{
		ScopedCryptContext CryptoProvider(HCPC);
		unsigned Ret;
		if (::CryptGenRandom(CryptoProvider, sizeof(Ret),
				reinterpret_cast<BYTE*> (&Ret)))
			return Ret;
	}

	// If that fails, fall back to pseudo-random numbers.
	return GetPseudoRandomNumber();
}
