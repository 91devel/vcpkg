if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sweeneychris/TheiaSfM
    REF d15154a6c30ea48e7d135be126e2936802e476ad
    SHA512 e3cb29b1806b6d2ed161c28432ad8788f756e03db55f883bfa2c4b389b506aa46909f0de57460e93e38926d8103382c54f51685bb9035688e4c7378f913c2de0
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-vlfeat-static.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-glog-error.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-find-suitesparse.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=OFF
        -DTHEIA_USE_EXTERNAL_CEREAL=ON
        -DTHEIA_USE_EXTERNAL_FLANN=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "CMake")

# Changes target search path
file(READ ${CURRENT_PACKAGES_DIR}/share/theia/TheiaConfig.cmake THEIA_TARGETS)
string(REPLACE "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n  \${THEIA_CURRENT_CONFIG_INSTALL_DIR}/../ ABSOLUTE)"
               "get_filename_component(CURRENT_ROOT_INSTALL_DIR\n  \${THEIA_CURRENT_CONFIG_INSTALL_DIR}/../../ ABSOLUTE)" THEIA_TARGETS "${THEIA_TARGETS}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/theia/TheiaConfig.cmake "${THEIA_TARGETS}")

vcpkg_copy_pdbs()

# Clean
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/optimo)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/cimg/cmake-modules)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/theia/libraries/akaze/datasets)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/theia/libraries/spectra/doxygen)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/optimo)

# Handle copyright
file(COPY ${SOURCE_PATH}/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/theia)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/theia/license.txt ${CURRENT_PACKAGES_DIR}/share/theia/copyright)
file(COPY ${SOURCE_PATH}/data/camera_sensor_database_license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/theia)
