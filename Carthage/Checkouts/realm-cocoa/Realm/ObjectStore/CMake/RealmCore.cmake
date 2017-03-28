###########################################################################
#
# Copyright 2016 Realm Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###########################################################################

include(ExternalProject)
include(ProcessorCount)

find_package(Threads)

# Load dependency info from dependencies.list into REALM_FOO_VERSION variables.
file(STRINGS dependencies.list DEPENDENCIES)
message("Dependencies: ${DEPENDENCIES}")
foreach(DEPENDENCY IN LISTS DEPENDENCIES)
    string(REGEX MATCHALL "([^=]+)" COMPONENT_AND_VERSION ${DEPENDENCY})
    list(GET COMPONENT_AND_VERSION 0 COMPONENT)
    list(GET COMPONENT_AND_VERSION 1 VERSION)
    set(${COMPONENT} ${VERSION})
endforeach()


if(APPLE)
    find_library(FOUNDATION_FRAMEWORK Foundation)
    find_library(SECURITY_FRAMEWORK Security)

    set(CRYPTO_LIBRARIES "")
    set(SSL_LIBRARIES ${FOUNDATION_FRAMEWORK} ${SECURITY_FRAMEWORK})
elseif(REALM_PLATFORM STREQUAL "Android")
    # The Android core and sync libraries include the necessary portions of OpenSSL.
    set(CRYPTO_LIBRARIES "")
    set(SSL_LIBRARIES "")
elseif(CMAKE_SYSTEM_NAME MATCHES "^Windows")
    # Windows doesn't do crypto right now, but that is subject to change
    set(CRYPTO_LIBRARIES "")
    set(SSL_LIBRARIES "")
else()
    find_package(OpenSSL REQUIRED)

    set(CRYPTO_LIBRARIES OpenSSL::Crypto)
    set(SSL_LIBRARIES OpenSSL::SSL)
endif()


set(MAKE_FLAGS "REALM_HAVE_CONFIG=1")

if(SANITIZER_FLAGS)
    set(MAKE_FLAGS ${MAKE_FLAGS} "EXTRA_CFLAGS=${SANITIZER_FLAGS}" "EXTRA_LDFLAGS=${SANITIZER_FLAGS}")
endif()

ProcessorCount(NUM_JOBS)
if(NOT NUM_JOBS EQUAL 0)
    set(MAKE_FLAGS ${MAKE_FLAGS} "-j${NUM_JOBS}")
endif()

if (${CMAKE_VERSION} VERSION_GREATER "3.4.0")
    set(USES_TERMINAL_BUILD USES_TERMINAL_BUILD 1)
endif()

function(use_realm_core enable_sync core_prefix sync_prefix)
    if(core_prefix)
        build_existing_realm_core(${core_prefix})
        if(sync_prefix)
            build_existing_realm_sync(${sync_prefix})
        endif()
    elseif(enable_sync)
        # FIXME: Support building against prebuilt sync binaries.
        clone_and_build_realm_core("v${REALM_CORE_VERSION}")
        clone_and_build_realm_sync("v${REALM_SYNC_VERSION}")
    else()
        if(APPLE OR REALM_PLATFORM STREQUAL "Android" OR CMAKE_SYSTEM_NAME MATCHES "^Windows")
            download_realm_core(${REALM_CORE_VERSION})
        else()
            clone_and_build_realm_core("v${REALM_CORE_VERSION}")
        endif()
    endif()

    set(REALM_CORE_INCLUDE_DIR ${REALM_CORE_INCLUDE_DIR} PARENT_SCOPE)
    set(REALM_SYNC_INCLUDE_DIR ${REALM_SYNC_INCLUDE_DIR} PARENT_SCOPE)
endfunction()

