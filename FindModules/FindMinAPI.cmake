include(FindPackageHandleStandardArgs)

if(NOT MinAPI_ROOT)
    file(GLOB_RECURSE C74_MIN_API_FILEPATH_LIST ${CMAKE_SOURCE_DIR}/c74_min_api.h)
    list(LENGTH C74_MIN_API_FILEPATH_LIST C74_MIN_API_FILEPATH_LIST_LENGTH)
    if(C74_MIN_API_FILEPATH_LIST_LENGTH EQUAL 0)
        message(FATAL_ERROR "MinAPI not found")
    else()
        list(GET C74_MIN_API_FILEPATH_LIST 0 C74_MIN_API_FILEPATH)
        cmake_path(GET C74_MIN_API_FILEPATH PARENT_PATH MIN_API_INCLUDE_PATH)
        cmake_path(GET MIN_API_INCLUDE_PATH PARENT_PATH MIN_API_ROOT_PATH)
        set(MinAPI_ROOT ${MIN_API_ROOT_PATH} CACHE PATH "MinAPI root path")
        mark_as_advanced(MinAPI_ROOT)
    endif()
endif()

find_package(MaxAPI REQUIRED)

find_path(MinAPI_INCLUDE_DIR c74_min_api.h PATHS ${MinAPI_ROOT}/include REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
mark_as_advanced(MinAPI_INCLUDE_DIR)

cmake_path(RELATIVE_PATH MinAPI_ROOT BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE MinAPI_ROOT_PATH)
find_package_handle_standard_args(MinAPI DEFAULT_MSG MinAPI_ROOT_PATH MinAPI_INCLUDE_DIR)

if(MinAPI_FOUND AND NOT TARGET MinAPI::MinAPI)
    add_library(MinAPI::MinAPI INTERFACE IMPORTED)
    set(MinAPI_LIBRARY MinAPI::MinAPI)
    target_compile_definitions(MinAPI::MinAPI INTERFACE C74_MIN_API)
    target_include_directories(MinAPI::MinAPI SYSTEM INTERFACE ${MinAPI_INCLUDE_DIR})
    target_link_libraries(MinAPI::MinAPI INTERFACE ${MaxAPI_LIBRARIES})
endif()
