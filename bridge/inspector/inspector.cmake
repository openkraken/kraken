#add_definitions(-DUSE_SYSTEM_MALLOC=1)
#add_definitions(-DENABLE_DFG_JIT=1)
#add_definitions(-DENABLE_INTL=1)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")#-fno-rtti
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Os -ffunction-sections -fdata-sections -fPIC")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS}")

set(INSPECTOR_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/inspector)

message(${DEBUG_JSC_ENGINE})

list(APPEND INSPECTOR_INCLUDE
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore/include
  ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/rapidjson-1.1.0/include
)

list(APPEND INSPECTOR_SOURCE
  ${INSPECTOR_SOURCE_DIR}/frontdoor.h
  ${INSPECTOR_SOURCE_DIR}/frontdoor.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_console_client_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_console_client_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_debugger_agent_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_debugger_agent_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_debugger_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_debugger_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_heap_profiler_agent_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_heap_profiler_agent_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_log_agent_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_log_agent_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_page_agent_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_page_agent_impl.h
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_runtime_agent_impl.cc
  ${INSPECTOR_SOURCE_DIR}/impl/jsc_runtime_agent_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/break_location.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/break_location.h
  ${INSPECTOR_SOURCE_DIR}/protocol/breakpoint_resolved_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/breakpoint_resolved_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/call_argument.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/call_argument.h
  ${INSPECTOR_SOURCE_DIR}/protocol/call_frame.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/call_frame.h
  ${INSPECTOR_SOURCE_DIR}/protocol/debug_dispatcher_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/debug_dispatcher_impl.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/debugger_backend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/debugger_dispatcher_contract.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/debugger_dispatcher_contract.h
  ${INSPECTOR_SOURCE_DIR}/protocol/debugger_frontend.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/debugger_frontend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/dispatch_response.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/dispatch_response.h
  ${INSPECTOR_SOURCE_DIR}/protocol/dispatcher_base.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/dispatcher_base.h
  ${INSPECTOR_SOURCE_DIR}/protocol/domain.h
  ${INSPECTOR_SOURCE_DIR}/protocol/entry_added_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/entry_added_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/entry_preview.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/entry_preview.h
  ${INSPECTOR_SOURCE_DIR}/protocol/error_support.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/error_support.h
  ${INSPECTOR_SOURCE_DIR}/protocol/exception_details.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/exception_details.h
  ${INSPECTOR_SOURCE_DIR}/protocol/execution_context_created_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/execution_context_created_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/execution_context_description.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/execution_context_description.h
  ${INSPECTOR_SOURCE_DIR}/protocol/frontend_channel.h
  ${INSPECTOR_SOURCE_DIR}/protocol/heap_profiler_backend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/heap_profiler_dispatcher_contract.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/heap_profiler_dispatcher_contract.h
  ${INSPECTOR_SOURCE_DIR}/protocol/heap_profiler_dispatcher_impl.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/heap_profiler_dispatcher_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/internal_property_descriptor.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/internal_property_descriptor.h
  ${INSPECTOR_SOURCE_DIR}/protocol/location.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/location.h
  ${INSPECTOR_SOURCE_DIR}/protocol/log_backend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/log_dispatcher_contract.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/log_dispatcher_contract.h
  ${INSPECTOR_SOURCE_DIR}/protocol/log_dispatcher_impl.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/log_dispatcher_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/log_entry.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/log_entry.h
  ${INSPECTOR_SOURCE_DIR}/protocol/log_frontend.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/log_frontend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/maybe.h
  ${INSPECTOR_SOURCE_DIR}/protocol/object_preview.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/object_preview.h
  ${INSPECTOR_SOURCE_DIR}/protocol/page_backend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/page_dispatcher_contract.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/page_dispatcher_contract.h
  ${INSPECTOR_SOURCE_DIR}/protocol/page_dispatcher_impl.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/page_dispatcher_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/paused_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/paused_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/private_property_descriptor.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/private_property_descriptor.h
  ${INSPECTOR_SOURCE_DIR}/protocol/property_descriptor.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/property_descriptor.h
  ${INSPECTOR_SOURCE_DIR}/protocol/property_preview.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/property_preview.h
  ${INSPECTOR_SOURCE_DIR}/protocol/remote_object.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/remote_object.h
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_backend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_dispatcher_contract.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_dispatcher_contract.h
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_dispatcher_impl.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_dispatcher_impl.h
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_frontend.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/runtime_frontend.h
  ${INSPECTOR_SOURCE_DIR}/protocol/scope.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/scope.h
  ${INSPECTOR_SOURCE_DIR}/protocol/script_failed_to_parse_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/script_failed_to_parse_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/script_parsed_notification.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/script_parsed_notification.h
  ${INSPECTOR_SOURCE_DIR}/protocol/script_position.h
  ${INSPECTOR_SOURCE_DIR}/protocol/script_position.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/search_match.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/search_match.h
  ${INSPECTOR_SOURCE_DIR}/protocol/stacktrace.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/stacktrace.h
  ${INSPECTOR_SOURCE_DIR}/protocol/stacktrace_id.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/stacktrace_id.h
  ${INSPECTOR_SOURCE_DIR}/protocol/uber_dispatcher.cc
  ${INSPECTOR_SOURCE_DIR}/protocol/uber_dispatcher.h
  ${INSPECTOR_SOURCE_DIR}/service/rpc/object_serializer.h
  ${INSPECTOR_SOURCE_DIR}/service/rpc/protocol.h
  ${INSPECTOR_SOURCE_DIR}/inspector_session.cc
  ${INSPECTOR_SOURCE_DIR}/inspector_session.h
  ${INSPECTOR_SOURCE_DIR}/protocol_handler.h
  ${INSPECTOR_SOURCE_DIR}/rpc_session.h
  ${INSPECTOR_SOURCE_DIR}/rpc_session.cc
)

add_library(inspector STATIC ${INSPECTOR_SOURCE})
target_include_directories(inspector PUBLIC ${BRIDGE_INCLUDE} ${INSPECTOR_INCLUDE})
target_link_libraries(inspector ${BRIDGE_LINK_LIBS})
