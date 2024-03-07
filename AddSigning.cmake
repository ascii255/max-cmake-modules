function(add_signing TARGET)
    cmake_parse_arguments(ARG NOTARIZE CERTIFICATE "" ${ARGN})
    if(NOTARIZE)
        set(ARG_NOTARIZE NOTARIZE)
    endif()

    if(ARG_CERTIFICATE)
        set(SIGNING_CERTIFICATE ARG_CERTIFICATE CACHE STRING "Developer ID Application" FORCE)
    else()
        execute_process(
            COMMAND xcrun security find-identity -v -p codesigning
            OUTPUT_VARIABLE IDENTITY_STRING
        )
        if(IDENTITY_STRING MATCHES "\"(Developer ID Application: [^;]+)\"")
            set(SIGNING_CERTIFICATE ${CMAKE_MATCH_1} CACHE STRING "Developer ID Application")
        endif()
    endif()

    if(ARG_NOTARIZE)
        add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND xcrun codesign --force --deep --verbose --timestamp --options runtime --ignore-resources
                $<TARGET_FILE:${TARGET}> --sign ${SIGNING_CERTIFICATE}
            COMMAND xcrun codesign -vvv --deep --strict $<TARGET_FILE:${TARGET}>
            COMMAND xcrun ditto -c -k --keepParent $<TARGET_BUNDLE_DIR:${TARGET}>
                ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
            COMMAND xcrun notarytool submit --verbose --wait --keychain-profile notarytool-password
                ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
            COMMAND xcrun stapler staple -v $<TARGET_BUNDLE_DIR:${TARGET}>
            COMMAND ${CMAKE_COMMAND} -E rm -rf ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
            VERBATIM USES_TERMINAL
        )
    elseif(NOT CMAKE_GENERATOR STREQUAL Xcode)
        add_custom_command(TARGET ${TARGET} POST_BUILD
            COMMAND xcrun codesign --force --deep --verbose --timestamp --options runtime --ignore-resources
                $<TARGET_FILE:${TARGET}> --sign ${SIGNING_CERTIFICATE}
            COMMAND xcrun codesign -vvv --deep --strict $<TARGET_FILE:${TARGET}>
            VERBATIM USES_TERMINAL
        )
    endif()
endfunction()
