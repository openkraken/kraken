/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <benchmark/benchmark.h>
#include "bridge_qjs.h"

static void CreateRawJavaScriptObject(benchmark::State& state) {
  kraken::JSBridge* bridge = new kraken::JSBridge(0, nullptr);
  std::string code = "var a = {}";
  // Perform setup here
  for (auto _ : state) {
    bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  }

  delete bridge;
}

static void CreateDivElement(benchmark::State& state) {
  kraken::JSBridge* bridge = new kraken::JSBridge(0, nullptr);
  std::string code = "var a = document.createElement('div');";
  // Perform setup here
  for (auto _ : state) {
    bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  }

  delete bridge;
}


BENCHMARK(CreateRawJavaScriptObject)->Threads(1);
BENCHMARK(CreateDivElement)->Threads(1);


// Run the benchmark
BENCHMARK_MAIN();
