cmake_minimum_required(VERSION 3.10.0)
set(CMAKE_OSX_DEPLOYMENT_TARGET 10.11)
project(KrakenBridge)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  execute_process(
    COMMAND bash "-c" "clang --version | xargs | awk '{print $7}' | cut -c1-5"
    OUTPUT_VARIABLE CLANG_ARCH
  )
  ## Set univeral archs for Apple arm64 processors
  if (${CLANG_ARCH} MATCHES "arm64")
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
  endif()
endif()

if (${ENABLE_PROFILE})
  add_definitions(-DENABLE_PROFILE=1)
else ()
  add_definitions(-DENABLE_PROFILE=0)
endif ()

execute_process(
  COMMAND bash "-c" "if [ ! -d \"node_modules\" ]; then npm install; fi"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/code_generator
) # install code_generator deps

execute_process(
  COMMAND bash "-c" "npm run build"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/code_generator
) # g

execute_process(
  COMMAND bash "-c" "node bin/code_generator -s ../../bindings/qjs/dom/elements -d ../../bindings/qjs/dom/elements/.gen"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/code_generator
) # generate elements code

execute_process(
  COMMAND bash "-c" "node bin/code_generator -s ../../bindings/qjs/dom/events -d ../../bindings/qjs/dom/events/.gen"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/code_generator
) # generate events code

execute_process(
  COMMAND bash "-c" "read dart_sdk < <(type -p dart) && echo $\{dart_sdk%/*\}/cache/dart-sdk/include | xargs"
  OUTPUT_VARIABLE DART_SDK
)
string(REGEX REPLACE "\n$" "" DART_SDK "${DART_SDK}")

list(APPEND KRAKEN_PUBLIC_HEADERS
  ${CMAKE_CURRENT_SOURCE_DIR}/include/kraken_bridge.h
)

set(QUICKJS_PUBLIC_HEADERS
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/cutils.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libregexp.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libregexp-opcode.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libunicode.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libunicode-table.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/list.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs-atom.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs-opcode.h
)


if (ENABLE_ASAN)
  add_compile_options(-fsanitize=address -fno-omit-frame-pointer -O1)
  add_link_options(-fsanitize=address -fno-omit-frame-pointer)
endif ()

if (DEFINED PLATFORM)
  if (${PLATFORM} STREQUAL "OS")
    add_compile_options(-fno-aligned-allocation)
  endif()
endif()

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
  foundation/ui_command_buffer.h
  foundation/ui_command_callback_queue.cc
  foundation/closure.h
  dart_methods.cc
  polyfill/dist/polyfill.cc
  )

list(APPEND GUMBO_PARSER
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/attribute.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/attribute.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/char_ref.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/char_ref.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/error.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/error.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/gumbo.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/insertion_mode.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/parser.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/parser.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_buffer.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_buffer.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_piece.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_piece.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tag_enum.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tag_gperf.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tag_sizes.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tag_strings.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tag.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_piece.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/string_piece.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/token_type.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tokenizer_states.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tokenizer.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/tokenizer.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/utf8.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/utf8.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/util.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/util.h
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/vector.c
  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/gumbo-parser/src/vector.h
  )

list(APPEND BRIDGE_INCLUDE
  ${CMAKE_CURRENT_LIST_DIR}/foundation
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_CURRENT_LIST_DIR}/include
  ${CMAKE_CURRENT_LIST_DIR}/polyfill/dist
  ${DART_SDK}
  ${ADDITIONAL_INCLUDE_DIRS}
  )

