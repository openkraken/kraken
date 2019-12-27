cmake_minimum_required(VERSION 3.4.1)

include(${KRAKEN_ROOT_DIR}/cmake/Common.cmake)

set(KRAKEN_DEVTOOLS_SOURCE_DIR ${DEVTOOLS_DIR})

add_definitions(-DUSE_SYSTEM_MALLOC=1)
add_definitions(-DENABLE_DFG_JIT=1)
add_definitions(-DENABLE_INTL=1)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")#-fno-rtti
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Os -ffunction-sections -fdata-sections -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CMAKE_C_FLAGS}")

set(DEBUG_INCLUDE_DIRECTORIES
        ${KRAKEN_ROOT_DIR}
        ${KRAKEN_THIRD_PARTY_DIR}
        ${KRAKEN_THIRD_PARTY_DIR}/JavaScriptCore-604.1.13/include
        ${KRAKEN_THIRD_PARTY_DIR}/JavaScriptCore-604.1.13/include/JavaScriptCore
        ${KRAKEN_THIRD_PARTY_DIR}/libfoundation-1.0.0
        ${KRAKEN_THIRD_PARTY_DIR}/rapidjson-1.1.0
        )
set(DEBUG_SOURCES
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/service/rpc/protocol_server.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/chrome_rpc_session.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/chrome_protocol_server.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/dispatch_response.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/uber_dispatcher.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/dispatcher_base.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/error_support.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/debugger_dispatcher_contract.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/debug_dispatcher_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/inspector_session_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_agent_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_debugger_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/frontdoor.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/location.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/script_position.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/remote_object.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/scope.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/call_frame.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/stacktrace_id.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/stacktrace.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/debugger_frontend.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/breakpoint_resolved_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/paused_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/script_failed_to_parse_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/script_parsed_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/break_location.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/call_argument.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/exception_details.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/search_match.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_contract.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/runtime_dispatcher_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/execution_context_description.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/execution_context_created_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/property_descriptor.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/private_property_descriptor.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/internal_property_descriptor.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_runtime_agent_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/entry_preview.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/object_preview.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/property_preview.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_contract.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/page_dispatcher_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_page_agent_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_contract.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/log_dispatcher_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_log_agent_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/entry_added_notification.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/log_entry.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/log_frontend.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/runtime_frontend.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_console_client_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_contract.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_frontend.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/protocol/heap_profiler_dispatcher_impl.cc
        ${KRAKEN_DEVTOOLS_SOURCE_DIR}/impl/jsc_heap_profiler_agent_impl.cc
        )

# set(DEBUG_LINK_LIBS
#         foundation
#         )

add_library(devtools STATIC ${DEBUG_SOURCES})

target_include_directories(devtools PUBLIC ${DEBUG_INCLUDE_DIRECTORIES})
# target_link_libraries(devtools ${DEBUG_LINK_LIBS})
