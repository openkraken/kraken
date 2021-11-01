cmake_minimum_required(VERSION 3.6)

project(app)

execute_process(
  COMMAND bash "-c" "./patches/apply_patch.sh"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../
) # Run patch scripts
