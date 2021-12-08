set(CMAKE_BUILD_TYPE Release)

# Fix Cmake configure Could NOT find Threads (missing: Threads_FOUND)
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)

# Benchmark sources
list(APPEND KRAKEN_BENCHMARK_SOURCE
  ./benchmark/test.cc
)

# Load benchmark library
add_subdirectory(./third_party/benchmark)

# Built the executable binary
add_executable(kraken_binding_benchmark ${KRAKEN_BENCHMARK_SOURCE})

# Configure C/C++ Header search path
target_include_directories(kraken_binding_benchmark PUBLIC
  ${BRIDGE_INCLUDE} # Kraken include directory
  ./third_party/benchmark/include # Benchmark library
)

# Configure C/C++ objects link dependencies.
target_link_libraries(kraken_binding_benchmark PUBLIC
  benchmark::benchmark
  ${BRIDGE_LINK_LIBS}
)