function(download_realm_tarball url target libraries)
    get_filename_component(tarball_name "${url}" NAME)

    set(tarball_parent_directory "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")
    set(tarball_path "${tarball_parent_directory}/${tarball_name}")
    set(temp_tarball_path "/tmp/${tarball_name}")

    if (NOT EXISTS ${tarball_path})
        if (NOT EXISTS ${temp_tarball_path})
            message("Downloading ${url}.")
            file(DOWNLOAD ${url} ${temp_tarball_path}.tmp SHOW_PROGRESS)
            file(RENAME ${temp_tarball_path}.tmp ${temp_tarball_path})
        endif()
        file(COPY ${temp_tarball_path} DESTINATION ${tarball_parent_directory})
    endif()

    if(APPLE)
        add_custom_command(
            COMMENT "Extracting ${tarball_name}"
            OUTPUT ${libraries}
            COMMAND ${CMAKE_COMMAND} -E tar xf ${tarball_path}
            COMMAND ${CMAKE_COMMAND} -E remove_directory ${target}
            COMMAND ${CMAKE_COMMAND} -E rename core ${target}
            COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${libraries})
    elseif(REALM_PLATFORM STREQUAL "Android" OR CMAKE_SYSTEM_NAME MATCHES "^Windows")
        add_custom_command(
            COMMENT "Extracting ${tarball_name}"
            OUTPUT ${libraries}
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${target}"
            COMMAND "${CMAKE_COMMAND}" -E chdir "${target}" "${CMAKE_COMMAND}" -E tar xf "${tarball_path}"
            COMMAND "${CMAKE_COMMAND}" -E touch_nocreate ${libraries})
    endif()

endfunction()

