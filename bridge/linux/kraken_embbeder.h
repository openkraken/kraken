/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_test.h"
#include <flutter/flutter_window_controller.h>
#include <memory>
#include <string>

KRAKEN_EXPORT
int init_kraken(
  flutter::FlutterWindowController &flutterWindowController,
  std::string &assets_path,
  std::string &icu_data_path,
  flutter::WindowProperties &properties
);

KRAKEN_EXPORT
void setJSLoadURL(const char* url);

KRAKEN_EXPORT
void setJSPath(const char* path);
