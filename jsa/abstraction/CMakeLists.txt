set(HEADER_FILES
        jsa.h
        instrumentation.h
        macros.h
        js_error.h
        js_context.h
        js_type.h
        )

set(SOURCE_FILES
        js_error.cc
        js_context.cc
        js_type.cc
        )

add_library(jsa_abstraction STATIC ${SOURCE_FILES} ${HEADER_FILES})
target_compile_options(jsa_abstraction PUBLIC -fPIC)
