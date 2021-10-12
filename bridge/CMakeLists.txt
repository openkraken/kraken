cmake_minimum_required(VERSION 3.10.0)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
string(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME)
string(TOLOWER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(${ENABLE_PROFILE})
  add_definitions(-DENABLE_PROFILE=1)
else()
  add_definitions(-DENABLE_PROFILE=0)
endif()

find_program(DART_PATH dart)
set(DART_SDK "${DART_PATH}/cache/dart-sdk/include")
string(REGEX REPLACE "\n$" "" DART_SDK "${DART_SDK}")

list(APPEND PUBLIC_HEADERS
  ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_bridge.h
)

list(APPEND BRIDGE_SOURCE
    kraken_bridge.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_bridge.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_foundation.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/dart_methods.h
    foundation/logging.cc
    foundation/logging.h
    foundation/colors.h
    foundation/ref_counted_internal.h
    foundation/ref_counter.h
    foundation/ref_ptr.h
    foundation/ref_ptr_internal.h
    foundation/ui_task_queue.h
    foundation/ui_task_queue.cc
    foundation/inspector_task_queue.h
    foundation/inspector_task_queue.cc
    foundation/task_queue.cc
    foundation/task_queue.h
    foundation/ui_command_buffer.cc
    foundation/ui_command_callback_queue.cc
    foundation/closure.h
    foundation/bridge_callback.h
    dart_methods.cc
    polyfill/dist/polyfill.cc
)

list(APPEND GUMBO_PAESER
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/attribute.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/attribute.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/char_ref.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/char_ref.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/error.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/error.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/gumbo.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/insertion_mode.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/parser.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/parser.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_buffer.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_buffer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_piece.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_piece.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tag_enum.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tag_gperf.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tag_sizes.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tag_strings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tag.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_piece.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/string_piece.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/token_type.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tokenizer_states.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tokenizer.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/tokenizer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/utf8.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/utf8.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/util.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/util.h
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/vector.c
    ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/gumbo-parser/src/vector.h
)

list(APPEND BRIDGE_INCLUDE
  ./foundation
  ./
  ../
  ./include
  ./polyfill/dist
  ${DART_SDK}
  ${ADDITIONAL_INCLUDE_DIRS}
  )

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  add_compile_options(-DKRAKEN_JSC_ENGINE=1)

  if (${IS_ANDROID})
    list(APPEND BRIDGE_INCLUDE
            ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore/include
            )
    add_library(JavaScriptCore SHARED IMPORTED)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore/lib/android/${ANDROID_ABI}/libjsc.so"
            )
    list(APPEND BRIDGE_LINK_LIBS
            JavaScriptCore
            )
  elseif (EXISTS ${DEBUG_JSC_ENGINE})
    list(APPEND BRIDGE_INCLUDE ${DEBUG_JSC_ENGINE}/Headers)
    add_library(JavaScriptCore SHARED IMPORTED)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION ${DEBUG_JSC_ENGINE}/JavaScriptCore)
    list(APPEND BRIDGE_LINK_LIBS JavaScriptCore)
  else()
    add_compile_options(-DIS_APPLE=1)
    list(APPEND BRIDGE_LINK_LIBS "-framework JavaScriptCore")
  endif ()

  list(APPEND BRIDGE_SOURCE
    bindings/jsc/js_context_internal.h
    bindings/jsc/js_context_internal.cc
    bindings/jsc/html_parser.h
    bindings/jsc/html_parser.cc
    bindings/jsc/host_object_internal.cc
    bindings/jsc/host_object_internal.h
    bindings/jsc/host_class.cc
    bindings/jsc/host_class.h
    bindings/jsc/kraken.h
    bindings/jsc/kraken.cc
    bindings/jsc/KOM/blob.cc
    bindings/jsc/KOM/blob.h
    bindings/jsc/KOM/location.cc
    bindings/jsc/KOM/location.h
    bindings/jsc/KOM/history.cc
    bindings/jsc/KOM/history.h
    bindings/jsc/KOM/window.cc
    bindings/jsc/KOM/window.h
    bindings/jsc/KOM/screen.cc
    bindings/jsc/KOM/screen.h
    bindings/jsc/KOM/timer.cc
    bindings/jsc/KOM/timer.h
    bindings/jsc/ui_manager.h
    bindings/jsc/ui_manager.cc
    bindings/jsc/DOM/document.h
    bindings/jsc/DOM/document.cc
    bindings/jsc/DOM/all_collection.cc
    bindings/jsc/DOM/all_collection.h
    bindings/jsc/DOM/elements/anchor_element.cc
    bindings/jsc/DOM/elements/anchor_element.h
    bindings/jsc/DOM/elements/canvas_element.cc
    bindings/jsc/DOM/elements/canvas_element.h
    bindings/jsc/DOM/elements/image_element.cc
    bindings/jsc/DOM/elements/image_element.h
    bindings/jsc/DOM/elements/input_element.cc
    bindings/jsc/DOM/elements/input_element.h
    bindings/jsc/DOM/elements/object_element.cc
    bindings/jsc/DOM/elements/object_element.h
    bindings/jsc/DOM/elements/svg_element.cc
    bindings/jsc/DOM/elements/svg_element.h
    bindings/jsc/DOM/elements/document_fragment.cc
    bindings/jsc/DOM/elements/document_fragment.h
    bindings/jsc/DOM/elements/script_element.cc
    bindings/jsc/DOM/elements/script_element.h
    bindings/jsc/KOM/performance.cc
    bindings/jsc/KOM/performance.h
    bindings/jsc/DOM/element.cc
    bindings/jsc/DOM/element.h
    bindings/jsc/DOM/event.h
    bindings/jsc/DOM/event.cc
    bindings/jsc/DOM/custom_event.h
    bindings/jsc/DOM/events/mouse_event.cc
    bindings/jsc/DOM/events/mouse_event.h
    bindings/jsc/DOM/events/gesture_event.cc
    bindings/jsc/DOM/events/gesture_event.h
    bindings/jsc/DOM/custom_event.cc
    bindings/jsc/DOM/events/input_event.cc
    bindings/jsc/DOM/events/input_event.h
    bindings/jsc/DOM/events/media_error_event.cc
    bindings/jsc/DOM/events/media_error_event.h
    bindings/jsc/DOM/events/message_event.cc
    bindings/jsc/DOM/events/message_event.h
    bindings/jsc/DOM/events/pop_state_event.cc
    bindings/jsc/DOM/events/pop_state_event.h
    bindings/jsc/DOM/events/close_event.cc
    bindings/jsc/DOM/events/close_event.h
    bindings/jsc/DOM/events/intersection_change_event.cc
    bindings/jsc/DOM/events/intersection_change_event.h
    bindings/jsc/DOM/events/touch_event.cc
    bindings/jsc/DOM/events/touch_event.h
    bindings/jsc/DOM/event_target.cc
    bindings/jsc/DOM/event_target.h
    bindings/jsc/DOM/node.cc
    bindings/jsc/DOM/node.h
    bindings/jsc/DOM/text_node.cc
    bindings/jsc/DOM/text_node.h
    bindings/jsc/DOM/comment_node.cc
    bindings/jsc/DOM/comment_node.h
    bindings/jsc/DOM/style_declaration.cc
    bindings/jsc/DOM/style_declaration.h
    bindings/jsc/KOM/console.h
    bindings/jsc/KOM/console.cc
    bindings/jsc/KOM/method_channel.cc
    bindings/jsc/KOM/method_channel.h
    bridge_jsc.cc
    bridge_jsc.h
  )
