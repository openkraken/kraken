cmake_minimum_required(VERSION 3.2.0)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.12)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
string(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME)
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

include(./jsa/jsa.cmake)

list(APPEND BRIDGE_SOURCE
    bindings/KOM/console.cc
    bindings/KOM/screen.cc
    bindings/KOM/timer.cc
    bindings/KOM/window.cc
    bindings/KOM/window.h
    bindings/KOM/location.cc
    bindings/KOM/location.h
    bindings/kraken.cc
    bindings/KOM/blob.cc
    bindings/KOM/blob.h
    bindings/KOM/toBlob.cc
    bindings/KOM/toBlob.h
    foundation/logging.cc
    foundation/logging.h
    foundation/colors.h
    foundation/bridge_callback.h
    foundation/bridge_callback.cc
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
    ${ADDITIONAL_INCLUDE_DIRS}
    ${JSA_INCLUDE_DIRS}
)

list(APPEND BRIDGE_LINK_LIBS
        jsa_abstraction
        jsa_implementation
        -pthread
)

list(APPEND PUBLIC_HEADER
  include/kraken_bridge.h
  )

add_library(bridge STATIC ${BRIDGE_SOURCE})
add_library(kraken SHARED kraken_bridge.cc ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_bridge.h)

if (${IS_ANDROID})
  find_library(log-lib log)
  list(APPEND BRIDGE_LINK_LIBS ${log-lib})
endif ()

### bridge
target_link_libraries(bridge PRIVATE ${BRIDGE_LINK_LIBS})
target_include_directories(bridge PRIVATE ${BRIDGE_INCLUDE})

### Kraken
target_link_libraries(kraken PRIVATE bridge)
target_include_directories(kraken PRIVATE
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

if (${ENABLE_TEST})
  add_compile_definitions(IS_TEST=true)
  include(./test/test.cmake)
endif ()

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  set_target_properties(kraken PROPERTIES OUTPUT_NAME kraken_jsc)
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "v8")
  set_target_properties(kraken PROPERTIES OUTPUT_NAME kraken_v8)
endif()

if (IS_ANDROID)
  # DONOT set output dir for android gradle.
else ()
  if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
    set_target_properties(kraken
      PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
      )
  else ()
    set_target_properties(kraken
      PROPERTIES
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../targets/${CMAKE_SYSTEM_NAME}/lib"
      )
  endif ()
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "ios")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

  set_target_properties(kraken PROPERTIES
    OUTPUT_NAME kraken_bridge
    FRAMEWORK TRUE
    FRAMEWORK_VERSION C
    MACOSX_FRAMEWORK_IDENTIFIER com.taobao.kraken_bridge
    PUBLIC_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_bridge.h
    )

  if (${CMAKE_BUILD_TYPE} STREQUAL "release")
    get_target_property(OUTPUT_DIRECTORY kraken LIBRARY_OUTPUT_DIRECTORY)
    add_custom_command(TARGET kraken POST_BUILD
      COMMAND ${CMAKE_STRIP} -x -X -S ${OUTPUT_DIRECTORY}/kraken_bridge.framework/kraken_bridge)
  endif ()
elseif(${CMAKE_SYSTEM_NAME} MATCHES "darwin")
  if (${CMAKE_BUILD_TYPE} STREQUAL "release")
    get_target_property(OUTPUT_DIRECTORY kraken LIBRARY_OUTPUT_DIRECTORY)
    get_target_property(OUTPUT_NAME kraken OUTPUT_NAME)
    add_custom_command(TARGET kraken POST_BUILD
      COMMAND ${CMAKE_STRIP} -x -X -S ${OUTPUT_DIRECTORY}/lib${OUTPUT_NAME}.dylib)
  endif ()
endif()
