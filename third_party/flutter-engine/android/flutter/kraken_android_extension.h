// Copyright 2019 The Alibaba Authors. All rights reserved.
// Author: chuyi

#ifndef SHELL_PLATFORM_ANDROID_KRAKEN_ANDROID_EXTENSION_H_
#define SHELL_PLATFORM_ANDROID_KRAKEN_ANDROID_EXTENSION_H_

#include <stdint.h>

#if OS_WIN
#define KRAKEN_EXPORT __declspec(dllexport)
#else  // OS_WIN
#define KRAKEN_EXPORT __attribute__((visibility("default")))
#endif  // OS_WIN

typedef void (*IsolateCreateCallback)(void*);
typedef void (*DartToJSCallback)(const char*, void*);

typedef void (*UITask)(void*);

KRAKEN_EXPORT
void set_root_isolate_create_callback(IsolateCreateCallback callback, void* userdata);
KRAKEN_EXPORT
void set_dart_to_js_callback(DartToJSCallback callback, void* userdata);

KRAKEN_EXPORT
void post_to_ui_thread(int64_t shell_holder, UITask task, void* data);

#endif  // SHELL_PLATFORM_ANDROID_KRAKEN_ANDROID_EXTENSION_H_