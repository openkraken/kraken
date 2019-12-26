set(JSA_LINK_LIBS)
set(ADDITIONAL_INCLUDE_DIRS)

set(HEADER_FILES
  jsc_context.h
  )

set(SOURCE_FILES
  jsc_context.cc
  )

if (${IS_ANDROID})
  add_definitions(-DIS_ANDROID=1)
  list(APPEND ADDITIONAL_INCLUDE_DIRS
    ./jsc/include
    )
  # jsc预编译库
  add_library(JavaScriptCore SHARED IMPORTED)
  set_target_properties(JavaScriptCore PROPERTIES IMPORTED_LOCATION
    ${CMAKE_CURRENT_SOURCE_DIR}/jsc/lib/android/${ANDROID_ABI}/libjsc.so
    )
  # 链接jsc
  list(APPEND JSA_LINK_LIBS
    JavaScriptCore
    )
elseif (${IS_LINUX_X86})
  add_definitions(-DIS_LINUX=1)
  list(APPEND ADDITIONAL_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/jsc/include
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

message(STATUS ${ADDITIONAL_INCLUDE_DIRS})

add_library(jsa_jsc_implementation STATIC ${SOURCE_FILES} ${HEADER_FILES})
target_link_libraries(jsa_jsc_implementation ${JSA_LINK_LIBS})
target_link_libraries(jsa_jsc_implementation jsa_abstraction)
target_include_directories(jsa_jsc_implementation PUBLIC ${ADDITIONAL_INCLUDE_DIRS})
