add_library(kraken_test SHARED
  bridge_test_export.cc
  include/bridge_test_export.h
  polyfill/dist/testframework.cc
  bridge_test.cc bridge_test.h)

### kraken_test
target_link_libraries(kraken_test PRIVATE kraken)
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
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../targets/${CMAKE_SYSTEM_NAME}/${CMAKE_BUILD_TYPE}/lib"
    )
endif ()

add_subdirectory(./third_party/googletest)

set(TEST_LINK_LIBRARY
        ${BRIDGE_LINK_LIBS}
        kraken_test
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

add_executable(jsa_test
        ./test/jsa/v8/v8_test.cc
        ./test/jsa/jsc/jsc_test.cc)
target_link_libraries(jsa_test ${TEST_LINK_LIBRARY})
target_include_directories(jsa_test PUBLIC ${TEST_INCLUDE_DIR})

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  set_target_properties(jsa_test PROPERTIES RUNTIME_OUTPUT_NAME jsa_test_jsc)
endif()

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  set_target_properties(jsa_test PROPERTIES RUNTIME_OUTPUT_NAME jsa_test_v8)
endif()

add_executable(kom_test
  ./test/kom/blob.cc
  ./test/kom/test_framework.cc
)
target_link_libraries(kom_test ${TEST_LINK_LIBRARY})
target_include_directories(kom_test PUBLIC ${TEST_INCLUDE_DIR})

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(jsa_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
  set_target_properties(kom_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
endif()
