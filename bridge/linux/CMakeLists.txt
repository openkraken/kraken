cmake_minimum_required(VERSION 3.2.0)
project(KrakenEmmbeder)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_compile_options(-fPIC)

add_library(flutter SHARED IMPORTED)
add_library(kraken SHARED IMPORTED)

set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
  ${CMAKE_CURRENT_SOURCE_DIR}/../../cli/build/app/lib/libflutter_linux_glfw.so
  BUILD_RPATH
  ./libkraken_linux_glfw.so
  )

set_target_properties(kraken PROPERTIES IMPORTED_LOCATION
  ${CMAKE_CURRENT_SOURCE_DIR}/../../cli/build/lib/libkraken.so)

add_library(flutter_plugin STATIC
  ../../playground/linux/flutter/generated_plugin_registrant.cc
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/engine_method_result.cc
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/flutter_window_controller.cc
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/plugin_registrar.cc
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/standard_codec.cc
  )
target_include_directories(flutter_plugin PUBLIC
  ../../playground/linux/flutter
  ../../playground/linux/flutter/ephemeral
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/include
  )

add_library(kraken_embbeder SHARED kraken_embbeder.cc kraken_embbeder.h)
target_link_libraries(kraken_embbeder kraken flutter flutter_plugin)

target_include_directories(kraken_embbeder PUBLIC
  ../../bridge/include
  ../../playground/linux/flutter
  ../../playground/linux/flutter/ephemeral
  ../../playground/linux/flutter/ephemeral/cpp_client_wrapper_glfw/include
  )

set_target_properties(kraken_embbeder
  PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../../cli/build/lib"
  )