set(BINDING_DIR ${CMAKE_CURRENT_LIST_DIR}/bindings)

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "quickjs")
  add_compile_options(-DKRAKEN_QUICK_JS_ENGINE=1)

  execute_process(
    COMMAND cat ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/VERSION
    OUTPUT_VARIABLE QUICKJS_VERSION
  )

  list(APPEND QUICK_JS_SOURCE
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/cutils.c
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/cutils.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libregexp.c
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libregexp.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libregexp-opcode.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libunicode.c
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libunicode.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/libunicode-table.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/list.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs.c
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs-atom.h
    ${CMAKE_CURRENT_SOURCE_DIR}/third_party/quickjs/quickjs-opcode.h
    )
  if(${STATIC_QUICKJS})
    add_library(quickjs STATIC ${QUICK_JS_SOURCE})
  else()
    add_library(quickjs SHARED ${QUICK_JS_SOURCE})
  endif()

  list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/third_party)
  list(APPEND BRIDGE_LINK_LIBS quickjs)

  list(APPEND BRIDGE_SOURCE
    page.cc
    page.h
    bindings/qjs/garbage_collected.h
    bindings/qjs/executing_context.cc
    bindings/qjs/executing_context.h
    bindings/qjs/heap_hashmap.h
    bindings/qjs/native_value.cc
    bindings/qjs/native_value.h
    bindings/qjs/host_object.h
    bindings/qjs/host_object.cc
    bindings/qjs/host_class.h
    bindings/qjs/qjs_patch.cc
    bindings/qjs/qjs_patch.h
    bindings/qjs/module_manager.cc
    bindings/qjs/module_manager.h
    bindings/qjs/html_parser.cc
    bindings/qjs/html_parser.h
    bindings/qjs/bom/console.cc
    bindings/qjs/bom/console.h
    bindings/qjs/bom/screen.cc
    bindings/qjs/bom/screen.h
    bindings/qjs/bom/timer.cc
    bindings/qjs/bom/timer.h
    bindings/qjs/bom/dom_timer_coordinator.cc
    bindings/qjs/bom/dom_timer_coordinator.h
    bindings/qjs/dom/frame_request_callback_collection.cc
    bindings/qjs/dom/frame_request_callback_collection.h
    bindings/qjs/dom/event_listener_map.cc
    bindings/qjs/dom/event_listener_map.h
    bindings/qjs/dom/script_animation_controller.cc
    bindings/qjs/dom/script_animation_controller.h
    bindings/qjs/dom/event_target.cc
    bindings/qjs/dom/event_target.h
    bindings/qjs/dom/event.cc
    bindings/qjs/dom/event.h
    bindings/qjs/dom/node.h
    bindings/qjs/dom/node.cc
    bindings/qjs/dom/element.cc
    bindings/qjs/dom/element.h
    bindings/qjs/dom/document.cc
    bindings/qjs/dom/document.h
    bindings/qjs/dom/text_node.cc
    bindings/qjs/dom/text_node.h
    bindings/qjs/dom/comment_node.cc
    bindings/qjs/dom/comment_node.h
    bindings/qjs/dom/document_fragment.cc
    bindings/qjs/dom/document_fragment.h
    bindings/qjs/dom/style_declaration.cc
    bindings/qjs/dom/style_declaration.h
    bindings/qjs/dom/elements/.gen/canvas_element.cc
    bindings/qjs/dom/elements/.gen/canvas_element.h
    bindings/qjs/dom/elements/image_element.cc
    bindings/qjs/dom/elements/image_element.h
    bindings/qjs/dom/elements/.gen/input_element.cc
    bindings/qjs/dom/elements/.gen/input_element.h
    bindings/qjs/dom/elements/.gen/anchor_element.cc
    bindings/qjs/dom/elements/.gen/anchor_element.h
    bindings/qjs/dom/elements/.gen/object_element.cc
    bindings/qjs/dom/elements/.gen/object_element.h
    bindings/qjs/dom/elements/.gen/script_element.cc
    bindings/qjs/dom/elements/.gen/script_element.h
    bindings/qjs/dom/elements/template_element.cc
    bindings/qjs/dom/elements/template_element.h
    bindings/qjs/dom/events/.gen/close_event.h
    bindings/qjs/dom/events/.gen/close_event.cc
    bindings/qjs/dom/events/.gen/gesture_event.cc
    bindings/qjs/dom/events/.gen/gesture_event.h
    bindings/qjs/dom/events/.gen/input_event.cc
    bindings/qjs/dom/events/.gen/input_event.h
    bindings/qjs/dom/events/.gen/popstate_event.cc
    bindings/qjs/dom/events/.gen/popstate_event.h
    bindings/qjs/dom/events/.gen/intersection_change.cc
    bindings/qjs/dom/events/.gen/intersection_change.h
    bindings/qjs/dom/events/.gen/media_error_event.cc
    bindings/qjs/dom/events/.gen/media_error_event.h
    bindings/qjs/dom/events/.gen/mouse_event.cc
    bindings/qjs/dom/events/.gen/mouse_event.h
    bindings/qjs/dom/events/.gen/message_event.h
    bindings/qjs/dom/events/.gen/message_event.cc
    bindings/qjs/dom/events/touch_event.cc
    bindings/qjs/dom/events/touch_event.h
    bindings/qjs/bom/blob.cc
    bindings/qjs/bom/blob.h
    bindings/qjs/bom/location.h
    bindings/qjs/bom/location.cc
    bindings/qjs/bom/window.cc
    bindings/qjs/bom/window.h
    bindings/qjs/bom/performance.cc
    bindings/qjs/bom/performance.h
    bindings/qjs/dom/custom_event.cc
    bindings/qjs/dom/custom_event.h
    bindings/qjs/dom/all_collection.cc
    bindings/qjs/dom/all_collection.h
    )

  # Quickjs use __builtin_frame_address() to get stack pointer, we should add follow options to get it work with -O2
  # https://stackoverflow.com/questions/14735010/how-do-you-get-gccs-builtin-frame-address-to-work-with-o2
  add_compile_options(-fno-optimize-sibling-calls -fno-omit-frame-pointer)
  target_compile_options(quickjs PUBLIC -DCONFIG_VERSION=${\"QUICKJS_VERSION\"})

endif ()

list(APPEND PUBLIC_HEADER
  include/kraken_bridge.h
  )

add_library(kraken SHARED ${BRIDGE_SOURCE})
add_library(kraken_static STATIC ${BRIDGE_SOURCE})

target_compile_definitions(kraken PUBLIC -DFLUTTER_BACKEND=1)

add_library(gumbo_parse_static STATIC ${GUMBO_PARSER})
list(APPEND BRIDGE_LINK_LIBS gumbo_parse_static)

if (${IS_ANDROID})
  find_library(log-lib log)
  add_definitions(-DIS_ANDROID=1)
  list(APPEND BRIDGE_LINK_LIBS ${log-lib})
endif ()

### Kraken
target_include_directories(kraken PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)
target_link_libraries(kraken PRIVATE ${BRIDGE_LINK_LIBS})

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "quickjs")
  if (${CMAKE_BUILD_TYPE} STREQUAL "Release" OR ${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo")
    target_compile_options(kraken PRIVATE -fno-exceptions -fvisibility=hidden -fno-rtti)
  else ()
    ### remove dynamic_cast and exceptions
    target_compile_options(kraken PRIVATE -fno-exceptions -fno-rtti)
  endif ()
endif ()

### KrakenStatic
target_include_directories(kraken_static PRIVATE
  ${BRIDGE_INCLUDE}
  ${CMAKE_CURRENT_SOURCE_DIR} PUBLIC ./include)
target_link_libraries(kraken_static ${BRIDGE_LINK_LIBS})

execute_process(
  COMMAND grep version: ./pubspec.yaml
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../kraken
  OUTPUT_VARIABLE APP_VER
)
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

if (DEFINED ENV{LIBRARY_OUTPUT_DIR})
  set_target_properties(kraken
    PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}"
    )
  set_target_properties(kraken_static PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}")

  if ($ENV{KRAKEN_JS_ENGINE} MATCHES "quickjs")
    set_target_properties(quickjs PROPERTIES LIBRARY_OUTPUT_DIRECTORY "$ENV{LIBRARY_OUTPUT_DIR}")
  endif ()
elseif (IS_ANDROID)
  # android do nothing
endif ()

if (${CMAKE_SYSTEM_NAME} MATCHES "iOS")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
  set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "")

  set_target_properties(kraken PROPERTIES
    OUTPUT_NAME kraken_bridge
    FRAMEWORK TRUE
    FRAMEWORK_VERSION C
    MACOSX_FRAMEWORK_IDENTIFIER com.openkraken.kraken-bridge
    PUBLIC_HEADER ${KRAKEN_PUBLIC_HEADERS}
    )

  # If quickjs is static, there will be no quickjs.framework any more.
  if(NOT ${STATIC_QUICKJS})
    set_target_properties(quickjs PROPERTIES
      OUTPUT_NAME quickjs
      FRAMEWORK TRUE
      FRAMEWORK_VERSION C
      MACOSX_FRAMEWORK_IDENTIFIER com.openkraken.quickjs
      PUBLIC_HEADER ${QUICKJS_PUBLIC_HEADERS}
      )
  endif()
endif ()
