set(TEST_LINK_LIBRARY
        bindings
        jsa_abstraction
        jsc_implementation
        gtest
        gtest_main
        js_code
        flutter
        )

set(TEST_INCLUDE_DIR
        ../bindings
        ../jsa/include
        ../polyfill/dist/
        ./googletest/googletest/include
        )

# console test
add_executable(console_test console_test.cc reload_test.cc)
target_link_libraries(console_test ${TEST_LINK_LIBRARY})
target_include_directories(console_test PUBLIC ${TEST_INCLUDE_DIR})

add_executable(reload_test ./reload_test.cc)
target_link_libraries(reload_test ${TEST_LINK_LIBRARY})
target_include_directories(reload_test PUBLIC ${TEST_INCLUDE_DIR})
