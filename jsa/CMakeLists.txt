cmake_minimum_required(VERSION 3.2.0)

# set C++ language version
set(CMAKE_CXX_STANDARD 14)

# load abstraction
include_directories(abstraction)
add_subdirectory(abstraction)

include_directories(implementation/JSC)
add_subdirectory(implementation/JSC)

if (${ENABLE_TEST})
  include_directories(test)
  add_subdirectory(test)
endif()

