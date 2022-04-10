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
  COMMAND bash "-c" "node bin/code_generator -s ../../core -d ../../out"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/scripts/code_generator
) # generate elements code

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

if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
  add_compile_options(-fPIC)
endif()

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
  foundation/macros.h
  foundation/logging.cc
  foundation/logging.h
  foundation/colors.h
  foundation/native_string.cc
  foundation/native_string.h
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
  foundation/native_value.cc
  foundation/native_value.h
  foundation/casting.h
  foundation/ui_command_buffer.cc
  foundation/ui_command_buffer.h
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
  ${CMAKE_CURRENT_LIST_DIR}/out
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
    # Binding files
    bindings/qjs/idl_type.h
    bindings/qjs/converter.h
    bindings/qjs/converter_impl.h
    bindings/qjs/dictionary_base.cc
    bindings/qjs/dictionary_base.h
    bindings/qjs/js_based_event_listener.cc
    bindings/qjs/js_based_event_listener.h
    bindings/qjs/js_event_handler.cc
    bindings/qjs/js_event_handler.h
    bindings/qjs/js_event_listener.cc
    bindings/qjs/js_event_listener.h
    bindings/qjs/binding_initializer.cc
    bindings/qjs/binding_initializer.h
    bindings/qjs/member_installer.cc
    bindings/qjs/member_installer.h
    bindings/qjs/source_location.cc
    bindings/qjs/source_location.h
    bindings/qjs/garbage_collected.h
    bindings/qjs/script_wrappable.cc
    bindings/qjs/script_wrappable.h
    bindings/qjs/wrapper_type_info.h
    bindings/qjs/heap_hashmap.h
    bindings/qjs/native_string_utils.cc
    bindings/qjs/native_string_utils.h
    bindings/qjs/qjs_engine_patch.cc
    bindings/qjs/qjs_engine_patch.h
    bindings/qjs/qjs_function.cc
    bindings/qjs/qjs_function.h
    bindings/qjs/script_value.cc
    bindings/qjs/script_value.h
    bindings/qjs/script_promise.cc
    bindings/qjs/script_promise.h
    bindings/qjs/to_quickjs.h
    bindings/qjs/qjs_interface_bridge.cc
    bindings/qjs/qjs_interface_bridge.h
    bindings/qjs/script_promise_resolver.cc
    bindings/qjs/script_promise_resolver.h
    bindings/qjs/atomic_string.cc
    bindings/qjs/atomic_string.h
    bindings/qjs/generated_code_helper.h
    bindings/qjs/exception_state.cc
    bindings/qjs/exception_state.h
    bindings/qjs/gc_visitor.cc
    bindings/qjs/gc_visitor.h
    bindings/qjs/rejected_promises.h
    bindings/qjs/rejected_promises.cc
    bindings/qjs/pending_promises.cc
    bindings/qjs/pending_promises.h
    bindings/qjs/qjs_window.cc
    bindings/qjs/qjs_window.h
    bindings/qjs/qjs_page.cc
    bindings/qjs/qjs_page.h

    # Core sources
    core/executing_context.cc
    core/executing_context.h
    core/script_state.cc
    core/script_state.h
    core/page.h
    core/page.cc
    core/executing_context_data.cc
    core/executing_context_data.h
    core/dart_methods.h
    core/fileapi/blob.h
    core/fileapi/blob.cc
    core/fileapi/blob_part.cc
    core/fileapi/blob_part.h
    core/fileapi/blob_property_bag.cc
    core/fileapi/blob_property_bag.h
    core/frame/console.cc
    core/frame/console.h
    core/frame/dom_timer.cc
    core/frame/dom_timer.h
    core/frame/dom_timer_coordinator.cc
    core/frame/dom_timer_coordinator.h
    core/frame/window_or_worker_global_scope.cc
    core/frame/window_or_worker_global_scope.h
    core/frame/module_listener.cc
    core/frame/module_listener.h
    core/frame/module_listener_container.cc
    core/frame/module_listener_container.h
    core/frame/module_manager.cc
    core/frame/module_manager.h
    core/frame/module_callback.cc
    core/frame/module_callback.h
    core/frame/module_callback_coordinator.cc
    core/frame/module_callback_coordinator.h
    core/dom/frame_request_callback_collection.cc
    core/dom/frame_request_callback_collection.h
    core/dom/events/event_listener.h
    core/dom/events/registered_eventListener.cc
    core/dom/events/registered_eventListener.h
    core/dom/events/event_listener_map.cc
    core/dom/events/event_listener_map.h
    core/dom/events/event.h
    core/dom/events/event.cc
    core/dom/events/event_target.h
    core/dom/events/event_target.cc
    core/dom/events/event_listener_map.cc
    core/dom/events/event_target_impl.cc
    core/dom/events/event_target_impl.h
    core/dom/node.cc
    core/dom/node.h
    core/dom/attr.cc
    core/dom/attr.h
    core/dom/node_traversal.cc
    core/dom/node_traversal.h
    core/dom/template_content_document_fragment.h
    core/dom/character_data.cc
    core/dom/character_data.h
    core/dom/text.cc
    core/dom/text.h
    core/dom/attribute.h
    core/dom/attribute_collection.h
    core/dom/tree_scope.cc
    core/dom/tree_scope.h
    core/dom/element.cc
    core/dom/element.h
    core/dom/element_data.cc
    core/dom/element_data.h
    core/dom/space_split_string.cc
    core/dom/space_split_string.h
    core/dom/document.cc
    core/dom/document.h
    core/dom/node_data.cc
    core/dom/node_data.h
    core/dom/document_fragment.h
    core/dom/document_fragment.cc
    core/dom/collection_index_cache.h
    core/dom/child_node_list.cc
    core/dom/child_node_list.h
    core/dom/empty_node_list.cc
    core/dom/empty_node_list.h
    core/dom/node_list.h
    core/dom/container_node.cc
    core/dom/container_node.h
    core/events/error_event.cc
    core/events/error_event.h
    core/html/html_collection.cc
    core/html/html_collection.h
    core/html/html_element.cc
    core/html/html_element.h
