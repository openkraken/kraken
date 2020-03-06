#include "time_point.h"
#include "macros.h"

#if defined(IS_MACOSX) || defined(IS_IOS)
#include <mach/kern_return.h>
#include <mach/mach_time.h>
#elif defined(IS_WIN)
#include <windows.h>
#else
#include <time.h>
#endif // defined(IS_MACOSX) || defined(IS_IOS)

#include "logging.h"

namespace foundation {

// Mac OS X/iOS don't have a (useful) |clock_gettime()|.
// Note: Chromium's |base::TimeTicks::Now()| uses boot time (obtained via
// |sysctl()| with |CTL_KERN|/|KERN_BOOTTIME|). For our current purposes,
// monotonic time (which pauses during sleeps) is sufficient. TODO(vtl): If/when
// we use this for other purposes, maybe we should use boot time (maybe also on
// POSIX).
#if defined(IS_MACOSX) || defined(IS_IOS)

mach_timebase_info_data_t GetMachTimebaseInfo() {
  mach_timebase_info_data_t timebase_info = {};
  mach_timebase_info(&timebase_info);
  return timebase_info;
}

// static
TimePoint TimePoint::Now() {
  static mach_timebase_info_data_t timebase_info = GetMachTimebaseInfo();
  return TimePoint(mach_absolute_time() * timebase_info.numer / timebase_info.denom);
}

#elif defined(IS_WIN)

TimePoint TimePoint::Now() {
  uint64_t freq = 0;
  uint64_t count = 0;
  QueryPerformanceFrequency((LARGE_INTEGER *)&freq);
  QueryPerformanceCounter((LARGE_INTEGER *)&count);
  return TimePoint((count * 1000000000) / freq);
}

#else

// static
TimePoint TimePoint::Now() {
  struct timespec ts;
  int res = clock_gettime(CLOCK_MONOTONIC, &ts);
  (void)res;
  return TimePoint::FromEpochDelta(TimeDelta::FromTimespec(ts));
}

#endif // defined(IS_MACOSX) || defined(IS_IOS)

} // namespace foundation
