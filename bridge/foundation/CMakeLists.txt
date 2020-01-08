cmake_minimum_required(VERSION 3.4.1)
add_definitions(-DASIO_NO_TYPEID)
add_definitions(-fPIC)
add_definitions(-DASIO_STANDALONE) # 不想引入boost.system

set(FOUNDATION_SOURCES
  logging.cc
  websocket_client.cc
  websocket_server.cc
  thread_utils.cc
  count_down_latch.cc
  time_point.cc
  waitable_event.cc
  )

set(FOUNDATION_HEADERS
  logging.h
  websocket_client.h
  websocket_server.h
  thread_utils.h
  count_down_latch.h
  time_point.h
  waitable_event.h
  )

set(FOUNDATION_INCLUDE_DIRECTORIES
  websockettpp-0.8.1
  asio-1.12.1/include
  )

add_library(foundation STATIC ${FOUNDATION_SOURCES})

if (${IS_ANDROID})

  find_library(log-lib log)

  target_link_libraries(foundation ${log-lib})

endif ()

target_include_directories(foundation
  PRIVATE
  ${FOUNDATION_INCLUDE_DIRECTORIES}
  )
