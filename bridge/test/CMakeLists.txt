project(Bridge_TEST)

include(googletest)
include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})

add_compile_definitions(IS_TEST=true)

# console test
add_executable(console_test console_test.cc)
target_link_libraries(console_test bindings)
target_link_libraries(console_test jsa_abstraction)
target_link_libraries(console_test jsa_jsc_implementation)
target_link_libraries(console_test gtest gtest_main)
target_include_directories(console_test PUBLIC ../bindings)
target_include_directories(console_test PUBLIC ../../jsa/abstraction)
target_include_directories(console_test PUBLIC ../../jsa/implementation/JSC)


# websocket test
add_executable(websocket_test websocket_test.cc)
target_link_libraries(websocket_test bindings)
target_link_libraries(websocket_test foundation)
target_link_libraries(websocket_test jsa_abstraction)
target_link_libraries(websocket_test jsa_jsc_implementation)
target_link_libraries(websocket_test gtest gtest_main)
target_include_directories(websocket_test PUBLIC ../bindings)
target_include_directories(websocket_test PUBLIC ../../jsa/abstraction)
target_include_directories(websocket_test PUBLIC ../../jsa/implementation/JSC)

add_executable(message_test ../message.cc ../message.h message_test.cc)
target_include_directories(message_test PUBLIC ../)
target_link_libraries(message_test gtest gtest_main)
