/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <benchmark/benchmark.h>
#include "kraken_test_env.h"
#include "page.h"

auto bridge = TEST_init();

static void BM_SomeFunction(benchmark::State& state) {
  auto& context = bridge->getContext();
  std::string code = "var a = document.createElement('div');";
  // Perform setup here
  for (auto _ : state) {
    context->evaluateJavaScript(code.c_str(), code.size(), "internal://", 0);
  }
}
// Register the function as a benchmark
BENCHMARK(BM_SomeFunction)->Threads(1);
// Run the benchmark
BENCHMARK_MAIN();
