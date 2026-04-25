cmake_minimum_required(VERSION 3.22.1)

project(hideport LANGUAGES C ASM)

set(HIDEPORT_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}/src")
set(HIDEPORT_MODULE_BIN_DIR "${CMAKE_CURRENT_LIST_DIR}/system/bin")

set(BPF_CLANG "clang" CACHE FILEPATH "Host clang with BPF target support")
set(BPFTOOL "bpftool" CACHE FILEPATH "Host bpftool executable")
set(VMLINUX_H "${HIDEPORT_SRC_DIR}/vmlinux.h" CACHE FILEPATH "Target device generated vmlinux.h")
set(LIBBPF_INCLUDE_DIR "" CACHE PATH "Directory containing bpf/libbpf.h")
set(LIBBPF_LIBRARY "" CACHE FILEPATH "Android arm64 libbpf.a")
set(LIBELF_LIBRARY "" CACHE FILEPATH "Android arm64 libelf.a")
set(ZLIB_LIBRARY "" CACHE FILEPATH "Android arm64 libz.a")
set(EXTRA_LOADER_LIBS "" CACHE STRING "Extra static libraries for hideport_loader")

if(NOT CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    message(FATAL_ERROR "hideport only supports arm64-v8a in this configuration")
endif()

if(NOT EXISTS "${VMLINUX_H}")
    message(FATAL_ERROR "Missing ${VMLINUX_H}. Generate it from the target Android kernel BTF first.")
endif()

if(NOT LIBBPF_INCLUDE_DIR)
    message(FATAL_ERROR "Set LIBBPF_INCLUDE_DIR to the libbpf headers directory")
endif()

foreach(required_lib LIBBPF_LIBRARY LIBELF_LIBRARY ZLIB_LIBRARY)
    if(NOT EXISTS "${${required_lib}}")
        message(FATAL_ERROR "Set ${required_lib} to an Android arm64 static library")
    endif()
endforeach()

file(MAKE_DIRECTORY "${HIDEPORT_MODULE_BIN_DIR}")

set(HIDEPORT_BPF_OBJECT "${HIDEPORT_MODULE_BIN_DIR}/hideport.bpf.o")
set(HIDEPORT_SKEL "${HIDEPORT_SRC_DIR}/hideport.skel.h")

add_custom_command(
    OUTPUT "${HIDEPORT_BPF_OBJECT}"
    COMMAND "${BPF_CLANG}"
        -target bpf
        -D__TARGET_ARCH_arm64
        -g
        -O2
        -I"${HIDEPORT_SRC_DIR}"
        -I"${LIBBPF_INCLUDE_DIR}"
        -c "${HIDEPORT_SRC_DIR}/hideport.bpf.c"
        -o "${HIDEPORT_BPF_OBJECT}"
    DEPENDS "${HIDEPORT_SRC_DIR}/hideport.bpf.c" "${VMLINUX_H}"
    VERBATIM
)

add_custom_command(
    OUTPUT "${HIDEPORT_SKEL}"
    COMMAND "${CMAKE_COMMAND}"
        -DBPFTOOL="${BPFTOOL}"
        -DINPUT="${HIDEPORT_BPF_OBJECT}"
        -DOUTPUT="${HIDEPORT_SKEL}"
        -P "${CMAKE_CURRENT_LIST_DIR}/cmake/GenSkeleton.cmake"
    DEPENDS "${HIDEPORT_BPF_OBJECT}"
    VERBATIM
)

add_custom_target(hideport_bpf ALL DEPENDS "${HIDEPORT_BPF_OBJECT}" "${HIDEPORT_SKEL}")

add_executable(
    hideport_loader
    "${HIDEPORT_SRC_DIR}/hideport_loader.c"
    "${HIDEPORT_SRC_DIR}/tls_align.S"
    "${HIDEPORT_SKEL}"
)
add_dependencies(hideport_loader hideport_bpf)
target_include_directories(hideport_loader PRIVATE "${HIDEPORT_SRC_DIR}" "${LIBBPF_INCLUDE_DIR}")
target_link_libraries(
    hideport_loader
    PRIVATE
    "${LIBBPF_LIBRARY}"
    "${LIBELF_LIBRARY}"
    "${ZLIB_LIBRARY}"
    ${EXTRA_LOADER_LIBS}
)

add_custom_command(
    TARGET hideport_loader
    POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E copy "$<TARGET_FILE:hideport_loader>" "${HIDEPORT_MODULE_BIN_DIR}/hideport_loader"
    VERBATIM
)
