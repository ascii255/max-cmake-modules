cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

include(Max/AddExternal)
include(Max/AddSigning)
include(Max/ParseAddPackageExternals/ConfigureExternalSourceFile)
include(Max/ParseAddPackageExternals/GetPackageExternals)
include(Max/ParseAddPackageExternals/ParsePackageExternal)

function(parse_add_package_externals FILEPATH)
    find_package(MaxAPI REQUIRED)
    find_package(MinAPI REQUIRED)

    #set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
    #include(CTest)

    get_package_externals(${FILEPATH})

    foreach(EXTERNAL IN LISTS PACKAGE_EXTERNALS)
        list(FIND PACKAGE_EXTERNALS ${EXTERNAL} INDEX)
        parse_package_external(${FILEPATH} ${INDEX})
        unset(INDEX)

        configure_external_source_file(${CMAKE_CURRENT_SOURCE_DIR}/source/${EXTERNAL}.hpp)
        
        message(STATUS "Adding ${EXTERNAL_NAME}${EXTERNAL_LIBRARIES_STRING}")
        
        add_external(${EXTERNAL} ${EXTERNAL_NAME})

        set_target_properties(${EXTERNAL} PROPERTIES
            CXX_STANDARD_REQUIRED TRUE
            LINKER_LANGUAGE CXX
        )

        target_compile_features(${EXTERNAL} PRIVATE cxx_std_23)
    
        target_sources(${EXTERNAL} PRIVATE 
            ${CMAKE_CURRENT_SOURCE_DIR}/source/${EXTERNAL}.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/source/${EXTERNAL}.cpp
            ${EXTERNAL_ADDITIONAL_SOURCE_FILES}
        )
        get_target_property(${EXTERNAL}_SOURCES ${EXTERNAL} SOURCES)
        source_group("" FILES ${${EXTERNAL}_SOURCES})
        
        foreach(LIBRARY IN LISTS EXTERNAL_LIBRARIES)
            find_package(${LIBRARY} MODULE REQUIRED)
        endforeach()
        
        target_link_libraries(${EXTERNAL} PRIVATE ${MaxAPI_LIBRARIES} ${MinAPI_LIBRARY} ${EXTERNAL_LINK_LIBRARIES})
        
        add_signing(${EXTERNAL})
    endforeach()
endfunction()

# https://github.com/create-dmg/create-dmg/blob/master/create-dmg
# cmake --preset=release -DSIGNING_CERTIFICATE_COMMON_NAME="Developer ID Application: Mediatain GmbH & Co. KG (QKLYGWR5K3)" && cmake --build build/release --config Release --target package
# rm -rf build && cmake --preset=xcode && open build/xcode/*.xcodeproj
