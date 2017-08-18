project (com.github.nick92.tranqil)
cmake_minimum_required (VERSION 2.8)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

#
# Base
#
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/enso/tranquil")
set (GETTEXT_PACKAGE "com.github.nick92.tranqil")
set (RELEASE_NAME "Soothing sounds.")
set (VERSION "0.1")
set (VERSION_INFO "Production")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

#
# Niceties
#
set (ARCHIVE_NAME tranquil-${VERSION})
add_custom_target (dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target (distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install -DGSETTINGS_LOCALINSTALL=ON .. -DCMAKE_MODULE_PATH=/usr/share/cmake
    && make -j8
    && make -j8 install
    && make check
)
add_dependencies (distcheck dist)

add_custom_target (uninstall "${CMAKE_COMMAND}" -P
    "${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake")

#
# config.h
#
configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)

#
# i18n
#
add_subdirectory(po)

#
# dconf
#
add_subdirectory(schemas)


find_package(PkgConfig)

pkg_check_modules(DEPS REQUIRED
        gtk+-3.0>=3.16
        granite>=0.3.0
	gstreamer-1.0
        glib-2.0>=2.39)

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)

include(ValaVersion)
ensure_vala_version("0.28.0" MINIMUM)

include(ValaPrecompile)
vala_precompile(VALA_C
        src/Tranquil.vala
        src/TranBus.vala
        src/TranquilWindow.vala
PACKAGES
        gtk+-3.0
        granite
        glib-2.0
	gstreamer-1.0
CUSTOM_VAPIS
        vapi/config.vapi
OPTIONS
        --thread
)

add_definitions(${CFLAGS} -Wall -Winit-self -Wwrite-strings -Wunreachable-code -Wstrict-prototypes)
add_executable(com.github.nick92.tranqil ${VALA_C})

install (TARGETS com.github.nick92.tranqil RUNTIME DESTINATION bin)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.nick92.tranqil.desktop DESTINATION share/applications)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.nick92.tranqil.appdata.xml DESTINATION share/metainfo)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/forest.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/forest-dark.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/night.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/night-dark.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/sea.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/sea-dark.svg DESTINATION ${PKGDATADIR}/icons)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/tranquil.svg DESTINATION share/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/tranquil.svg DESTINATION share/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/tranquil.svg DESTINATION share/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/tranquil.svg DESTINATION share/icons/hicolor/128x128/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/tranquil.svg DESTINATION share/icons/hicolor/512x512/apps)
#install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/info.svg DESTINATION ${PKGDATADIR}/icons)
<<<<<<< HEAD
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/amb-forest-spring-afternoon-02.ogg DESTINATION ${PKGDATADIR}/sounds)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/countryside-summer-evening.ogg DESTINATION ${PKGDATADIR}/sounds)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/waves-and-birdsong.ogg DESTINATION ${PKGDATADIR}/sounds)
=======
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/amb-forest-spring-afternoon-02.wav DESTINATION ${PKGDATADIR}/sounds)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/countryside-summer-evening.wav DESTINATION ${PKGDATADIR}/sounds)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/sounds/waves-and-birdsong.wav DESTINATION ${PKGDATADIR}/sounds)
>>>>>>> 51a183799e0b88c9e74e9c7cfd8af25a9ad18659

option (ICON_UPDATE "Run gtk-update-icon-cache after the install." ON)
if (ICON_UPDATE)
  install (CODE "message(\"-- Updating icon cache...\")")
  install (CODE "execute_process(COMMAND gtk-update-icon-cache -f -t ${CMAKE_INSTALL_PREFIX}/share/icons/)")
endif (ICON_UPDATE)
