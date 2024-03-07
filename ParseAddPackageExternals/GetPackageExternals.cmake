macro(get_package_externals FILE_PATH)
    file(READ ${FILE_PATH} PACKAGE_EXTERNALS_FILE)
    string(JSON EXTERNAL_COUNT LENGTH ${PACKAGE_EXTERNALS_FILE})
    if(EXTERNAL_COUNT)
        math(EXPR EXTERNAL_MAX_INDEX "${EXTERNAL_COUNT} - 1")
        foreach(INDEX RANGE ${EXTERNAL_MAX_INDEX})
            string(JSON NAME GET ${PACKAGE_EXTERNALS_FILE} ${INDEX} name)
            string(REPLACE "~" "_tilde" NAME ${NAME})
            list(APPEND PACKAGE_EXTERNALS ${NAME})
            unset(NAME)
        endforeach()
    endif()
endmacro()
