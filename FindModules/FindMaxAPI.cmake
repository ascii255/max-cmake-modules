include(FindPackageHandleStandardArgs)

if(NOT C74_SUPPORT_PATH)
    if(NOT MaxAPI_ROOT)
        file(GLOB_RECURSE C74_MAX_FILEPATH_LIST ${CMAKE_SOURCE_DIR}/c74_max.h)
        list(LENGTH C74_MAX_FILEPATH_LIST C74_MAX_FILEPATH_LIST_LENGTH)
        if(C74_MAX_FILEPATH_LIST_LENGTH EQUAL 0)
            message(FATAL_ERROR "MaxAPI not found")
        else()
            list(GET C74_MAX_FILEPATH_LIST 0 C74_MAX_FILEPATH)
            cmake_path(GET C74_MAX_FILEPATH PARENT_PATH C74_SUPPORT_PATH)
            set(C74_SUPPORT_PATH ${C74_SUPPORT_PATH} CACHE PATH "Cycling ’74 support path" FORCE)
            mark_as_advanced(C74_SUPPORT_PATH)
            cmake_path(GET C74_SUPPORT_PATH PARENT_PATH MaxAPI_ROOT_PATH)
            set(MaxAPI_ROOT ${MaxAPI_ROOT_PATH} CACHE PATH "MaxAPI root path" FORCE)
            mark_as_advanced(MaxAPI_ROOT)
        endif()
    else()
        set(C74_SUPPORT_PATH ${MaxAPI_ROOT}/c74support CACHE PATH "Cycling ’74 support path" FORCE)
        mark_as_advanced(C74_SUPPORT_PATH)
    endif()
endif()

