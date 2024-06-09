cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/source/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/source/cmake/Max/FindModules
)

include(Max/ParsePackageInfo)
include(Max/AddExternal)
include(Max/AddSigning)
include(Max/GeneratePackageDMG)
