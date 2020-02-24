/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include <cassert>
#include <js_context.h>

namespace kraken {
namespace binding {

using namespace alibaba::jsa;
#if defined(_WIN32)
#define PLATFORM "windows" // Windows
#elif defined(_WIN64)
#define PLATFORM "windows" // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
#define PLATFORM "windows" // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
#define PLATFORM "android" // Android (implies Linux, so it must come first)
#elif defined(__linux__)
#define PLATFORM                                                               \
  "linux" // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__APPLE__) && defined(__MACH__) // Apple OSX and iOS (Darwin)
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
#define PLATFORM "ios" // Apple iOS Simulator
#elif TARGET_OS_IPHONE == 1
#define PLATFORM "ios" // Apple iOS
#elif TARGET_OS_MAC == 1
#define PLATFORM "macos" // Apple macOS
#endif
#else
#define PLATFORM "unknown"
#endif

void bindKraken(std::unique_ptr<JSContext> &context) {
  auto kraken = JSA_CREATE_OBJECT(*context);

  // Other properties are injected by dart.
  JSA_SET_PROPERTY(*context, kraken, "appName", "Kraken");
  JSA_SET_PROPERTY(*context, kraken, "appVersion", VERSION_APP);
  JSA_SET_PROPERTY(*context, kraken, "platform", PLATFORM);
  JSA_SET_PROPERTY(*context, kraken, "product", PRODUCT);
  JSA_SET_PROPERTY(*context, kraken, "productSub", PRODUCT_SUB);

  JSA_SET_PROPERTY(*context, context->global(), "__kraken__", kraken);
}

} // namespace binding
} // namespace kraken
