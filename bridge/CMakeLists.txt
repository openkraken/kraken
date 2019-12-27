cmake_minimum_required(VERSION 3.2.0)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(JSA_DIR ../jsa)

#load jsa
add_subdirectory(${JSA_DIR} ${JSA_DIR})
project(Bridge_Test)

# foundation
add_subdirectory(foundation)
include_directories(foundation)

# test
if (${ENABLE_TEST})
  add_subdirectory(test)
  include_directories(test)
endif ()

add_library(bindings STATIC
  bindings/kraken.cc
  bindings/kraken.h
  bindings/console.cc
  bindings/console.h
  bindings/fetch.cc
  bindings/fetch.h
  bindings/screen.cc
  bindings/screen.h
  bindings/thread_safe_map.h
  bindings/thread_safe_data.h
  bindings/timer.cc
  bindings/timer.h
  bindings/websocket.cc
  bindings/websocket.h
  bindings/window.cc
  bindings/window.h
  )

target_include_directories(bindings PUBLIC ${JSA_DIR}/abstraction)
target_include_directories(bindings PUBLIC ${JSA_DIR}/implementation/JSC)
target_include_directories(bindings PUBLIC ./foundation)

target_link_libraries(bindings PUBLIC jsa_abstraction)
target_link_libraries(bindings PUBLIC jsa_jsc_implementation)
target_link_libraries(bindings PUBLIC foundation)

if ($ENV{KRAKEN_BUILD} MATCHES Release)
  target_include_directories(bindings PUBLIC $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/Headers)
else()
  target_include_directories(bindings PUBLIC $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/Headers)
endif()

execute_process(
  COMMAND grep version: ./pubspec.yaml
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../dartfm
  OUTPUT_VARIABLE APP_VER
)
string(SUBSTRING ${APP_VER} 9 30 APP_VER)
string(REPLACE \n "" APP_VER ${APP_VER}) # Remove last \n
add_definitions(-DVERSION_APP="${APP_VER}") # Read from dartfm version
add_definitions(-DPRODUCT="kraken")
execute_process(
  COMMAND /usr/bin/git rev-parse --short HEAD
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_HEAD
)
string(REPLACE \n "" GIT_HEAD ${GIT_HEAD}) # Remove last \n
add_definitions(-DPRODUCT_SUB="${GIT_HEAD}") # Read from git head sha1

if (${ENABLE_TEST})
  target_compile_definitions(bindings PRIVATE IS_TEST=true)
endif ()
