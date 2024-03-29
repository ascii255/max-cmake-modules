include(FindPackageHandleStandardArgs)

if(NOT MinLib_ROOT)
    file(GLOB_RECURSE C74_MIN_LIB_FILEPATH_LIST ${CMAKE_SOURCE_DIR}/c74_lib.h)
    list(GET C74_MIN_LIB_FILEPATH_LIST 0 C74_MIN_LIB_FILEPATH)
    unset(C74_MIN_LIB_FILEPATH_LIST)
    cmake_path(GET C74_MIN_LIB_FILEPATH PARENT_PATH MIN_LIB_INCLUDE_PATH)
    unset(C74_MIN_LIB_FILEPATH)
    cmake_path(GET MIN_LIB_INCLUDE_PATH PARENT_PATH MIN_LIB_ROOT_PATH)
    unset(MIN_LIB_INCLUDE_PATH)
    set(MinLib_ROOT ${MIN_LIB_ROOT_PATH} CACHE PATH "MinLib root directory")
    mark_as_advanced(MinLib_ROOT)
    unset(MIN_LIB_ROOT_PATH)
endif()

find_path(MinLib_INCLUDE_DIR c74_lib.h PATHS ${MinLib_ROOT}/include REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
mark_as_advanced(MinLib_INCLUDE_DIR)

cmake_path(RELATIVE_PATH MinLib_ROOT BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE MinLib_ROOT_PATH)
find_package_handle_standard_args(MinLib DEFAULT_MSG MinLib_ROOT_PATH MinLib_INCLUDE_DIR)
unset(MinLib_ROOT_PATH)

if(MinLib_FOUND AND NOT TARGET MinLib::MinLib)
    add_library(MinLib::MinLib INTERFACE IMPORTED)
    set(MinLib_LIBRARY MinLib::MinLib)
    target_compile_definitions(MinLib::MinLib INTERFACE C74_USE_MIN_LIB)
    target_include_directories(MinLib::MinLib SYSTEM INTERFACE ${MinLib_INCLUDE_DIRS})
endif()
