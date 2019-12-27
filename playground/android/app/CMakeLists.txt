cmake_minimum_required(VERSION 3.4.1)

set(IS_ANDROID true)

add_library(flutter SHARED IMPORTED)
set_target_properties(flutter PROPERTIES IMPORTED_LOCATION
        ${FLUTTER_ENGINE}/libflutter.so
        )
include_directories(${FLUTTER_ENGINE})

add_subdirectory(./bridge)
add_library(bridge STATIC bridge/bridge.cc bridge/bridge.h bridge/message.cc bridge/message.h)
target_link_libraries(bridge jsa_jsc_implementation)
target_link_libraries(bridge jsa_abstraction)
target_link_libraries(bridge bindings)
target_link_libraries(bridge -pthread)
target_link_libraries(bridge flutter)
target_include_directories(bridge PUBLIC ${FLUTTER_ENGINE})
target_include_directories(bridge PUBLIC ./bridge/bindings)

add_library(kraken SHARED ./common/kraken_bridge_export.cc ./common/kraken_bridge_export.h)

target_include_directories(kraken PUBLIC ./bridge)
target_include_directories(kraken PUBLIC ./bridge/jsa/abstraction)
target_include_directories(kraken PUBLIC ./bridge/jsa/implementation/JSC)
target_include_directories(kraken PUBLIC ./bridge/foundation)

target_link_libraries(kraken bridge)
target_link_libraries(bridge flutter)
target_link_libraries(kraken jsa_abstraction)
target_link_libraries(kraken jsa_jsc_implementation)
target_link_libraries(kraken foundation)