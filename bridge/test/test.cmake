add_subdirectory(./third_party/googletest)

set(TEST_LINK_LIBRARY
        ${BRIDGE_LINK_LIBS}
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

add_executable(bridge_test
    ./test/bridge/blob.cc)
target_link_libraries(bridge_test ${TEST_LINK_LIBRARY})
target_include_directories(bridge_test PUBLIC ${TEST_INCLUDE_DIR})
