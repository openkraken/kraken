#ifndef KRAKEN_MACROS_H_
#define KRAKEN_MACROS_H_


//////////
#if defined(ANDROID)
#define IS_ANDROID 1
#elif defined(__APPLE__)
// only include TargetConditions after testing ANDROID as some android builds
// on mac don't have this header available and it's not needed unless the target
// is really mac/ios.
#include <TargetConditionals.h>
#define IS_MACOSX 1
#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#define IS_IOS 1
#endif  // defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#elif defined(__linux__)
#define IS_LINUX 1
// include a system header to pull in features.h for glibc/uclibc macros.
#include <unistd.h>
#if defined(__GLIBC__) && !defined(__UCLIBC__)
// we really are using glibc, not uClibc pretending to be glibc
#define LIBC_GLIBC 1
#endif
#elif defined(_WIN32)
#define IS_WIN 1
#elif defined(__FreeBSD__)
#define IS_FREEBSD 1
#elif defined(__OpenBSD__)
#define IS_OPENBSD 1
#elif defined(__sun)
#define IS_SOLARIS 1
#elif defined(__QNXNTO__)
#define IS_QNX 1
#else
#error Please add support for your platform in build_config.h
#endif

/////////////////

#define KRAKEN_DISALLOW_COPY(TypeName) TypeName(const TypeName&) = delete

#define KRAKEN_DISALLOW_ASSIGN(TypeName) \
  TypeName& operator=(const TypeName&) = delete

#define KRAKEN_DISALLOW_MOVE(TypeName) \
  TypeName(TypeName&&) = delete;    \
  TypeName& operator=(TypeName&&) = delete

#define KRAKEN_DISALLOW_COPY_AND_ASSIGN(TypeName) \
  TypeName(const TypeName&) = delete;          \
  TypeName& operator=(const TypeName&) = delete

#define KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName) \
  TypeName(const TypeName&) = delete;               \
  TypeName(TypeName&&) = delete;                    \
  TypeName& operator=(const TypeName&) = delete;    \
  TypeName& operator=(TypeName&&) = delete

#define KRAKEN_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName) \
  TypeName() = delete;                               \
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

#endif  // KRAKEN_MACROS_H_
