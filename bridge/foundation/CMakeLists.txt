cmake_minimum_required(VERSION 3.4.1)
add_definitions(-fPIC)

set(FOUNDATION_SOURCES
  logging.cc
  logging.h
  colors.h
  uri.hpp
  bridge_callback.h
  bridge_callback.cc)

add_library(foundation STATIC ${FOUNDATION_SOURCES})

if (${IS_ANDROID})
  find_library(log-lib log)
  target_link_libraries(foundation ${log-lib})

endif ()

target_include_directories(foundation
  PRIVATE
  ${JSA_INCLUDE_DIRS}
  )
