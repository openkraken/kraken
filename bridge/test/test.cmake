list(APPEND KRAKEN_TEST_SOURCE
        include/kraken_bridge_test.h
        kraken_bridge_test.cc
        polyfill/dist/testframework.cc
        )

if (${KRAKEN_ENABLE_JSA})
  list(APPEND KRAKEN_TEST_SOURCE
      bridge_test_jsa.cc
      bridge_test_jsa.h
  )
else()
  if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
    list(APPEND KRAKEN_TEST_SOURCE
      bridge_test_jsc.cc
      bridge_test_jsc.h
    )
  endif()
endif()

add_library(kraken_test SHARED ${KRAKEN_TEST_SOURCE})

### kraken_test
target_link_libraries(kraken_test PRIVATE kraken ${BRIDGE_LINK_LIBS})
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
else ()
  set_target_properties(kraken_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../targets/${CMAKE_SYSTEM_NAME}/lib"
    )
endif ()

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

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  add_executable(jsa_test_jsc ./test/jsa/jsc/jsc_test.cc ./test/jsa/jsc/multiple_context.cc)
  target_link_libraries(jsa_test_jsc ${TEST_LINK_LIBRARY})
  target_include_directories(jsa_test_jsc PUBLIC ${TEST_INCLUDE_DIR})
endif()

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  add_executable(jsa_test_v8 ./test/jsa/v8/v8_test.cc)
  target_link_libraries(jsa_test_v8 ${TEST_LINK_LIBRARY})
  target_include_directories(jsa_test_v8 PUBLIC ${TEST_INCLUDE_DIR})
endif ()

add_executable(foundation_test
  ./test/foundation/bridge_callback_test.cc
  )
target_link_libraries(foundation_test ${TEST_LINK_LIBRARY})
target_include_directories(foundation_test PUBLIC ${TEST_INCLUDE_DIR})

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
    set_target_properties(jsa_test_jsc
      PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      )
  endif ()

  if ($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
    set_target_properties(jsa_test_v8
      PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      )
  endif ()

  set_target_properties(foundation_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
endif()
