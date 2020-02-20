add_subdirectory(./third_party/googletest)

set(TEST_LINK_LIBRARY
        jsa_abstraction
        jsa_implementation
        gtest
        gtest_main
        gmock
        gmock_main
        )

message(${JSA_INCLUDE_DIRS})

set(TEST_INCLUDE_DIR
        ./jsa/include
        ./third_party/googletest/googletest/include
        ./third_party/googletest/googlemock/include
        ${JSA_INCLUDE_DIRS}
        )


add_executable(v8_test ./test/jsa/v8/v8_test.cc)
target_link_libraries(v8_test ${TEST_LINK_LIBRARY})
target_include_directories(v8_test PUBLIC ${TEST_INCLUDE_DIR})