#    core/dom/character_data.cc
#    core/dom/character_data.h
#    core/dom/comment.cc
#    core/dom/comment.h
#    core/dom/node.cc
#    core/dom/node.h
#    core/dom/events/custom_event.cc
#    core/dom/events/custom_event.h
#    core/dom/events/event.h
#    core/dom/events/event.cc
#    core/dom/events/event_listener_map.cc
#    core/dom/events/event_listener_map.h
#    core/dom/events/event_target.cc
#    core/dom/events/event_target.h
    )

  # Gen sources.
  list(APPEND BRIDGE_SOURCE
    out/qjs_console.cc
    out/qjs_console.h
    out/qjs_module_manager.cc
    out/qjs_module_manager.h
    out/qjs_blob.cc
    out/qjs_blob.h
    out/qjs_event.cc
    out/qjs_event.h
    out/qjs_add_event_listener_options.cc
    out/qjs_add_event_listener_options.h
    out/qjs_event_listener_options.cc
    out/qjs_event_listener_options.h
    out/qjs_error_event.h
    out/qjs_error_event.cc
    out/qjs_error_event_init.h
    out/qjs_error_event_init.cc
    out/qjs_event_init.h
    out/qjs_event_init.cc
    out/qjs_event_target.cc
    out/qjs_event_target.h
    out/qjs_node.h
    out/qjs_node.cc
    out/event_type_names.h
    out/event_type_names.cc
    out/built_in_string.cc
    out/built_in_string.h
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

  if (${ANDROID_ABI} MATCHES "armeabi-v7a" OR ${ANDROID_ABI} MATCHES "x86")
    add_definitions(-DANDROID_32_BIT=1)
  endif()

  add_definitions(-DIS_ANDROID=1)
  list(APPEND BRIDGE_LINK_LIBS ${log-lib})
elseif(${IS_IOS})
  add_definitions(-DIS_IOS=1)
endif()

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
    MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0
    MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0
    PUBLIC_HEADER ${KRAKEN_PUBLIC_HEADERS}
    )

  # If quickjs is static, there will be no quickjs.framework any more.
  if(NOT DEFINED STATIC_QUICKJS)
    set_target_properties(quickjs PROPERTIES
      OUTPUT_NAME quickjs
      FRAMEWORK TRUE
      FRAMEWORK_VERSION C
      MACOSX_FRAMEWORK_IDENTIFIER com.openkraken.quickjs
      MACOSX_FRAMEWORK_BUNDLE_VERSION 1.0
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING 1.0
      PUBLIC_HEADER ${QUICKJS_PUBLIC_HEADERS}
      )
  endif()
endif ()
