<p align="center">
    <img src="Logo.svg" width="57%" />
</p>

CMake Modules for Max Package Development
=========================================

Find Modules
------------
There are three find modules that can be used to find libraries and create CMake targets.
* `FindMaxAPI`
* `FindMinAPI`
* `FindMinLib`

Usually CMake modules are put into a `cmake` folder and this directory is added to the `CMAKE_MODULE_PATH`. It is 
recommended that you add the repository into the `cmake` folder as a submodule.
```
pushd cmake
git submodule add https://github.com/ascii255/max-cmake-modules.git Max
popd
```
In your `CMakeLists.txt` the `cmake` folder and the `FindModules` path should be appended to the `CMAKE_MODULE_PATH`.
```cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_SOURCE_DIR}/source/cmake/Max/FindModules)
```

The CMake targets will be created after the `project` command using
```cmake
find_package(MinAPI REQUIRED)
find_package(MinLib REQUIRED)
```
The `FindMinAPI` module will also create the `MaxAPI` targets and link them.

The module will look for the repositories somewhere in the `${CMAKE_SOURCE_DIR}`. It is recommended to have the 
[min-api](https://github.com/Cycling74/min-api) and optionally the [min-lib](https://github.com/Cycling74/min-lib) 
added as a submodule to the package git repository.

```
git submodule add https://github.com/Cycling74/min-api.git
git submodule add https://github.com/Cycling74/min-lib.git
```

The `find_package` functions will fill the variables
* `MaxAPI_LIBRARIES`, `MaxAPI_INCLUDE_DIRS`
* `MinAPI_LIBRARY`, `MinAPI_INCLUDE_DIR`
* `MinLib_LIBRARY`, `MinLib_INCLUDE_DIR`

and the targets
* `MaxAPI::Core`, `MaxAPI::Audio`, `MaxAPI::Jitter`
* `MinAPI::MinAPI`
* `MinLib::MinLib`

To link the MinAPI use
```cmake
target_link_libraries(${EXTERNAL_TARGET} PRIVATE MinAPI::MinAPI)
```

For the `MaxAPI` module components can be listed.
```cmake
find_package(MaxAPI REQUIRED COMPONENTS Core Audio)
```

Utility Modules
---------------
These modules will help to configure a project as a Max package. It can be seen as an alternative to using the
[min-devkit](https://github.com/Cycling74/min-devkit).

### ParsePackageInfo
This module will parse the [`package-info.json`](https://docs.cycling74.com/max8/vignettes/package_info_json) file that 
is also part of the resulting Max package. The module will fill the CMake variables
* `PACKAGE_NAME`
* `PACKAGE_DISPLAY_NAME`
* `PACKAGE_VERSION`
* `PACKAGE_AUTHOR`
* `PACKAGE_DESCRIPTION`
* `PACKAGE_WEBSITE`
* `PACKAGE_REVERSE_DOMAIN`
* `PACKAGE_COPYRIGHT` (`(c)` will be replaced by `©`)

These variables can then be used to create a project for the Max package.
```cmake
include(Max/ParsePackageInfo)
parse_package_info(${CMAKE_SOURCE_DIR}/package-info.json)

project(${PACKAGE_NAME}
    VERSION ${PACKAGE_VERSION}
    DESCRIPTION ${PACKAGE_DESCRIPTION}
    HOMEPAGE_URL ${PACKAGE_WEBSITE}
    LANGUAGES CXX
)
```

### AddExternal
This module will add a target configured to be build as a Max external.
```cmake
include(Max/AddExternal)
add_external(${EXTERNAL_TARGET} ${EXTERNAL_NAME}
    VERSION ${PACKAGE_VERSION}
    REVERSE_DOMAIN ${PACKAGE_REVERSE_DOMAIN}
    COPYRIGHT ${PACKAGE_COPYRIGHT}
)
```

If the variables `PACKAGE_VERSION`, `PACKAGE_REVERSE_DOMAIN`, `PACKAGE_COPYRIGHT` have been set or there was a previous 
call to the `parse_package_info` macro of the `ParsePackageInfo` module that set them, the optional arguments can be 
omitted.
```cmake
add_external(${EXTERNAL_TARGET} ${EXTERNAL_NAME})
```

On an `ARM64` Mac computer or when `CMAKE_OSX_ARCHITECTURES` are set, signing (see `AddSigning`) is always added.

To trigger regeneration of the documentation from the source code, the module will remove the documentation file for 
the external in `docs` after the external was built. To avoid this behavior if a custom documentation is provided and 
generation should be avoided, the argument `CUSTUM_DOCUMENTATION` can be specified.
```cmake
add_external(${EXTERNAL_TARGET} ${EXTERNAL_NAME} CUSTOM_DOCUMENTATION)
```

### AddSigning
This module is for Mac only and will handle signing and notarization of the built externals. A signing certificate has 
to be provided. An [Apple Developer ID](https://developer.apple.com/developer-id/) is required. To generate the signing 
certificate follow the 
[instructions from Apple](https://developer.apple.com/help/account/create-certificates/create-developer-id-certificates/).

To check if you have a valid `Developer ID` present on your system you can use:
```
xcrun security find-identity -v -p codesigning
```

The `add_signing` function should be called after the `add_external` function has been called for the same target.
```cmake
add_signing(${EXTERNAL_TARGET} CERTIFICATE ${SIGNING_CERTIFICATE})
```

The argument `CERTIFICATE` can be omitted if a valid `Developer ID` certificate is present in the local keychain. Then
the first valid certificate will be used.
```cmake
add_signing(${EXTERNAL_TARGET})
```
If no valid certificate is present, the external will be signed to run only locally.

The CMake argument `SIGNING_CERTIFICATE` can also be used to define the certificate.
```
cmake ... -DSIGNING_CERTIFICATE="..."
```

To force not to use a certificate from the keychain use:
```
cmake ... -DSIGNING_CERTIFICATE="-"
```

If the argument `NOTARIZE` is given, the external will also be notarized. Credentials have to be present in the 
keychain. To setup the keychain it is recommended to use a command from the 
[customizing the notarization workflow tutorial](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow):
```
xcrun notarytool store-credentials "notarytool-password"
               --apple-id "<AppleID>"
               --team-id <DeveloperTeamID>
               --password <secret_2FA_password>
```

### GeneratePackageDMG
This module is for Mac only and will generate a drag and drop DMG image containing the package and a symlink to 
`/Users/Shared/Max 8/Packages`. The module is using CPack internally and the `DragNDrop` generator.
```cmake
include(Max/GeneratePackageDMG)
generate_package_dmg(${PROJECT_NAME})
```

The package can be created using the cmake target `package`.
```cmake
cmake -B build -S . -D CMAKE_BUILD_TYPE=Release
cmake --build build --config Release --target package
```
