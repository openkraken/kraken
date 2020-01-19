cmake_minimum_required(VERSION 3.2.0)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(./jsa/jsa.cmake)

# foundation
add_subdirectory(foundation)
include_directories(foundation)

# test
if (${ENABLE_TEST})
  add_subdirectory(test)
  include_directories(test)
endif ()

add_library(bindings STATIC
  bindings/KOM/console.cc
  bindings/KOM/fetch.cc
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
add_library(bridge STATIC bridge.cc bridge.h message.cc message.h)
add_library(js_code STATIC polyfill/dist/polyfill.h polyfill/dist/polyfill.cc)
add_library(kraken SHARED kraken_bridge_export.cc)
add_library(flutter SHARED IMPORTED)

### Bindings
target_include_directories(bindings PRIVATE
  ./jsa/include
  ./foundation
  ${ADDITIONAL_INCLUDE_DIRS}
  )
target_link_libraries(bindings PRIVATE
  jsa_abstraction
  jsc_implementation
  foundation)

### Bridges
target_link_libraries(bridge PRIVATE
  jsc_implementation
  jsa_abstraction
  bindings
  -pthread
  flutter)
target_include_directories(bridge PRIVATE
  ./jsa/include
  ${ADDITIONAL_INCLUDE_DIRS})

message(STATUS ${ADDITIONAL_INCLUDE_DIRS})

### Js Code
target_link_libraries(js_code PRIVATE bridge)
target_include_directories(js_code PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ./jsa/include
  ${ADDITIONAL_INCLUDE_DIRS}
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
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

## Linux X86_64
if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
  if ($ENV{KRAKEN_BUILD} MATCHES Release)
    set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
      $ENV{FLUTTER_ENGINE}/out/host_debug/libflutter_linux_glfw.so
      )
    target_include_directories(bindings PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/)
    target_include_directories(bridge PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/)
    target_include_directories(kraken PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/)
  else ()
    set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
      $ENV{FLUTTER_ENGINE}/out/host_release/libflutter_linux_glfw.so
      )
    target_include_directories(bindings PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/)
    target_include_directories(bridge PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/)
    target_include_directories(kraken PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/)
  endif ()
## macOS
elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Darwin")
  if ($ENV{KRAKEN_BUILD} MATCHES Release)
    set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
      $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/FlutterMacOS
      )
    target_include_directories(bindings PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/Headers)
    target_include_directories(bridge PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/Headers)
    target_include_directories(kraken PRIVATE $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/Headers)
  else ()
    set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
      $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/FlutterMacOS
      )
    target_include_directories(bindings PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/Headers)
    target_include_directories(bridge PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/Headers)
    target_include_directories(kraken PRIVATE $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/Headers)
  endif ()
endif ()

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
