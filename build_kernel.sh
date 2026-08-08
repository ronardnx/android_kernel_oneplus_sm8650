#!/bin/bash

echo -e "===== BUILD STARTED =====\n"

export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export SUBARCH=arm64

export ANDROID_VER="android14"
export KBUILD_BUILD_USER="@ronardnx"
export UNAME="MiaKhalifa"

# timestamp
export KBUILD_BUILD_TIMESTAMP="Tue May 5 22:32:00 UTC 2026"

# Directories
mkdir -p "${KERNEL_ROOT}/out" "${KERNEL_ROOT}/build"

# Clang toolchain path
export PATH="$HOME/clang-17/clang-r487747c/bin:${PATH}"

# export
export LLVM=1
export LLVM_IAS=1
export CC=clang
export HOSTCC=clang
export HOSTCXX=clang++

export CROSS_COMPILE=aarch64-linux-gnu-

export LD=ld.lld
export HOSTLD=ld.lld

export AR=llvm-ar
export NM=llvm-nm
export OBJCOPY=llvm-objcopy
export OBJDUMP=llvm-objdump
export STRIP=llvm-strip

CUSTOM_LOCALVERSION="-$ANDROID_VER-$UNAME"

export OUT=out

echo -e "===== CLEAN ABI EXPORTS =====\n"
rm -f android/abi_gki_protected_exports_*

mkdir -p "$OUT"

# scm
: > .scmversion

echo -e "===== GENERATING CONFIG =====\n"

# Defconfig
make O="$OUT" \
gki_defconfig \
vendor/pineapple_GKI.config \
vendor/oplus/pineapple_GKI.config

# Olddefconfig
make O="$OUT" olddefconfig

scripts/config --file "${KERNEL_ROOT}/out/.config" \
--set-str LOCALVERSION "$CUSTOM_LOCALVERSION"

scripts/config --file "${KERNEL_ROOT}/out/.config" \
-d LOCALVERSION_AUTO

echo -e "===== COMPILING KERNEL =====\n"

# Final Build
make O="$OUT" -j$(nproc) 2>&1 | tee build.log || exit 1

# Fresh build directory
rm -rf "${KERNEL_ROOT}/build"
mkdir -p "${KERNEL_ROOT}/build"

if [ -f "${KERNEL_ROOT}/out/arch/arm64/boot/Image" ]; then
    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" "${KERNEL_ROOT}/build/"
    echo -e "\n✅ Kernel Image copied to build/ successfully!"
else
    echo -e "\n❌ Error: Kernel Image not found!"
    exit 1
fi

echo -e "\n===== BUILD FINISHED =====\n"
