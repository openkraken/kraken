cmake_minimum_required(VERSION 3.4.1)

set(IS_ANDROID true)

set(ENV{KRAKEN_JS_ENGINE} jsc)

add_subdirectory(./bridge)