cmake_minimum_required(VERSION 3.2.0)

# set C++ language version
set(CMAKE_CXX_STANDARD 14)
set(JSA_INCLUDE_DIRS)
add_definitions(-fPIC)
list(APPEND JSA_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include)

add_library(jsa_abstraction STATIC
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_context.cc
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_error.cc
  ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/abstraction/js_type.cc
)
target_include_directories(jsa_abstraction PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include)

### JSC implementations
if ($ENV{KRAKEN_JS_ENGINE} MATCHES "jsc" OR $ENV{KRAKEN_JS_ENGINE} MATCHES "all")
  add_compile_options(-DKRAKEN_JSC_ENGINE=1)
  list(APPEND JSA_IMPLEMENTATION ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/implementation/jsc/jsc_implementation.cc)
  list(APPEND JSA_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include/jsc)

  if (${IS_ANDROID})
    list(APPEND JSA_INCLUDE_DIRS
            ${CMAKE_CURRENT_SOURCE_DIR}/third_party/JavaScriptCore-604.1.13/include
            )
    # jsc预编译库
    add_library(JavaScriptCore SHARED IMPORTED)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/JavaScriptCore-604.1.13/lib/android/${ANDROID_ABI}/libjsc.so"
            )
    # 链接jsc
    list(APPEND JSA_LINK_LIBS
            JavaScriptCore
            )
  elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    list(APPEND JSA_INCLUDE_DIRS
            ${CMAKE_CURRENT_SOURCE_DIR}/third_party/JavaScriptCore-604.1.13/include
            )
    add_library(JavaScriptCore SHARED IMPORTED include/v8/v8_implementation.h)
    set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
            /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so
            )
    # 链接jsc
    list(APPEND JSA_LINK_LIBS
            JavaScriptCore
            )
  else ()
    list(APPEND JSA_LINK_LIBS "-framework JavaScriptCore")
  endif ()

endif()

if($ENV{KRAKEN_JS_ENGINE} MATCHES "v8" OR $ENV{KRAKEN_JS_ENGINE} MATCHES "all")
  ### V8 Implementations
  add_compile_options(-DKRAKEN_V8_ENGINE=1)
  list(APPEND JSA_IMPLEMENTATION
          ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/implementation/v8/v8_implementation.cc
          ${CMAKE_CURRENT_SOURCE_DIR}/jsa/src/implementation/v8/v8_instrumentation.cc)
  list(APPEND JSA_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/jsa/include/v8)

  if (${IS_ANDROID})
    ## TODO implementation android v8 build
  elseif (${CMAKE_SYSTEM_NAME} STREQUAL "Linux" AND ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    ## TODO implementation linux v8
  else ()
    list(APPEND JSA_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/include)
    add_library(v8 SHARED IMPORTED)
    set_target_properties(v8 PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/lib/macos/libv8.dylib"
            )
    add_library(v8_base SHARED IMPORTED)
    set_target_properties(v8_base PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/lib/macos/libv8_libbase.dylib"
            )
    add_library(v8_platform SHARED IMPORTED)
    set_target_properties(v8_platform PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/lib/macos/libv8_libplatform.dylib"
            )
    add_library(v8_icui18n SHARED IMPORTED)
    set_target_properties(v8_icui18n PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/lib/macos/libicui18n.dylib"
            )
    add_library(v8_icuuc SHARED IMPORTED)
    set_target_properties(v8_icuuc PROPERTIES IMPORTED_LOCATION
            "${CMAKE_CURRENT_SOURCE_DIR}/third_party/v8-7.9.317.31/lib/macos/libicuuc.dylib"
            )

    # linking jsc
    list(APPEND JSA_LINK_LIBS v8 v8_base v8_platform v8_icui18n v8_icuuc)
  endif ()
endif()

add_library(jsa_implementation ${JSA_IMPLEMENTATION})
target_link_libraries(jsa_implementation PRIVATE ${JSA_LINK_LIBS})
target_include_directories(jsa_implementation PRIVATE
        ${JSA_INCLUDE_DIRS}
        )
