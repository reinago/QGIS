# Allow to configure a custom vcpkg directory, otherwise download vcpkg to the
# build directory. Check for a `vcpkg` directory within the source directory
# to make offline build bundles work out of the box. By default, download only
# to the build directory, but `QGIS_VCPKG_DOWNLOAD` can be used to enable
# the download for a custom directory.

set(QGIS_VCPKG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg" CACHE PATH "Path to vcpkg.")
set(QGIS_VCPKG_DOWNLOAD OFF CACHE BOOL "Download vcpkg.")
mark_as_advanced(FORCE QGIS_VCPKG_DIR QGIS_VCPKG_DOWNLOAD)

if (NOT IS_DIRECTORY "${QGIS_VCPKG_DIR}")
  set(QGIS_VCPKG_DIR "${CMAKE_CURRENT_BINARY_DIR}/vcpkg" CACHE PATH "Path to vcpkg." FORCE)
  set(QGIS_VCPKG_DOWNLOAD ON CACHE BOOL "Download vcpkg." FORCE)
endif ()

# Download vcpkg via FetchContent.
if (QGIS_VCPKG_DOWNLOAD)
  include(FetchContent)
  mark_as_advanced(FORCE
    FETCHCONTENT_BASE_DIR
    FETCHCONTENT_FULLY_DISCONNECTED
    FETCHCONTENT_QUIET
    FETCHCONTENT_UPDATES_DISCONNECTED)

  # Require git for download
  find_package(Git REQUIRED)

  FetchContent_Declare(vcpkg-download
    GIT_REPOSITORY https://github.com/microsoft/vcpkg.git
    GIT_TAG ${QGIS_VCPKG_VERSION}
    #GIT_SHALLOW TRUE # Not supported by vcpkg
    SOURCE_DIR ${QGIS_VCPKG_DIR})
  FetchContent_GetProperties(vcpkg-download)
  if (NOT vcpkg-download_POPULATED)
    message(STATUS "Fetch vcpkg ...")
    FetchContent_Populate(vcpkg-download)
    mark_as_advanced(FORCE
      FETCHCONTENT_SOURCE_DIR_VCPKG-DOWNLOAD
      FETCHCONTENT_UPDATES_DISCONNECTED_VCPKG-DOWNLOAD)
  endif ()
endif ()

# vcpkg config
set(VCPKG_OVERLAY_PORTS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/vcpkg_ports")
set(VCPKG_OVERLAY_TRIPLETS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/vcpkg_triplets") # Disable compiler tracking on Windows.
set(VCPKG_BOOTSTRAP_OPTIONS "-disableMetrics")
set(VCPKG_INSTALL_OPTIONS "--clean-after-build" "--no-print-usage")
set(CMAKE_TOOLCHAIN_FILE "${QGIS_VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
set(ENV{VCPKG_FORCE_DOWNLOADED_BINARIES} ON) # Always download tools (i.e. CMake) to have consistent versions on all systems.
