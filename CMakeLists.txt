cmake_minimum_required(VERSION 3.25)

project(atsp2k LANGUAGES Fortran)

include(GNUInstallDirs)

find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)

set(_atsp2k_bin_dir "${CMAKE_CURRENT_BINARY_DIR}/bin")
set(ATSP2K_EXECUTABLE_DIR "${_atsp2k_bin_dir}" CACHE INTERNAL "ATSP2K executable directory")

function(atsp2k_apply_legacy_fortran_options target_name)
    set_target_properties(
        "${target_name}"
        PROPERTIES
            Fortran_FORMAT FIXED
    )

    if(CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
        target_compile_options(
            "${target_name}"
            PRIVATE
                -std=legacy
                -fallow-argument-mismatch
                -fallow-invalid-boz
                -fcray-pointer
                -fno-automatic
                -fno-range-check
        )
    endif()
endfunction()

function(atsp2k_filter_sources output_variable source_directory)
    file(GLOB _sources CONFIGURE_DEPENDS "${source_directory}/*.f")
    foreach(_exclude_pattern IN LISTS ARGN)
        list(FILTER _sources EXCLUDE REGEX "${_exclude_pattern}")
    endforeach()
    set("${output_variable}" ${_sources} PARENT_SCOPE)
endfunction()

function(atsp2k_add_library target_name)
    add_library("${target_name}" STATIC ${ARGN})
    atsp2k_apply_legacy_fortran_options("${target_name}")
endfunction()

function(atsp2k_add_executable target_name output_name)
    add_executable("${target_name}" ${ARGN})
    atsp2k_apply_legacy_fortran_options("${target_name}")
    set_target_properties(
        "${target_name}"
        PROPERTIES
            OUTPUT_NAME "${output_name}"
            RUNTIME_OUTPUT_DIRECTORY "${_atsp2k_bin_dir}"
    )
    install(TARGETS "${target_name}" RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
endfunction()

atsp2k_filter_sources(
    _atsp2k_libcom_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/src/lib/libcom"
    ".*/alloc_IBMSP\\.f$"
    ".*/alloc_LINUX_32\\.f$"
    ".*/alloc_LINUX_64\\.f$"
    ".*/dalloc_IBMSP\\.f$"
    ".*/realloc_IBMSP\\.f$"
)
atsp2k_add_library(atsp2k_com ${_atsp2k_libcom_sources})

atsp2k_filter_sources(
    _atsp2k_librad_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/src/lib/librad"
    ".*/rlshft_AZ\\.f$"
)
atsp2k_add_library(atsp2k_rad ${_atsp2k_librad_sources})

atsp2k_filter_sources(
    _atsp2k_libdvdson_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/src/lib/libdvdson"
    ".*/driver\\.f$"
)
atsp2k_add_library(atsp2k_dvdson ${_atsp2k_libdvdson_sources})

set(_atsp2k_libnet_names
    dlagtf dlanst dlarnv dlasr dopmtr dstebz ilaenv dlae2 dlagts dlapy2
    dlartg dlasrt dorg2l dstein lsame dlaebz dlarf dspmv dlascl dlassq
    dorg2r dsteqr dlaev2 dlansp dlarfg dlaset dopgtr dsptrd dsterf xerbla
    ieeeck dlaruv dlamch slamch dger dasum dspr2
)
set(_atsp2k_libnet_sources)
foreach(_source_name IN LISTS _atsp2k_libnet_names)
    list(APPEND _atsp2k_libnet_sources "${CMAKE_CURRENT_SOURCE_DIR}/src/lib/libnet/${_source_name}.f")
endforeach()
atsp2k_add_library(atsp2k_net ${_atsp2k_libnet_sources})

atsp2k_filter_sources(
    _atsp2k_libang_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/src/lib/libang"
)
atsp2k_add_library(atsp2k_ang ${_atsp2k_libang_sources})

atsp2k_add_executable(atsp2k_hf hf "${CMAKE_CURRENT_SOURCE_DIR}/src/util/hf.f")

atsp2k_add_executable(atsp2k_lsgen lsgen "${CMAKE_CURRENT_SOURCE_DIR}/src/util/lsgen.f")
target_link_libraries(atsp2k_lsgen PRIVATE atsp2k_com atsp2k_rad atsp2k_ang atsp2k_com)

atsp2k_add_executable(atsp2k_w_format w_format "${CMAKE_CURRENT_SOURCE_DIR}/src/util/w_format.f")
atsp2k_add_executable(atsp2k_w_unformat w_unformat "${CMAKE_CURRENT_SOURCE_DIR}/src/util/w_unformat.f")

atsp2k_filter_sources(
    _atsp2k_lsreduce_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/src/appl/lsreduce"
)
atsp2k_add_executable(atsp2k_lsreduce lsreduce ${_atsp2k_lsreduce_sources})
target_link_libraries(
    atsp2k_lsreduce
    PRIVATE
        atsp2k_com
        atsp2k_dvdson
        atsp2k_ang
        atsp2k_rad
        atsp2k_com
)

set(_atsp2k_nonh_names
    nonh angmomg genint orbitals isearch ltriang savels ffgg analy_blk cfgblk
)
set(_atsp2k_nonh_sources)
foreach(_source_name IN LISTS _atsp2k_nonh_names)
    list(APPEND _atsp2k_nonh_sources "${CMAKE_CURRENT_SOURCE_DIR}/src/appl/nonh/${_source_name}.f")
endforeach()
atsp2k_add_executable(atsp2k_nonh nonh ${_atsp2k_nonh_sources})
target_link_libraries(
    atsp2k_nonh
    PRIVATE
        atsp2k_com
        atsp2k_dvdson
        atsp2k_ang
        atsp2k_rad
        atsp2k_com
)

set(_atsp2k_mchf_names
    mchf alloc_mem data de diag diff dinit dssbmv e eig_out eijset grange
    methd1 nmrvs nodec orthog output potl quad scale scf search solve spintgrl
    summry unpacki update wavefn xch diag_hmx supdatc prprty print_memory
    alcsts_LINUX diag_allocate_LINUX diag_deallocate_LINUX
)
set(_atsp2k_mchf_sources)
foreach(_source_name IN LISTS _atsp2k_mchf_names)
    list(APPEND _atsp2k_mchf_sources "${CMAKE_CURRENT_SOURCE_DIR}/src/appl/mchf/${_source_name}.f")
endforeach()
atsp2k_add_executable(atsp2k_mchf mchf ${_atsp2k_mchf_sources})
target_link_libraries(
    atsp2k_mchf
    PRIVATE
        atsp2k_dvdson
        atsp2k_rad
        atsp2k_com
        atsp2k_net
        ${LAPACK_LIBRARIES}
        ${BLAS_LIBRARIES}
)

add_custom_target(
    atsp2k_serial_tools
    DEPENDS
        atsp2k_hf
        atsp2k_lsgen
        atsp2k_lsreduce
        atsp2k_nonh
        atsp2k_mchf
        atsp2k_w_format
        atsp2k_w_unformat
)
