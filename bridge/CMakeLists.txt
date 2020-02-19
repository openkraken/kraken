cmake_minimum_required(VERSION 3.2.0)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(./jsa/jsa.cmake)

# foundation
add_subdirectory(foundation)
include_directories(foundation)

add_library(bindings STATIC
  bindings/KOM/console.cc
  bindings/KOM/screen.cc
  bindings/KOM/timer.cc
  bindings/KOM/websocket.cc
  bindings/KOM/websocket.h
  bindings/KOM/window.cc
  bindings/KOM/window.h
  bindings/KOM/location.cc
  bindings/KOM/location.h
  bindings/kraken.cc
)
add_library(bridge STATIC bridge.cc bridge.h)
add_library(dart_methods STATIC dart_methods.cc dart_methods.h)
add_library(js_code STATIC polyfill/dist/polyfill.h polyfill/dist/polyfill.cc)
add_library(kraken SHARED bridge_export.cc)

### Bindings
target_include_directories(bindings PRIVATE
  ./jsa/include
  ./foundation
  ./
  ./foundation/websockettpp-0.8.1
  ${ADDITIONAL_INCLUDE_DIRS}
  ${JSA_INCLUDE_DIRS}
  )
target_link_libraries(bindings PRIVATE
  jsa_abstraction
  jsa_implementation
  dart_methods
  foundation)

### Bridges
target_link_libraries(bridge PRIVATE
  jsa_implementation
  jsa_abstraction
  dart_methods
  bindings
  -pthread)
target_include_directories(bridge PRIVATE
  ./jsa/include
  ${JSA_INCLUDE_DIRS}
  ${ADDITIONAL_INCLUDE_DIRS})

target_include_directories(dart_methods PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${JSA_INCLUDE_DIRS}
  PUBLIC ./include
)

### Js Code
target_link_libraries(js_code PRIVATE bridge)
target_include_directories(js_code PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ./jsa/include
  ${ADDITIONAL_INCLUDE_DIRS}
  ${JSA_INCLUDE_DIRS}
  )

### Kraken
target_link_libraries(kraken PRIVATE
  bridge
  js_code
  )
target_include_directories(kraken PRIVATE
  ./foundation
  ./polyfill/dist
  ./jsa/include
  ${ADDITIONAL_INCLUDE_DIRS}
  ${JSA_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

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

include(./test/test.cmake)
if (${ENABLE_TEST})
  add_compile_definitions(IS_TEST=true)
endif ()

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  set_target_properties(kraken PROPERTIES OUTPUT_NAME kraken_jsc)
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  set_target_properties(kraken PROPERTIES OUTPUT_NAME kraken_v8)
endif()

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
else ()
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../cli/build/lib"
    )
endif ()
