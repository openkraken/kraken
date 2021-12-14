list(APPEND KRAKEN_TEST_SOURCE
  include/kraken_bridge_test.h
  kraken_bridge_test.cc
  polyfill/dist/testframework.cc
)

set(gtest_disable_pthreads ON)

add_subdirectory(./third_party/googletest)

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  list(APPEND KRAKEN_TEST_SOURCE
    bridge_test_jsc.cc
    bridge_test_jsc.h
  )
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "quickjs")
  list(APPEND KRAKEN_TEST_SOURCE
    bridge_test_qjs.cc
    bridge_test_qjs.h
  )
  list(APPEND KRAKEN_UNIT_TEST_SOURCE
    ./bindings/qjs/js_context_test.cc
    ./bindings/qjs/bom/console_test.cc
    ./bindings/qjs/qjs_patch_test.cc
    ./bindings/qjs/host_object_test.cc
    ./bindings/qjs/host_class_test.cc
    ./bindings/qjs/dom/event_target_test.cc
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
  add_executable(kraken_unit_test ${KRAKEN_UNIT_TEST_SOURCE} ${KRAKEN_TEST_SOURCE} ${BRIDGE_SOURCE} ../bindings/qjs/html_parser.cc ../bindings/qjs/html_parser.h ../bindings/qjs/module_manager_test.cc)
  target_include_directories(kraken_unit_test PUBLIC ./third_party/googletest/googletest/include ${BRIDGE_INCLUDE})
  target_link_libraries(kraken_unit_test gtest gtest_main ${BRIDGE_LINK_LIBS})

  target_compile_options(quickjs PUBLIC -DDUMP_LEAKS=1)
  target_compile_options(kraken PUBLIC -DDUMP_LEAKS=1)

  target_compile_definitions(kraken_unit_test PUBLIC -DFLUTTER_BACKEND=0)
  target_compile_definitions(kraken_static PUBLIC -DFLUTTER_BACKEND=1)
  if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
    set_target_properties(kraken_unit_test
            PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
            )
  endif()
endif()

### kraken_integration support library
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
