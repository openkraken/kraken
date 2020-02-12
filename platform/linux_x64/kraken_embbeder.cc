/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_embbeder.h"
#include "generated_plugin_registrant.h"
#include <stdlib.h>

int init_kraken(
    flutter::FlutterWindowController &flutterWindowController,
    std::string &assets_path,
    std::string &icu_data_path,
    flutter::WindowProperties &properties
    ) {

  // Arguments for the Flutter Engine.
  std::vector<std::string> arguments;

  if (properties.title.empty()) {
    properties.title = "";
  }

  if (properties.width == 0) {
    properties.width = 800;
  }

  if (properties.height == 0) {
    properties.height = 600;
  }

  // Start the engine.
  if (!flutterWindowController.CreateWindow(properties, assets_path,
                                       arguments)) {
    return EXIT_FAILURE;
  }
  RegisterPlugins(&flutterWindowController);

  return EXIT_SUCCESS;
}

void setJSLoadURL(const char* url) {
  setenv("KRAKEN_BUNDLE_URL", url, 1);
}

void setJSPath(const char* path) {
  setenv("KRAKEN_BUNDLE_PATH", path, 1);
}
