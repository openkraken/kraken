list(APPEND KRAKEN_TEST_SOURCE
  include/kraken_bridge_test.h
  kraken_bridge_test.cc
  polyfill/dist/testframework.cc
)

set(gtest_disable_pthreads ON)

add_subdirectory(./third_party/googletest)
add_subdirectory(./third_party/benchmark)

list(APPEND KRAKEN_TEST_SOURCE
  page_test.cc
  page_test.h
)
list(APPEND KRAKEN_UNIT_TEST_SOURCE
  ./test/kraken_test_env.cc
  ./test/kraken_test_env.h
  ./bindings/qjs/js_context_test.cc
  ./bindings/qjs/bom/timer_test.cc
  ./bindings/qjs/bom/console_test.cc
  ./bindings/qjs/qjs_patch_test.cc
  ./bindings/qjs/host_object_test.cc
  ./bindings/qjs/host_class_test.cc
  ./bindings/qjs/dom/event_target_test.cc
  ./bindings/qjs/module_manager_test.cc
  ./bindings/qjs/dom/node_test.cc
  ./bindings/qjs/dom/event_test.cc
  ./bindings/qjs/dom/element_test.cc
  ./bindings/qjs/dom/document_test.cc
  ./bindings/qjs/dom/text_node_test.cc
  ./bindings/qjs/bom/window_test.cc
  ./bindings/qjs/dom/custom_event_test.cc
  ./bindings/qjs/module_manager_test.cc
)

### kraken_unit_test executable
add_executable(kraken_unit_test
  ${KRAKEN_UNIT_TEST_SOURCE}
  ${KRAKEN_TEST_SOURCE}
  ${BRIDGE_SOURCE}
)

target_include_directories(kraken_unit_test PUBLIC ./third_party/googletest/googletest/include ${BRIDGE_INCLUDE} ./test)
target_link_libraries(kraken_unit_test gtest gtest_main ${BRIDGE_LINK_LIBS})

target_compile_options(quickjs PUBLIC -DDUMP_LEAKS=1)
target_compile_options(kraken PUBLIC -DDUMP_LEAKS=1)

target_compile_definitions(kraken_unit_test PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(kraken_unit_test PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(kraken_unit_test PUBLIC -DUNIT_TEST=1)

target_compile_definitions(kraken_static PUBLIC -DFLUTTER_BACKEND=1)
if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken_unit_test
          PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
          )
endif()

# Run Kraken integration without flutter.
add_executable(kraken_integration_test
  ${KRAKEN_TEST_SOURCE}
  ${BRIDGE_SOURCE}
  ./test/kraken_test_env.cc
  ./test/kraken_test_env.h
  ./test/run_integration_test.cc
  )
target_include_directories(kraken_integration_test PUBLIC ./third_party/googletest/googletest/include ${BRIDGE_INCLUDE} ./test)
target_link_libraries(kraken_integration_test gtest gtest_main ${BRIDGE_LINK_LIBS})
target_compile_definitions(kraken_integration_test PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(kraken_integration_test PUBLIC -DUNIT_TEST=1)
target_compile_definitions(kraken_integration_test PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")

# Benchmark test
add_executable(kraken_benchmark
  ${KRAKEN_TEST_SOURCE}
  ${BRIDGE_SOURCE}
  ./test/kraken_test_env.cc
  ./test/kraken_test_env.h
  ./test/benchmark/create_element.cc
)
target_include_directories(kraken_benchmark PUBLIC
  ./third_party/googletest/googletest/include
  ./third_party/benchmark/include/
  ${BRIDGE_INCLUDE}
  ./test)
target_link_libraries(kraken_benchmark gtest gtest_main benchmark::benchmark  ${BRIDGE_LINK_LIBS})
target_compile_definitions(kraken_benchmark PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(kraken_benchmark PUBLIC -DUNIT_TEST=1)

# Built libkraken_test.dylib library for integration test with flutter.
add_library(kraken_test SHARED ${KRAKEN_TEST_SOURCE})
target_link_libraries(kraken_test PRIVATE ${BRIDGE_LINK_LIBS} kraken)
target_include_directories(kraken_test PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
endif()
