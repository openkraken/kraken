project(JSA_Test)
# load Google test
add_subdirectory(../../third_party/googletest ../../third_party/googletest)
include_directories(${gtest_SOURCE_DIR}/include ${gtest_SOURCE_DIR})

add_executable(jsa_test to_sum.cc)
target_link_libraries(jsa_test jsa_abstraction)
target_link_libraries(jsa_test jsa_jsc_implementation)
target_link_libraries(jsa_test gtest gtest_main)