if(MaxAPI_FIND_COMPONENTS MATCHES Core OR NOT MaxAPI_FIND_COMPONENTS)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        find_library(MaxAPI_Core_LIBRARY MaxAPI PATHS ${C74_SUPPORT_PATH}/max-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        find_library(MaxAPI_Core_LIBRARY MaxAPI PATHS ${C74_SUPPORT_PATH}/max-includes/x64 REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    endif()
    find_path(MaxAPI_Core_INCLUDE_DIR c74_linker_flags.txt PATHS ${C74_SUPPORT_PATH}/max-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    if(MaxAPI_Core_LIBRARY AND MaxAPI_Core_INCLUDE_DIR)
        set(MaxAPI_Core_FOUND TRUE)
        cmake_path(ABSOLUTE_PATH MaxAPI_Core_LIBRARY NORMALIZE OUTPUT_VARIABLE MaxAPI_Core_PATH)
        cmake_path(RELATIVE_PATH MaxAPI_Core_PATH BASE_DIRECTORY ${CMAKE_SOURCE_DIR})
        find_package_message(MaxAPI_Core "Found MaxAPI::Core: ${MaxAPI_Core_PATH}" "[${MaxAPI_Core_LIBRARY}][${MaxAPI_Core_INCLUDE_DIR}]")
    endif()
    mark_as_advanced(MaxAPI_Core_LIBRARY MaxAPI_Core_INCLUDE_DIR)
    
    if(MaxAPI_Core_FOUND AND NOT TARGET MaxAPI::Core)
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            add_library(MaxAPI::Core INTERFACE IMPORTED)
        
            file(READ ${MaxAPI_Core_INCLUDE_DIR}/c74_linker_flags.txt C74_SYM_MAX_LINKER_FLAGS)
            string(REPLACE "\n" "" C74_SYM_MAX_LINKER_FLAGS ${C74_SYM_MAX_LINKER_FLAGS})
            string(REPLACE " " ";" C74_SYM_MAX_LINKER_FLAGS ${C74_SYM_MAX_LINKER_FLAGS})
            target_link_options(MaxAPI::Core INTERFACE ${C74_SYM_MAX_LINKER_FLAGS})
        elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
            add_library(MaxAPI::Core SHARED IMPORTED)

            set_target_properties(MaxAPI::Core PROPERTIES
                IMPORTED_IMPLIB ${MaxAPI_Core_LIBRARY}
                SYSTEM TRUE
            )

            target_compile_definitions(MaxAPI::Core INTERFACE MAXAPI_USE_MSCRT WIN_VERSION _USE_MATH_DEFINES)
        endif()

        target_include_directories(MaxAPI::Core SYSTEM INTERFACE ${C74_SUPPORT_PATH} ${MaxAPI_Core_INCLUDE_DIR})

        list(APPEND MaxAPI_LIBRARIES MaxAPI::Core)
        list(APPEND MaxAPI_INCLUDE_DIRS ${C74_SUPPORT_PATH})
        list(APPEND MaxAPI_INCLUDE_DIRS ${MaxAPI_Core_INCLUDE_DIR})
    endif()
endif()

if(MaxAPI_FIND_COMPONENTS MATCHES Audio OR NOT MaxAPI_FIND_COMPONENTS)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        find_library(MaxAPI_Audio_LIBRARY MaxAudioAPI PATHS ${C74_SUPPORT_PATH}/msp-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        find_library(MaxAPI_Audio_LIBRARY MaxAudio PATHS ${C74_SUPPORT_PATH}/msp-includes/x64 REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    endif()
    find_path(MaxAPI_Audio_INCLUDE_DIR MaxAudioAPI.h PATHS ${C74_SUPPORT_PATH}/msp-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    if(MaxAPI_Audio_LIBRARY AND MaxAPI_Audio_INCLUDE_DIR)
        set(MaxAPI_Audio_FOUND TRUE)
        cmake_path(ABSOLUTE_PATH MaxAPI_Audio_LIBRARY NORMALIZE OUTPUT_VARIABLE MaxAPI_Audio_PATH)
        cmake_path(RELATIVE_PATH MaxAPI_Audio_PATH BASE_DIRECTORY ${CMAKE_SOURCE_DIR})
        find_package_message(MaxAPI_Audio "Found MaxAPI::Audio: ${MaxAPI_Audio_PATH}" "[${MaxAPI_Audio_LIBRARY}][${MaxAPI_Audio_INCLUDE_DIR}]")
    endif()
    mark_as_advanced(MaxAPI_Audio_LIBRARY MaxAPI_Audio_INCLUDE_DIR)
    
    if(MaxAPI_Audio_FOUND AND NOT TARGET MaxAPI::Audio)
        add_library(MaxAPI::Audio SHARED IMPORTED)
    
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            set_target_properties(MaxAPI::Audio PROPERTIES
                FRAMEWORK TRUE
                IMPORTED_LOCATION ${MaxAPI_Audio_LIBRARY}
                MACOSX_FRAMEWORK_IDENTIFIER "com.cycling74.MaxAudioAPI"
                MACOSX_FRAMEWORK_INFO_PLIST ${MaxAPI_Audio_LIBRARY}/Resources/Info.plist
                SYSTEM TRUE
            )
        elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
            set_target_properties(MaxAPI::Audio PROPERTIES
                IMPORTED_IMPLIB ${MaxAPI_Audio_LIBRARY}
                SYSTEM TRUE
            )

            target_include_directories(MaxAPI::Audio SYSTEM INTERFACE ${MaxAPI_Audio_INCLUDE_DIR})
        endif()

        list(APPEND MaxAPI_LIBRARIES MaxAPI::Audio)
        list(APPEND MaxAPI_INCLUDE_DIRS ${MaxAPI_Audio_INCLUDE_DIR})
    endif()
endif()

if(MaxAPI_FIND_COMPONENTS MATCHES Jitter OR NOT MaxAPI_FIND_COMPONENTS)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        find_library(MaxAPI_Jitter_LIBRARY JitterAPI PATHS ${C74_SUPPORT_PATH}/jit-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        find_library(MaxAPI_Jitter_LIBRARY jitlib PATHS ${C74_SUPPORT_PATH}/jit-includes/x64 REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    endif()
    find_path(MaxAPI_Jitter_INCLUDE_DIR jit.common.h PATHS ${C74_SUPPORT_PATH}/jit-includes REQUIRED NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
    if(MaxAPI_Jitter_LIBRARY AND MaxAPI_Jitter_INCLUDE_DIR)
        set(MaxAPI_Jitter_FOUND TRUE)
        cmake_path(ABSOLUTE_PATH MaxAPI_Jitter_LIBRARY NORMALIZE OUTPUT_VARIABLE MaxAPI_Jitter_PATH)
        cmake_path(RELATIVE_PATH MaxAPI_Jitter_PATH BASE_DIRECTORY ${CMAKE_SOURCE_DIR})
        find_package_message(MaxAPI_Jitter "Found MaxAPI::Jitter: ${MaxAPI_Jitter_PATH}" "[${MaxAPI_Jitter_LIBRARY}][${MaxAPI_Jitter_INCLUDE_DIR}]")
    endif()
    mark_as_advanced(MaxAPI_Jitter_LIBRARY MaxAPI_Jitter_INCLUDE_DIR)
    
    if(MaxAPI_Jitter_FOUND AND NOT TARGET MaxAPI::Jitter)
        add_library(MaxAPI::Jitter SHARED IMPORTED)
    
        if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
            set_target_properties(MaxAPI::Jitter PROPERTIES
                FRAMEWORK TRUE
                IMPORTED_LOCATION ${MaxAPI_Jitter_LIBRARY}
                MACOSX_FRAMEWORK_IDENTIFIER "com.cycling74.JitterAPI"
                MACOSX_FRAMEWORK_INFO_PLIST ${MaxAPI_Jitter_LIBRARY}/Resources/Info.plist
                SYSTEM TRUE
            )
        elseif(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
            set_target_properties(MaxAPI::Jitter PROPERTIES
                IMPORTED_IMPLIB ${MaxAPI_Jitter_LIBRARY}
                SYSTEM TRUE
            )

            target_include_directories(MaxAPI::Jitter SYSTEM INTERFACE ${MaxAPI_Jitter_INCLUDE_DIR})
        endif()

        list(APPEND MaxAPI_LIBRARIES MaxAPI::Jitter)
        list(APPEND MaxAPI_INCLUDE_DIRS ${MaxAPI_Jitter_INCLUDE_DIR})
    endif()
endif()

if(MaxAPI_FIND_COMPONENTS)
    find_package_handle_standard_args(MaxAPI HANDLE_COMPONENTS)
endif()
