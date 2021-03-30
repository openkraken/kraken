#add_definitions(-DUSE_SYSTEM_MALLOC=1)
#add_definitions(-DENABLE_DFG_JIT=1)
#add_definitions(-DENABLE_INTL=1)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")#-fno-rtti
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Os -ffunction-sections -fdata-sections -fPIC")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS}")

set(DEVTOOLS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/devtools)

message(${DEBUG_JSC_ENGINE})

list(APPEND DEVTOOL_INCLUDE
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore/include
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/rapidjson-1.1.0/include
)

list(APPEND DEVTOOL_SOURCE
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_console_client_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_console_client_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_agent_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_agent_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_heap_profiler_agent_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_heap_profiler_agent_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_log_agent_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_log_agent_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_page_agent_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_page_agent_impl.h
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_runtime_agent_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/impl/jsc_runtime_agent_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/break_location.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/break_location.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/breakpoint_resolved_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/breakpoint_resolved_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/call_argument.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/call_argument.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/call_frame.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/call_frame.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/debug_dispatcher_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/debug_dispatcher_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/debugger_backend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/debugger_dispatcher_contract.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/debugger_dispatcher_contract.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/debugger_frontend.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/debugger_frontend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/dispatch_response.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/dispatch_response.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/dispatcher_base.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/dispatcher_base.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/domain.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/entry_added_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/entry_added_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/entry_preview.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/entry_preview.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/error_support.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/error_support.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/exception_details.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/exception_details.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/execution_context_created_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/execution_context_created_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/execution_context_description.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/execution_context_description.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/frontend_channel.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_backend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_contract.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_contract.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/inspector_session.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/internal_property_descriptor.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/internal_property_descriptor.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/location.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/location.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_backend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_contract.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_contract.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_entry.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_entry.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_frontend.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/log_frontend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/maybe.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/object_preview.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/object_preview.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/page_backend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_contract.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_contract.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/paused_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/paused_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/private_property_descriptor.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/private_property_descriptor.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/property_descriptor.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/property_descriptor.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/property_preview.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/property_preview.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/remote_object.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/remote_object.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_backend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_contract.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_contract.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_impl.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_frontend.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/runtime_frontend.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/scope.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/scope.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_failed_to_parse_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_failed_to_parse_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_parsed_notification.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_parsed_notification.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_position.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/script_position.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/search_match.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/search_match.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/stacktrace.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/stacktrace.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/stacktrace_id.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/stacktrace_id.h
  ${DEVTOOLS_SOURCE_DIR}/protocol/uber_dispatcher.cc
  ${DEVTOOLS_SOURCE_DIR}/protocol/uber_dispatcher.h
  ${DEVTOOLS_SOURCE_DIR}/service/rpc/object_serializer.h
  ${DEVTOOLS_SOURCE_DIR}/service/rpc/protocol.h
  ${DEVTOOLS_SOURCE_DIR}/service/rpc/session.h
  ${DEVTOOLS_SOURCE_DIR}/frontdoor.h
  ${DEVTOOLS_SOURCE_DIR}/frontdoor.cc
#  ${DEVTOOLS_SOURCE_DIR}/inspector_session_impl.cc
#  ${DEVTOOLS_SOURCE_DIR}/inspector_session_impl.h
  ${DEVTOOLS_SOURCE_DIR}/protocol_handler.h
)

add_library(devtool STATIC ${DEVTOOL_SOURCE})
target_include_directories(devtool PUBLIC ${BRIDGE_INCLUDE} ${DEVTOOL_INCLUDE})
target_link_libraries(devtool ${BRIDGE_LINK_LIBS})