macro(define_realm_core_target was_downloaded core_directory)
    if(${was_downloaded})
        set(library_directory "")
        set(include_directory "include/")
    else()
        set(library_directory "src/realm/")
        set(include_directory "src/")
    endif()
      
    if(CMAKE_SYSTEM_NAME MATCHES "^Windows")
        set(library_directory "lib")
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(core_platform "-x64")
        else()
            set(core_platform "-x86")
        endif()
    elseif(REALM_PLATFORM STREQUAL "Android")
        if(ANDROID_ABI STREQUAL "armeabi-v7a") # Realm Core still uses this name
            set(core_platform "-android-arm-v7a")
        else()
            set(core_platform "-android-${ANDROID_ABI}")
        endif()
    endif()

    set(core_library_debug ${core_directory}/${library_directory}/${CMAKE_STATIC_LIBRARY_PREFIX}realm${core_platform}-dbg${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(core_library_release ${core_directory}/${library_directory}/${CMAKE_STATIC_LIBRARY_PREFIX}realm${core_platform}${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(core_libraries ${core_library_debug} ${core_library_release})

    if(${was_downloaded})
        add_custom_target(realm-core DEPENDS ${core_libraries})
    else()
        ExternalProject_Add_Step(realm-core ensure-libraries
            COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${core_libraries}
            OUTPUT ${core_libraries}
            DEPENDEES build
            )
    endif()

    add_library(realm STATIC IMPORTED)
    add_dependencies(realm realm-core)
    set_property(TARGET realm PROPERTY IMPORTED_LOCATION_DEBUG ${core_library_debug})
    set_property(TARGET realm PROPERTY IMPORTED_LOCATION_COVERAGE ${core_library_debug})
    set_property(TARGET realm PROPERTY IMPORTED_LOCATION_RELEASE ${core_library_release})
    set_property(TARGET realm PROPERTY IMPORTED_LOCATION ${core_library_release})

    set_property(TARGET realm PROPERTY INTERFACE_LINK_LIBRARIES Threads::Threads ${CRYPTO_LIBRARIES})

    set(REALM_CORE_INCLUDE_DIR ${core_directory}/${include_directory} PARENT_SCOPE)
endmacro()

function(download_realm_core core_version)
    if(APPLE)
        set(basename "realm-core")
        set(compression "tar.xz")
        set(platform "")
    elseif(REALM_PLATFORM STREQUAL "Android")
        set(basename "realm-core-android")
        set(compression "tar.gz")
        if(ANDROID_ABI STREQUAL "armeabi-v7a")
            set(platform "-android-arm-v7a")
        else()
            set(platform "-android-${ANDROID_ABI}")
        endif()
    elseif(CMAKE_SYSTEM_NAME MATCHES "^Windows")
        set(basename "realm-core-windows")
        set(compression "zip")
        set(library_directory "lib")
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(platform "-x64")
        else()
            set(platform "-x86")
        endif()
    endif()
    set(tarball_name "${basename}-${core_version}.${compression}")
    set(url "https://static.realm.io/downloads/core/${tarball_name}")
    set(temp_tarball "/tmp/${tarball_name}")
    set(core_directory_parent "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")
    set(core_directory "${core_directory_parent}/realm-core-${core_version}")
    set(tarball "${core_directory_parent}/${tarball_name}")

    set(core_library_debug ${core_directory}/${library_directory}/${CMAKE_STATIC_LIBRARY_PREFIX}realm${platform}-dbg${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(core_library_release ${core_directory}/${library_directory}/${CMAKE_STATIC_LIBRARY_PREFIX}realm${platform}${CMAKE_STATIC_LIBRARY_SUFFIX})
    set(core_libraries ${core_library_debug} ${core_library_release})

    download_realm_tarball(${url} ${core_directory} "${core_libraries}")
    define_realm_core_target(YES ${core_directory})
endfunction()

function(download_realm_sync sync_version)
    if(APPLE)
        set(basename "realm-sync-cocoa")
        set(compression "xz")
        set(platform "")
    elseif(REALM_PLATFORM STREQUAL "Android")
        set(basename "realm-sync-android")
        set(compression "gz")
        if(ANDROID_ABI STREQUAL "armeabi-v7a")
            set(platform "-android-arm-v7a")
        else()
            set(platform "-android-${ANDROID_ABI}")
        endif()
    endif()
    set(tarball_name "${basename}-${sync_version}.tar.${compression}")
    set(url "https://static.realm.io/downloads/sync/${tarball_name}")
    set(temp_tarball "/tmp/${tarball_name}")
    set(sync_directory_parent "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}")
    set(sync_directory "${sync_directory_parent}/realm-sync-${sync_version}")
    set(tarball "${sync_directory_parent}/${tarball_name}")

    set(core_library_debug ${sync_directory}/librealm${platform}-dbg.a)
    set(core_library_release ${sync_directory}/librealm${platform}.a)
    set(core_libraries ${core_library_debug} ${core_library_release})

    download_realm_tarball(${url} ${sync_directory} "${core_libraries}")
    define_realm_core_target(YES ${sync_directory})

    add_library(realm-sync INTERFACE)
    add_dependencies(realm-sync realm)

    # FIXME: Where should we be getting librealm-sync-server.a from?
    # We can't build the unit tests with sync enabled without it.
    add_library(realm-sync-server INTERFACE)
    set_property(TARGET realm-sync-server PROPERTY INTERFACE_LINK_LIBRARIES ${SSL_LIBRARIES})
endfunction()

macro(build_realm_core)
    set(core_prefix_directory "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/realm-core")
    
    if(REALM_PLATFORM STREQUAL "Android")
        set(build_cmd sh build.sh build-android)
    else()
        set(build_cmd make -C src/realm librealm.a librealm-dbg.a ${MAKE_FLAGS})
    endif()

    ExternalProject_Add(realm-core
        PREFIX ${core_prefix_directory}
        BUILD_IN_SOURCE 1
        BUILD_COMMAND ${build_cmd}
        INSTALL_COMMAND ""
        CONFIGURE_COMMAND ""
        ${USES_TERMINAL_BUILD}
        ${ARGV}
        )
    ExternalProject_Get_Property(realm-core SOURCE_DIR)
    define_realm_core_target(NO ${SOURCE_DIR})
endmacro()

function(clone_and_build_realm_core branch)
    if(REALM_PLATFORM STREQUAL "Android")
        set(config_cmd REALM_ENABLE_ENCRYPTION=YES REALM_ENABLE_ASSERTIONS= sh build.sh config)
    else()
        set(config_cmd REALM_ENABLE_ENCRYPTION=YES REALM_ENABLE_ASSERTIONS=YES sh build.sh config)
    endif()
    build_realm_core(GIT_REPOSITORY "https://github.com/realm/realm-core.git"
                     GIT_TAG ${branch}
                     CONFIGURE_COMMAND test -f src/config.mk || ${config_cmd}
                     )
endfunction()

function(build_existing_realm_core core_directory)
    get_filename_component(core_directory ${core_directory} ABSOLUTE)
    set(core_prefix_directory "${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/realm-core")

    build_realm_core(URL ""
                     SOURCE_DIR ${core_directory}
                     BUILD_ALWAYS 1
                     )
endfunction()

macro(build_realm_sync)
    set(cmake_files ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
    if(REALM_PLATFORM STREQUAL "Android")
        set(build_cmd sh build.sh build-android)
    else()
        set(build_cmd make -C src/realm librealm-sync.a librealm-sync-dbg.a librealm-server.a librealm-server-dbg.a ${MAKE_FLAGS})
    endif()

    ExternalProject_Add(realm-sync-lib
        DEPENDS realm-core
        PREFIX ${cmake_files}/realm-sync
        BUILD_IN_SOURCE 1
        BUILD_COMMAND ${build_cmd}
        CONFIGURE_COMMAND ""
        INSTALL_COMMAND ""
        ${USES_TERMINAL_BUILD}
        ${ARGV}
        )

    if(APPLE)
        set(platform "")
    elseif(REALM_PLATFORM STREQUAL "Android")
        if(ANDROID_ABI STREQUAL "armeabi-v7a")
            set(platform "-android-arm-v7a")
        else()
            set(platform "-android-${ANDROID_ABI}")
        endif()
    endif()

    
    ExternalProject_Get_Property(realm-sync-lib SOURCE_DIR)
    set(sync_directory ${SOURCE_DIR})
    if(REALM_PLATFORM STREQUAL "Android")
        set(sync_library_directory ${sync_directory}/android-lib)
    else()
        set(sync_library_directory ${sync_directory}/src/realm)
    endif()
    
    set(sync_library_debug ${sync_library_directory}/librealm-sync${platform}-dbg.a)
    set(sync_library_release ${sync_library_directory}/librealm-sync${platform}.a)
    set(sync_libraries ${sync_library_debug} ${sync_library_release})

    ExternalProject_Add_Step(realm-sync-lib ensure-libraries
        COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${sync_libraries}
        OUTPUT ${sync_libraries}
        DEPENDEES build
        )

    add_library(realm-sync STATIC IMPORTED)
    add_dependencies(realm-sync realm-sync-lib)

    set_property(TARGET realm-sync PROPERTY IMPORTED_LOCATION_DEBUG ${sync_library_debug})
    set_property(TARGET realm-sync PROPERTY IMPORTED_LOCATION_COVERAGE ${sync_library_debug})
    set_property(TARGET realm-sync PROPERTY IMPORTED_LOCATION_RELEASE ${sync_library_release})
    set_property(TARGET realm-sync PROPERTY IMPORTED_LOCATION ${sync_library_release})

    set_property(TARGET realm-sync PROPERTY INTERFACE_LINK_LIBRARIES ${SSL_LIBRARIES})

    # Sync server library is built as part of the sync library build
    set(sync_server_library_debug ${sync_library_directory}/librealm-server${platform}-dbg.a)
    set(sync_server_library_release ${sync_library_directory}/librealm-server${platform}.a)
    set(sync_server_libraries ${sync_server_library_debug} ${sync_server_library_release})

    ExternalProject_Add_Step(realm-sync-lib ensure-server-libraries
        COMMAND ${CMAKE_COMMAND} -E touch_nocreate ${sync_server_libraries}
        OUTPUT ${sync_server_libraries}
        DEPENDEES build
        )

    add_library(realm-sync-server STATIC IMPORTED)
    add_dependencies(realm-sync-server realm-sync-lib)

    set_property(TARGET realm-sync-server PROPERTY IMPORTED_LOCATION_DEBUG ${sync_server_library_debug})
    set_property(TARGET realm-sync-server PROPERTY IMPORTED_LOCATION_COVERAGE ${sync_server_library_debug})
    set_property(TARGET realm-sync-server PROPERTY IMPORTED_LOCATION_RELEASE ${sync_server_library_release})
    set_property(TARGET realm-sync-server PROPERTY IMPORTED_LOCATION ${sync_server_library_release})

    find_package(PkgConfig)
    pkg_check_modules(YAML QUIET yaml-cpp)
    set_property(TARGET realm-sync-server PROPERTY INTERFACE_LINK_LIBRARIES ${SSL_LIBRARIES} ${YAML_LDFLAGS})

    set(REALM_SYNC_INCLUDE_DIR ${sync_directory}/src PARENT_SCOPE)
endmacro()

function(build_existing_realm_sync sync_directory)
    get_filename_component(sync_directory ${sync_directory} ABSOLUTE)
    build_realm_sync(URL ""
                     SOURCE_DIR ${sync_directory}
                     BUILD_ALWAYS 1
                     )

endfunction()

function(clone_and_build_realm_sync branch)
    set(cmake_files ${CMAKE_CURRENT_BINARY_DIR}${CMAKE_FILES_DIRECTORY})
    if(REALM_PLATFORM STREQUAL "Android")
        set(config_cmd test -f src/config.mk || REALM_CORE_PREFIX=${cmake_files}/realm-core/src/realm-core REALM_FORCE_OPENSSL=YES REALM_ENABLE_ASSERTIONS= sh build.sh config && echo "ENABLE_ENCRYPTION    = yes" >> src/config.mk)
    else()
        set(config_cmd test -f src/config.mk || REALM_CORE_PREFIX=${cmake_files}/realm-core/src/realm-core sh build.sh config)
    endif()

    build_realm_sync(GIT_REPOSITORY "git@github.com:realm/realm-sync.git"
                     GIT_TAG ${branch}
                     CONFIGURE_COMMAND ${config_cmd}
                     )

endfunction()
