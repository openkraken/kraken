list(APPEND KRAKEN_TEST_SOURCE
        include/kraken_bridge_test.h
        kraken_bridge_test.cc
        polyfill/dist/testframework.cc
        )

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  list(APPEND KRAKEN_TEST_SOURCE
    bridge_test_jsc.cc
    bridge_test_jsc.h
  )
endif()

add_library(kraken_test SHARED ${KRAKEN_TEST_SOURCE})

### kraken_test
target_link_libraries(kraken_test PRIVATE ${BRIDGE_LINK_LIBS} kraken)
target_include_directories(kraken_test PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  set_target_properties(kraken_test PROPERTIES OUTPUT_NAME kraken_test_jsc)
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  set_target_properties(kraken_test PROPERTIES OUTPUT_NAME kraken_test_v8)
endif()

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
endif()

add_subdirectory(./third_party/googletest)

set(TEST_LINK_LIBRARY
        ${BRIDGE_LINK_LIBS}
        kraken_test
        kraken
        bridge
        gtest
        gtest_main
        gmock
        gmock_main
        )

set(TEST_INCLUDE_DIR
        ./third_party/googletest/googletest/include
        ./third_party/googletest/googlemock/include
        ${BRIDGE_INCLUDE}
        )
