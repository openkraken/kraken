cmake_minimum_required(VERSION 3.15)

project(Kraken LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)

add_definitions(-DIS_MAC=1)

add_library(flutter SHARED IMPORTED)

if ($ENV{KRAKEN_BUILD} MATCHES Release)
  set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
    $ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/FlutterMacOS
  )
else()
  set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
    $ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/FlutterMacOS
  )
endif()
include_directories($ENV{FLUTTER_ENGINE}/out/host_debug_unopt/FlutterMacOS.framework/Headers)
include_directories($ENV{FLUTTER_ENGINE}/out/host_release/FlutterMacOS.framework/Headers)
include_directories($ENV{FLUTTER_ENGINE}/out/host_debug/FlutterMacOS.framework/Headers)

set(BRIDGE_DIR ../../bridge)

add_subdirectory(${BRIDGE_DIR} ./CMakeFiles)

## define bridge library
add_library(bridge STATIC ${BRIDGE_DIR}/bridge.cc ${BRIDGE_DIR}/bridge.h ${BRIDGE_DIR}/message.cc ${BRIDGE_DIR}/message.h)
target_link_libraries(bridge jsa_jsc_implementation)
target_link_libraries(bridge jsa_abstraction)
target_link_libraries(bridge bindings)
target_link_libraries(bridge -pthread)
target_link_libraries(bridge flutter)
target_include_directories(bridge PUBLIC ./flutter/include)
target_include_directories(bridge PUBLIC ${BRIDGE_DIR}/bindings)

add_library(js_code STATIC ${BRIDGE_DIR}/polyfill/dist/polyfill.h ${BRIDGE_DIR}/polyfill/dist/polyfill.cc)
target_link_libraries(js_code bridge)
target_include_directories(js_code PUBLIC ${BRIDGE_DIR})

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

target_include_directories(kraken PUBLIC ${BRIDGE_DIR})
target_include_directories(kraken PUBLIC ${BRIDGE_DIR}/jsa/abstraction)
target_include_directories(kraken PUBLIC ${BRIDGE_DIR}/jsa/implementation/JSC)
target_include_directories(kraken PUBLIC ${BRIDGE_DIR}/foundation)
target_include_directories(kraken PUBLIC ${BRIDGE_DIR}/polyfill/dist)


target_link_libraries(kraken bridge)
target_link_libraries(bridge flutter)
target_link_libraries(kraken jsa_abstraction)
target_link_libraries(kraken jsa_jsc_implementation)
target_link_libraries(kraken foundation)
target_link_libraries(kraken js_code)
