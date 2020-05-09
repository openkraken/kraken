cmake_minimum_required(VERSION 3.4.1)
add_definitions(-fPIC)

set(FOUNDATION_SOURCES
  logging.cc
  thread_utils.cc
  count_down_latch.cc
  time_point.cc
  waitable_event.cc
  colors.h
  thread_safe_stack.h
  flushUITask.h
  flushUITask.cc
  bridge_callback.h
  bridge_callback.cc)

set(FOUNDATION_HEADERS
  logging.h
  thread_utils.h
  count_down_latch.h
  time_point.h
  waitable_event.h
  )

add_library(foundation STATIC ${FOUNDATION_SOURCES})

if (${IS_ANDROID})

  find_library(log-lib log)

  target_link_libraries(foundation ${log-lib})

endif ()

target_include_directories(foundation
  PRIVATE
  ${JSA_INCLUDE_DIRS}
  ${FOUNDATION_INCLUDE_DIRECTORIES}
  )
