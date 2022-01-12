cmake_minimum_required(VERSION 3.10.0)
project(kraken_devtools)

find_package(kraken)

add_library(kraken_devtools SHARED
  kraken_devtools.cc
  kraken_devtools.h
  dart_methods.cc
  dart_methods.h
  inspector/frontdoor.cc
  inspector/frontdoor.h
  inspector/inspector_session.cc
  inspector/inspector_session.h
  inspector/protocol_handler.h
  inspector/rpc_session.cc
  inspector/rpc_session.h
  inspector/impl/jsc_console_client_impl.cc
  inspector/impl/jsc_console_client_impl.h
  inspector/impl/jsc_debugger_agent_impl.cc
  inspector/impl/jsc_debugger_agent_impl.h
  inspector/impl/jsc_debugger_impl.cc
  inspector/impl/jsc_debugger_impl.h
  inspector/impl/jsc_heap_profiler_agent_impl.cc
  inspector/impl/jsc_heap_profiler_agent_impl.h
  inspector/impl/jsc_log_agent_impl.cc
  inspector/impl/jsc_log_agent_impl.h
  inspector/impl/jsc_page_agent_impl.cc
  inspector/impl/jsc_page_agent_impl.h
  inspector/impl/jsc_runtime_agent_impl.cc
  inspector/impl/jsc_runtime_agent_impl.h
  inspector/protocol/break_location.cc
  inspector/protocol/break_location.h
  inspector/protocol/breakpoint_resolved_notification.cc
  inspector/protocol/breakpoint_resolved_notification.h
  inspector/protocol/call_argument.cc
  inspector/protocol/call_argument.h
  inspector/protocol/call_frame.cc
  inspector/protocol/call_frame.h
  inspector/protocol/debug_dispatcher_impl.cc
  inspector/protocol/debug_dispatcher_impl.h
  inspector/protocol/debugger_backend.h
  inspector/protocol/debugger_dispatcher_contract.cc
  inspector/protocol/debugger_dispatcher_contract.h
  inspector/protocol/debugger_frontend.cc
  inspector/protocol/debugger_frontend.h
  inspector/protocol/dispatch_response.cc
  inspector/protocol/dispatch_response.h
  inspector/protocol/dispatcher_base.cc
  inspector/protocol/dispatcher_base.h
  inspector/protocol/domain.h
  inspector/protocol/entry_added_notification.cc
  inspector/protocol/entry_added_notification.h
  inspector/protocol/entry_preview.cc
  inspector/protocol/entry_preview.h
  inspector/protocol/error_support.cc
  inspector/protocol/error_support.h
  inspector/protocol/exception_details.cc
  inspector/protocol/exception_details.h
  inspector/protocol/execution_context_created_notification.cc
  inspector/protocol/execution_context_created_notification.h
  inspector/protocol/execution_context_description.cc
  inspector/protocol/execution_context_description.h
  inspector/protocol/frontend_channel.h
  inspector/protocol/heap_profiler_backend.h
  inspector/protocol/heap_profiler_dispatcher_contract.cc
  inspector/protocol/heap_profiler_dispatcher_contract.h
  inspector/protocol/heap_profiler_dispatcher_impl.cc
  inspector/protocol/heap_profiler_dispatcher_impl.h
  inspector/protocol/internal_property_descriptor.cc
  inspector/protocol/internal_property_descriptor.h
  inspector/protocol/location.cc
  inspector/protocol/location.h
  inspector/protocol/log_backend.h
  inspector/protocol/log_dispatcher_contract.cc
  inspector/protocol/log_dispatcher_contract.h
  inspector/protocol/log_dispatcher_impl.cc
  inspector/protocol/log_dispatcher_impl.h
  inspector/protocol/log_entry.cc
  inspector/protocol/log_entry.h
  inspector/protocol/log_frontend.cc
  inspector/protocol/log_frontend.h
  inspector/protocol/maybe.h
  inspector/protocol/object_preview.cc
  inspector/protocol/object_preview.h
  inspector/protocol/page_backend.h
  inspector/protocol/page_dispatcher_contract.cc
  inspector/protocol/page_dispatcher_contract.h
  inspector/protocol/page_dispatcher_impl.cc
  inspector/protocol/page_dispatcher_impl.h
  inspector/protocol/paused_notification.cc
  inspector/protocol/paused_notification.h
  inspector/protocol/private_property_descriptor.cc
  inspector/protocol/private_property_descriptor.h
  inspector/protocol/property_descriptor.cc
  inspector/protocol/property_descriptor.h
  inspector/protocol/property_preview.cc
  inspector/protocol/property_preview.h
  inspector/protocol/remote_object.cc
  inspector/protocol/remote_object.h
  inspector/protocol/runtime_backend.h
  inspector/protocol/runtime_dispatcher_contract.cc
  inspector/protocol/runtime_dispatcher_contract.h
  inspector/protocol/runtime_dispatcher_impl.cc
  inspector/protocol/runtime_dispatcher_impl.h
  inspector/protocol/runtime_frontend.cc
  inspector/protocol/runtime_frontend.h
  inspector/protocol/scope.cc
  inspector/protocol/scope.h
  inspector/protocol/script_failed_to_parse_notification.cc
  inspector/protocol/script_failed_to_parse_notification.h
  inspector/protocol/script_parsed_notification.cc
  inspector/protocol/script_parsed_notification.h
  inspector/protocol/script_position.cc
  inspector/protocol/script_position.h
  inspector/protocol/search_match.cc
  inspector/protocol/search_match.h
  inspector/protocol/stacktrace.cc
  inspector/protocol/stacktrace.h
  inspector/protocol/stacktrace_id.cc
  inspector/protocol/stacktrace_id.h
  inspector/protocol/uber_dispatcher.cc
  inspector/protocol/uber_dispatcher.h
  inspector/service/rpc/object_serializer.h
  inspector/service/rpc/protocol.h
)

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  set_target_properties(kraken_devtools PROPERTIES OUTPUT_NAME kraken_devtools_jsc)
endif()

list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR})
list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/third_party/rapidjson-1.1.0/include)
list(APPEND BRIDGE_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/kraken/include)
target_link_libraries(kraken_devtools ${BRIDGE_LINK_LIBS} kraken)
target_include_directories(kraken_devtools PUBLIC ${BRIDGE_INCLUDE})
target_compile_definitions(kraken_devtools PUBLIC RAPIDJSON_HAS_STDSTRING=1)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set_target_properties(kraken_devtools PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../macos"
          )
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Android")
  set_target_properties(kraken_devtools PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../android/jniLibs/${ANDROID_ABI}/"
  )
endif ()
