cmake_minimum_required(VERSION 3.25 FATAL_ERROR)

function(generate_package_dmg PACKAGE_NAME)
    install(FILES
        icon.png
        LICENSE.md
        package-info.json
        README.md
        DESTINATION ${PACKAGE_NAME}
    )

    install(DIRECTORY docs DESTINATION ${PACKAGE_NAME})
    install(DIRECTORY externals DESTINATION ${PACKAGE_NAME})
    install(DIRECTORY help DESTINATION ${PACKAGE_NAME})
    install(DIRECTORY patchers DESTINATION ${PACKAGE_NAME})

    set(CPACK_GENERATOR DragNDrop)
    set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/LICENSE.md)
    set(CPACK_DMG_SLA_USE_RESOURCE_FILE_LICENSE ON)
    set(CPACK_DMG_DISABLE_APPLICATIONS_SYMLINK ON)
    execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink "/Users/Shared/Max 8/Packages"
        ${CMAKE_BINARY_DIR}/Packages
    )
    install(FILES ${CMAKE_BINARY_DIR}/Packages DESTINATION ./)
    include(CPack)
endfunction()