elseif($ENV{KRAKEN_JS_ENGINE} MATCHES "quickjs")
  add_compile_options(-DKRAKEN_QUICK_JS_ENGINE=1)

  file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/VERSION QUICKJS_VERSION)

  list(APPEND QUICK_JS_SOURCE
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/cutils.c
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/cutils.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libregexp.c
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libregexp.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libregexp-opcode.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libunicode.c
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libunicode.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/libunicode-table.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/list.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/quickjs.c
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/quickjs.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/quickjs-atom.h
          ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/quickjs/quickjs-opcode.h
  )
  add_library(quickjs SHARED ${QUICK_JS_SOURCE})

  target_compile_options(quickjs PUBLIC -DCONFIG_VERSION=${\"QUICKJS_VERSION\"})
endif()

list(APPEND PUBLIC_HEADER
  include/kraken_bridge.h
  )

add_library(kraken SHARED ${BRIDGE_SOURCE})
add_library(kraken_static STATIC ${BRIDGE_SOURCE})

add_library(gumbo_parse_static STATIC ${GUMBO_PAESER})

if (${IS_ANDROID})
  find_library(log-lib log)
  add_definitions(-DIS_ANDROID=1)
  list(APPEND BRIDGE_LINK_LIBS ${log-lib})
endif ()

### Kraken
target_include_directories(kraken PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)
target_link_libraries(kraken PRIVATE ${BRIDGE_LINK_LIBS} gumbo_parse_static)

if (${CMAKE_BUILD_TYPE} STREQUAL "release" OR ${CMAKE_BUILD_TYPE} STREQUAL "relwithdebinfo")
  ## http://ptspts.blogspot.com/2013/12/how-to-make-smaller-c-and-c-binaries.html
  ### remove dynamic_cast and exceptions
  target_compile_options(kraken PRIVATE -fno-exceptions -fvisibility=hidden)
else()
  ### remove dynamic_cast and exceptions
  target_compile_options(kraken PRIVATE -fno-exceptions)
endif()

### KrakenStatic
target_include_directories(kraken_static PRIVATE
        ${BRIDGE_INCLUDE}
        ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)
target_link_libraries(kraken_static ${BRIDGE_LINK_LIBS} gumbo_parse_static)

file(READ ${PROJECT_SOURCE_DIR}/../kraken/pubspec.yaml PUBSPEC)
string(REGEX MATCH "(version: [v0-9.+]+)" _ ${PUBSPEC})
set(APP_VER ${CMAKE_MATCH_1})

string(SUBSTRING ${APP_VER} 9 30 APP_VER)
string(REGEX REPLACE "\n$" "" APP_VER "${APP_VER}")

string(REPLACE \n "" APP_VER ${APP_VER}) # Remove last \n
add_definitions(-DAPP_VERSION="${APP_VER}") # Read from dartfm version
execute_process(
  COMMAND git rev-parse --short HEAD
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
  set_target_properties(kraken_static PROPERTIES OUTPUT_NAME kraken_jsc)
endif()

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken
          PROPERTIES
          LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
          )

  set_target_properties(kraken_static PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}")
elseif (IS_ANDROID)
  # android do nothing
endif()

if (${CMAKE_SYSTEM_NAME} MATCHES "ios")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

  set_target_properties(kraken PROPERTIES
    OUTPUT_NAME kraken_bridge
    FRAMEWORK TRUE
    FRAMEWORK_VERSION C
    MACOSX_FRAMEWORK_IDENTIFIER com.openkraken.kraken_bridge
    PUBLIC_HEADER ${PUBLIC_HEADERS}
    )
endif()
