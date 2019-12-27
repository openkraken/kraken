cmake_minimum_required(VERSION 3.15)

project(Kraken LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)

add_definitions(-DIS_LINUX=1)
set(IS_LINUX_X86 1)

add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
  $ENV{FLUTTER_ENGINE}/out/host_debug/libflutter_engine.so
  )
include_directories($ENV{FLUTTER_ENGINE}/out/host_debug_unopt/)
include_directories($ENV{FLUTTER_ENGINE}/out/host_release/)
include_directories($ENV{FLUTTER_ENGINE}/out/host_debug/)

add_subdirectory(./bridge)

## define bridge library
add_library(bridge STATIC bridge/bridge.cc bridge/bridge.h bridge/message.cc bridge/message.h)
target_link_libraries(bridge jsa_jsc_implementation)
target_link_libraries(bridge jsa_abstraction)
target_link_libraries(bridge bindings)
target_link_libraries(bridge -pthread)
target_link_libraries(bridge flutter)
target_include_directories(bridge PUBLIC ./flutter/include)
target_include_directories(bridge PUBLIC ./bridge/bindings)

add_library(js_code STATIC ../../polyfill/dist/polyfill.h ../../polyfill/dist/polyfill.cc)
target_link_libraries(js_code bridge)
target_include_directories(js_code PUBLIC ./bridge)

add_library(kraken SHARED ../common/kraken_bridge_export.cc ../common/kraken_bridge_export.h)

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
else()
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../lib"
    )
endif()

target_include_directories(kraken PUBLIC ./bridge)
target_include_directories(kraken PUBLIC ./bridge/jsa/abstraction)
target_include_directories(kraken PUBLIC ./bridge/jsa/implementation/JSC)
target_include_directories(kraken PUBLIC ./bridge/foundation)
target_include_directories(kraken PUBLIC ../../polyfill/dist)

target_link_libraries(kraken bridge)
target_link_libraries(bridge flutter)
target_link_libraries(kraken jsa_abstraction)
target_link_libraries(kraken jsa_jsc_implementation)
target_link_libraries(kraken foundation)
target_link_libraries(kraken js_code)
