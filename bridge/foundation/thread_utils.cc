#include "thread_utils.h"
#include "logging.h"
#include "macros.h"

#if defined(IS_WIN)
#include <windows.h>
#else
#include <pthread.h>
#endif

namespace kraken {
namespace foundation {
void SetCurrentThreadName(const std::string &name) {
  if (name == "") {
    return;
  }
#if IS_MACOSX
  pthread_setname_np(name.c_str());
#elif IS_LINUX || IS_ANDROID
  pthread_setname_np(pthread_self(), name.c_str());
#elif IS_WIN
  THREADNAME_INFO info;
  info.dwType = 0x1000;
  info.szName = name.c_str();
  info.dwThreadID = GetCurrentThreadId();
  info.dwFlags = 0;
  __try {
    RaiseException(kVCThreadNameException, 0, sizeof(info) / sizeof(DWORD),
                   reinterpret_cast<DWORD_PTR *>(&info));
  } __except (EXCEPTION_CONTINUE_EXECUTION) {
  }
#else
  KRAKEN_LOG(INFO) << "Could not set the thread name to '" << name
                   << "' on this platform.";
#endif
}
} // namespace foundation
} // namespace kraken
