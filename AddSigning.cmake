function(add_signing TARGET)
    if(CMAKE_SYSTEM_NAME MATCHES "Darwin")
        cmake_parse_arguments(ARG NOTARIZE CERTIFICATE "" ${ARGN})
            
        if(NOTARIZE)
            set(ARG_NOTARIZE NOTARIZE)
        endif()

        if(ARG_CERTIFICATE)
            set(SIGNING_CERTIFICATE ${ARG_CERTIFICATE} CACHE STRING "Developer ID Application")
        else()
            execute_process(
                COMMAND xcrun security find-identity -v -p codesigning
                OUTPUT_VARIABLE IDENTITY_STRING
            )
            if(IDENTITY_STRING MATCHES "\"(Developer ID Application: [^;]+)\"")
                set(SIGNING_CERTIFICATE ${CMAKE_MATCH_1} CACHE STRING "Developer ID Application")
            else()
                set(SIGNING_CERTIFICATE "-" CACHE STRING "Developer ID Application")
            endif()
        endif()

        if(SIGNING_CERTIFICATE STREQUAL "-")
            get_target_property(EXTERNAL_NAME ${TARGET} MACOSX_BUNDLE_BUNDLE_NAME)
            message(STATUS "Warning: no valid Apple Developer ID certificate found in keychain")
            message(STATUS "      -> signing external ${EXTERNAL_NAME} to run locally")
        endif()

        if(CMAKE_GENERATOR STREQUAL Xcode AND NOT ARG_NOTARIZE)
            set_target_properties(${TARGET} PROPERTIES
                XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${SIGNING_CERTIFICATE}
                XCODE_ATTRIBUTE_CODE_SIGN_INJECT_BASE_ENTITLEMENTS NO
                XCODE_ATTRIBUTE_CODE_SIGN_STYLE Manual
                XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
                XCODE_ATTRIBUTE_OTHER_CODE_SIGN_FLAGS "--force --deep --timestamp --ignore-resources"
            )       
        else()
            set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED NO)

            add_custom_command(TARGET ${TARGET} PRE_BUILD
                COMMAND ${CMAKE_COMMAND} -E rm -rf $<TARGET_BUNDLE_CONTENT_DIR:${TARGET}>/_CodeSignature
            )

            add_custom_command(TARGET ${TARGET} POST_BUILD
                COMMAND xcrun codesign --force --deep --verbose --timestamp --options runtime --ignore-resources
                    $<TARGET_FILE:${TARGET}> --sign ${SIGNING_CERTIFICATE}
                COMMAND xcrun codesign -vvv --deep --strict $<TARGET_FILE:${TARGET}>
                VERBATIM USES_TERMINAL
            )
        endif()

        if(ARG_NOTARIZE)
            add_custom_command(TARGET ${TARGET} POST_BUILD
                COMMAND xcrun ditto -c -k --keepParent $<TARGET_BUNDLE_DIR:${TARGET}>
                    ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
                COMMAND xcrun notarytool submit --verbose --wait --keychain-profile notarytool-password
                    ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
                COMMAND xcrun stapler staple -v $<TARGET_BUNDLE_DIR:${TARGET}>
                COMMAND ${CMAKE_COMMAND} -E rm -rf ${CMAKE_BINARY_DIR}/$<TARGET_FILE_NAME:${TARGET}>.zip
                VERBATIM USES_TERMINAL
            )
        endif()
    endif()
endfunction()
