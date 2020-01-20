cmake_minimum_required(VERSION 3.2.0)

# set C++ language version
set(CMAKE_CXX_STANDARD 14)
set(ADDITIONAL_INCLUDE_DIRS)

add_library(jsa_abstraction STATIC
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_context.cc
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_error.cc
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_type.cc
  )
target_include_directories(jsa_abstraction PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include)

if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc")
  add_compile_definitions(KRAKEN_JSC_ENGINE=1)
  add_definitions(-fPIC)
  add_library(jsc_implementation ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/implementation/jsc/jsc_implementation.cc)
  list(APPEND ADDITIONAL_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include/jsc)
  if (${IS_ANDROID})
    add_definitions(-DIS_ANDROID=1)
    list(APPEND ADDITIONAL_INCLUDE_DIRS
      ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore-604.1.13/include
      )
    # jsc预编译库
    add_library(JavaScriptCore SHARED IMPORTED)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
      ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore-604.1.13/lib/android/${ANDROID_ABI}/libjsc.so
      )
    # 链接jsc
    list(APPEND JSA_LINK_LIBS
      JavaScriptCore
      )
  elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    add_definitions(-DIS_LINUX=1)
    list(APPEND ADDITIONAL_INCLUDE_DIRS
      ${CMAKE_CURRENT_SOURCE_DIR}/../third_party/JavaScriptCore-604.1.13/include
      )
    add_library(JavaScriptCore SHARED IMPORTED)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
      /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so
      )
    # 链接jsc
    list(APPEND JSA_LINK_LIBS
      JavaScriptCore
      )
  else ()
    add_definitions(-DIS_MAC=1)
    list(APPEND JSA_LINK_LIBS "-framework JavaScriptCore")
  endif ()

  target_link_libraries(jsc_implementation PRIVATE ${JSA_LINK_LIBS})
  target_include_directories(jsc_implementation PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include
    ${ADDITIONAL_INCLUDE_DIRS}
    )
endif()

