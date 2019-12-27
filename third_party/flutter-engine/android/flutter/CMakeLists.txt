project(flutter)

add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
  ./libflutter.so)
