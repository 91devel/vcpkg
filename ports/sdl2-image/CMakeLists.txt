cmake_minimum_required(VERSION 2.6)
project(SDL2_image C)

### configuration ###

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
# enable all file formats which are supported natively
set(SUPPORTED_FORMATS BMP GIF LBM PCX PNM TGA XPM XCF XV)

# enable all file formats which are supported through external dependencies
# first try to load them statically (lib file in vcpkg installation)
# if this fails try to make them a dynamic dependency (dll will be loaded at runtime) if possible. vcpkg cannot resolve these dependencies!
# else do not support this file format at all
set(DEPENDENCIES PNG JPEG TIFF WEBP)

# patch library names for preprocessor flags
set(JPEG_FLAG JPG)
set(TIFF_FLAG TIF)

# names of potentially dynamically loaded libraries
set(JPEG_DYNAMIC \"libjpeg-9.dll\")
set(PNG_DYNAMIC \"libpng16-16.dll\")
set(TIFF_DYNAMIC \"libtiff-5.dll\")
set(WEBP_DYNAMIC \"libwebp-4.dll\")

### implementation ###

add_library(SDL2_image
    IMG.c
    IMG_bmp.c
    IMG_gif.c
    IMG_jpg.c
    IMG_lbm.c
    IMG_pcx.c
    IMG_png.c
    IMG_pnm.c
    IMG_tga.c
    IMG_tif.c
    IMG_webp.c
    IMG_xcf.c
    IMG_xpm.c
    IMG_xv.c
    IMG_xxx.c
    )

set_target_properties(SDL2_image PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)

foreach(FORMAT ${SUPPORTED_FORMATS})
    add_definitions(-DLOAD_${FORMAT})
endforeach(FORMAT)

# SDL
find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_library(SDL_LIBRARY SDL2)

include_directories(${SDL_INCLUDE_DIR})
include_directories(${SDL_INCLUDE_DIR}/SDL2)
include_directories(${CMAKE_SOURCE_DIR})

target_link_libraries(SDL2_image ${SDL_LIBRARY})

# external dependencies
foreach(DEPENDENCY ${DEPENDENCIES})
    find_package(${DEPENDENCY})

    if(NOT DEFINED ${DEPENDENCY}_FLAG)
        set(${DEPENDENCY}_FLAG ${DEPENDENCY})
    endif()

    add_definitions(-DLOAD_${${DEPENDENCY}_FLAG})
    if(${DEPENDENCY}_FOUND)
        message(STATUS "  --> linking statically.")
        target_link_libraries(SDL2_image ${${DEPENDENCY}_LIBRARIES})
    elseif(DEFINED ${DEPENDENCY}_DYNAMIC)
        message(STATUS "  --> linking dynamically.")
        add_definitions(-DLOAD_${${DEPENDENCY}_FLAG}_DYNAMIC=${${DEPENDENCY}_DYNAMIC})
        set(RUNTIME_DEPENDENCIES ON)
    else()
        message(STATUS "  --> skipping.")
    endif()
endforeach(DEPENDENCY)

if(DEFINED RUNTIME_DEPENDENCIES)
    include_directories(VisualC/external/include)
endif()


install(TARGETS SDL2_image
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(FILES SDL_image.h DESTINATION include/SDL2 CONFIGURATIONS Release)


message(STATUS "Link-time dependencies:")
message(STATUS "  " ${SDL_LIBRARY})
foreach(DEPENDENCY ${DEPENDENCIES})
    if(${DEPENDENCY}_FOUND)
        message(STATUS "  " ${DEPENDENCY})
    endif()
endforeach(DEPENDENCY)

if(DEFINED RUNTIME_DEPENDENCIES)
    message(STATUS "Run-time dependencies:")
    foreach(DEPENDENCY ${DEPENDENCIES})
        if(NOT ${DEPENDENCY}_FOUND AND DEFINED ${DEPENDENCY}_DYNAMIC)
            message(STATUS "  " ${${DEPENDENCY}_DYNAMIC})
        endif()
    endforeach(DEPENDENCY)
endif()
