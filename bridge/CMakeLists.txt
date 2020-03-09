cmake_minimum_required(VERSION 3.2.0)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
string(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME)
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

include(./jsa/jsa.cmake)

# foundation
add_subdirectory(foundation)
include_directories(foundation)

list(APPEND BRIDGE_SOURCE
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
    bindings/KOM/blob.cc
    bindings/KOM/blob.h
    bindings/KOM/toBlob.cc
    bindings/KOM/toBlob.h
    dart_methods.cc
    dart_methods.h
    bridge.cc
    bridge.h
    polyfill/dist/polyfill.cc
)

list(APPEND BRIDGE_INCLUDE
    ./jsa/include
    ./foundation
    ./
    ./include
    ./polyfill/dist
    ./foundation/websockettpp-0.8.1
    ${ADDITIONAL_INCLUDE_DIRS}
    ${JSA_INCLUDE_DIRS}
)

list(APPEND BRIDGE_LINK_LIBS
        jsa_abstraction
        jsa_implementation
        foundation
        -pthread
)

add_library(bridge STATIC ${BRIDGE_SOURCE} bridge_test.cc bridge_test.h)
add_library(kraken SHARED bridge_export.cc)
add_library(kraken_test SHARED
  bridge_test_export.cc include/bridge_test_export.h
  polyfill/dist/testframework.cc
  bridge_test.cc bridge_test.h)

### bridge
target_link_libraries(bridge PRIVATE ${BRIDGE_LINK_LIBS})
target_include_directories(bridge PRIVATE ${BRIDGE_INCLUDE})

### Kraken
target_link_libraries(kraken PRIVATE bridge)
target_include_directories(kraken PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

### kraken_test
target_link_libraries(kraken_test PRIVATE kraken)
target_include_directories(kraken_test PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)

execute_process(
  COMMAND grep version: ./pubspec.yaml
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../kraken
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
  set_target_properties(kraken_test PROPERTIES OUTPUT_NAME kraken_test_jsc)
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  set_target_properties(kraken PROPERTIES OUTPUT_NAME kraken_v8)
  set_target_properties(kraken_test PROPERTIES OUTPUT_NAME kraken_test_v8)
endif()

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
  set_target_properties(kraken_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
else ()
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../targets/${CMAKE_SYSTEM_NAME}/${CMAKE_BUILD_TYPE}/lib"
    )
  set_target_properties(kraken_test
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../targets/${CMAKE_SYSTEM_NAME}/${CMAKE_BUILD_TYPE}/lib"
    )
endif ()
