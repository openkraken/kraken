cmake_minimum_required(VERSION 3.2.0)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.12)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
string(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME)
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)

list(APPEND BRIDGE_SOURCE
    foundation/logging.cc
    foundation/logging.h
    foundation/colors.h
    foundation/ref_counted_internal.h
    foundation/ref_counter.h
    foundation/ref_ptr.h
    foundation/ref_ptr_internal.h
    foundation/ui_task_queue.h
    foundation/ui_task_queue.cpp
    foundation/ui_command_queue.h
    foundation/ui_command_queue.cpp
    foundation/closure.h
    foundation/bridge_callback.h
    dart_methods.cc
    dart_methods.h
    bridge.cc
    bridge.h
    polyfill/dist/polyfill.cc
)

if (${KRAKEN_ENABLE_JSA})
  include(./jsa/jsa.cmake)
  list(APPEND BRIDGE_SOURCE
    bindings/jsa/KOM/console.cc
    bindings/jsa/KOM/screen.cc
    bindings/jsa/KOM/timer.cc
    bindings/jsa/KOM/window.cc
    bindings/jsa/KOM/window.h
    bindings/jsa/KOM/location.cc
    bindings/jsa/KOM/location.h
    bindings/jsa/kraken.cc
    bindings/jsa/ui_manager.cpp
    bindings/jsa/ui_manager.h
    bindings/jsa/KOM/blob.cc
    bindings/jsa/KOM/blob.h
    bindings/jsa/KOM/toBlob.cc
    bindings/jsa/KOM/toBlob.h
    bindings/jsa/DOM/document.cc
    bindings/jsa/DOM/document.h
    bindings/jsa/DOM/element.cc
    bindings/jsa/DOM/element.h
    bindings/jsa/DOM/node.cc
    bindings/jsa/DOM/node.h
    bindings/jsa/DOM/eventTarget.cc
    bindings/jsa/DOM/eventTarget.h
  )

  list(APPEND BRIDGE_LINK_LIBS
          jsa_abstraction
          jsa_implementation
          -pthread
          )
  list(APPEND BRIDGE_INCLUDE
          ${JSA_INCLUDE_DIRS}
          ./jsa/include
          )
else()
  if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
    add_compile_options(-DKRAKEN_JSC_ENGINE=1)

    if (${IS_ANDROID})
      list(APPEND BRIDGE_INCLUDE
              ${CMAKE_CURRENT_SOURCE_DIR}/third_party/JavaScriptCore-604.1.13/include
              )
      # jsc预编译库
      add_library(JavaScriptCore SHARED IMPORTED)
      set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
              "${CMAKE_CURRENT_SOURCE_DIR}/third_party/JavaScriptCore-604.1.13/lib/android/${ANDROID_ABI}/libjsc.so"
              )
      # 链接jsc
      list(APPEND BRIDGE_LINK_LIBS
              JavaScriptCore
              )
    else ()
      list(APPEND BRIDGE_LINK_LIBS "-framework JavaScriptCore")
    endif ()

    list(APPEND BRIDGE_SOURCE
      bindings/jsc/js_context.h
      bindings/jsc/js_context.cc
      bindings/jsc/ui_manager.h
      bindings/jsc/ui_manager.cc
      bindings/jsc/DOM/document.h
      bindings/jsc/DOM/document.cc
      bindings/jsc/DOM/element.cc
      bindings/jsc/DOM/element.h
      bindings/jsc/DOM/eventTarget.cc
      bindings/jsc/DOM/eventTarget.h
      bindings/jsc/DOM/node.cc
      bindings/jsc/DOM/node.h
      bindings/jsc/KOM/console.h
      bindings/jsc/KOM/console.cc
    )
  endif()
endif()

list(APPEND BRIDGE_INCLUDE
    ./foundation
    ./
    ./include
    ./polyfill/dist
    ${ADDITIONAL_INCLUDE_DIRS}
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
add_definitions(-DAPP_VERSION="${APP_VER}") # Read from dartfm version
execute_process(
  COMMAND /usr/bin/git rev-parse --short HEAD
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
  OUTPUT_VARIABLE GIT_HEAD
)
string(REPLACE \n "" GIT_HEAD ${GIT_HEAD}) # Remove last \n
add_definitions(-DAPP_REV="${GIT_HEAD}") # Read from git head sha1

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
