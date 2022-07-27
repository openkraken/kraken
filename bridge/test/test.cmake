list(APPEND WEBF_TEST_SOURCE
  include/webf_bridge_test.h
  webf_bridge_test.cc
  polyfill/dist/testframework.cc
)

set(gtest_disable_pthreads ON)

add_subdirectory(./third_party/googletest)
add_subdirectory(./third_party/benchmark)

list(APPEND WEBF_TEST_SOURCE
  page_test.cc
  page_test.h
)
list(APPEND WEBF_UNIT_TEST_SOURCEURCE
  ./test/webf_test_env.cc
  ./test/webf_test_env.h
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

### webf_unit_test executable
add_executable(webf_unit_test
  ${WEBF_UNIT_TEST_SOURCEURCE}
  ${WEBF_TEST_SOURCE}
  ${BRIDGE_SOURCE}
)

target_include_directories(webf_unit_test PUBLIC ./third_party/googletest/googletest/include ${BRIDGE_INCLUDE} ./test)
target_link_libraries(webf_unit_test gtest gtest_main ${BRIDGE_LINK_LIBS})

target_compile_options(quickjs PUBLIC -DDUMP_LEAKS=1)
target_compile_options(webf PUBLIC -DDUMP_LEAKS=1)

target_compile_definitions(webf_unit_test PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(webf_unit_test PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(webf_unit_test PUBLIC -DUNIT_TEST=1)

target_compile_definitions(webf_static PUBLIC -DFLUTTER_BACKEND=1)
if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(webf_unit_test
          PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
          )
endif()

# Run webf integration without flutter.
add_executable(webf_integration_test
  ${WEBF_TEST_SOURCE}
  ${BRIDGE_SOURCE}
  ./test/webf_test_env.cc
  ./test/webf_test_env.h
  ./test/run_integration_test.cc
  )
target_include_directories(webf_integration_test PUBLIC ./third_party/googletest/googletest/include ${BRIDGE_INCLUDE} ./test)
target_link_libraries(webf_integration_test gtest gtest_main ${BRIDGE_LINK_LIBS})
target_compile_definitions(webf_integration_test PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(webf_integration_test PUBLIC -DUNIT_TEST=1)
target_compile_definitions(webf_integration_test PUBLIC -DSPEC_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}")

# Benchmark test
add_executable(webf_benchmark
  ${WEBF_TEST_SOURCE}
  ${BRIDGE_SOURCE}
  ./test/webf_test_env.cc
  ./test/webf_test_env.h
  ./test/benchmark/create_element.cc
)
target_include_directories(webf_benchmark PUBLIC
  ./third_party/googletest/googletest/include
  ./third_party/benchmark/include/
  ${BRIDGE_INCLUDE}
  ./test)
target_link_libraries(webf_benchmark gtest gtest_main benchmark::benchmark  ${BRIDGE_LINK_LIBS})
target_compile_definitions(webf_benchmark PUBLIC -DFLUTTER_BACKEND=0)
target_compile_definitions(webf_benchmark PUBLIC -DUNIT_TEST=1)

# Built libwebf_test.dylib library for integration test with flutter.
add_library(webf_test SHARED ${WEBF_TEST_SOURCE})
target_link_libraries(webf_test PRIVATE ${BRIDGE_LINK_LIBS} webf)
target_include_directories(webf_test PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(webf_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
endif()
