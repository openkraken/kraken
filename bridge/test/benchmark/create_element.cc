/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <benchmark/benchmark.h>
#include "page.h"
#include "webf_test_env.h"

auto bridge = TEST_init();

static void CreateRawJavaScriptObjects(benchmark::State& state) {
  auto& context = bridge->getContext();
  std::string code = "var a = {}";
  // Perform setup here
  for (auto _ : state) {
    context->evaluateJavaScript(code.c_str(), code.size(), "internal://", 0);
  }
}

static void CreateDivElement(benchmark::State& state) {
  auto& context = bridge->getContext();
  std::string code = "var a = document.createElement('div');";
  // Perform setup here
  for (auto _ : state) {
    context->evaluateJavaScript(code.c_str(), code.size(), "internal://", 0);
  }
}

BENCHMARK(CreateRawJavaScriptObjects)->Threads(1);
BENCHMARK(CreateDivElement)->Threads(1);

// Run the benchmark
BENCHMARK_MAIN();
