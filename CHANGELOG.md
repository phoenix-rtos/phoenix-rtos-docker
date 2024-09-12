# Changelog

## NEXT VERSION

* build: install python3-jinja2 as global dependency

## 20240827 (latest)

* **GCC version: 9.5.0**
* devel: add qemu-system-sparc v9.0.2
* devel: add qemu-system-arm v9.0.2
* phoenix-rtos-project commit:
  * devel image: `d0f17a4`
  * build image: `4167633`

## 20240625

* **GCC version: 9.5.0**
* build: install python3 and python3-yaml as global dependencies
* phoenix-rtos-project commit: `4167633`

## v3.2.2

* **GCC version: 9.5.0**
* phoenix-rtos-project commit: `v3.2.2` (`d7f4535`)

## 20240502

* **GCC version: 9.5.0**
* built: fix arm toolchain (.data layout in PIC mode)
* phoenix-rtos-project commit: `6f87c3f`

## v3.2.1

* **GCC version: 9.5.0**
* phoenix-rtos-project commit: `v3.2.1` (`df4e848`)

## 20240314

* **GCC version: 9.5.0**
* devel, gh-runner: pull requirements for test runner from requirements.txt
* devel, gh-runner: bump jlink version
* gh-runner: fix net-tools
* phoenix-rtos-project commit:
  * devel image: `a2f1e41`
  * build image: `04a14d3`

## 20240228

* **old version release - GCC version: 7.1.0**
* on branch release/gcc7-1
* phoenix-rtos-project commit `28e0aba`

## 20240221

* **GCC version: 9.5.0**
* phoenix-rtos-project commit `04a14d3`

## 20231204

* **GCC version: 9.5.0**
* devel: add tini (init system)
* devel, gh-runner: add net-tools
* phoenix-rtos-project commit:
  * devel image: `b947c7a`
  * build image: `5c6d72a`

## 20230920

* **GCC version: 9.5.0**
* gh-runner: support arm64 target architecture
* build: fix `sparc-phoenix` toolchain linking spec
* build: make `sparc-phoenix` multilib
* phoenix-rtos-project commit `5c6d72a`

## 20230918

* **GCC version: 9.5.0**
* **`build`, `devel` images won't be published for ARMv7 arch anymore**
* build: add sparc-phoenix toolchain
* build: support fully-external sysroot in all toolchains
* devel: update xilinx qemu to 2023.1
* devel: update how host tools are built
* devel, gh-runner: add support for am64 JLink tools, use explicit version
* all: add option to build with specific phoenix-rtos-project reference
* gh-runner: don't depend on `devel` image, use multi-stage build instead
* phoenix-rtos-project commit `6ece28c`

## 20230830

* **GCC version: 9.3.0**
* devel: add junitparser python package
* phoenix-rtos-project commit
  * devel image: `3a54d36`
  * build image: `e8b8ba5`

## 20230711

* **GCC version: 9.3.0**
* devel: add colorama package
* phoenix-rtos-project commit
  * devel image: `7496f4a`
  * build image: `e8b8ba5`

## 20230522

* **GCC version: 9.3.0**
* devel: update host utils
* phoenix-rtos-project commit
  * devel image: `2346a35`
  * build image: `e8b8ba5`

## 20230323

* **GCC version: 9.3.0**
* devel: update host utils
* phoenix-rtos-project commit: `e8b8ba5`

## 20230313

* **GCC version: 9.3.0**
* build: add bear tool
* build: update base ubuntu image to 22.04
* devel: update base ubuntu image to 22.04
* devel: update openocd to v0.12
* devel: update xilinx qemu to 2022.2
* toolchain: add libstdc++ building (full C++ support)
* add Thread Local Storage libphoenix implementation
* phoenix-rtos-project commit: `e8b8ba5`

## 20230117

* **GCC version: 9.3.0**
* devel: add openocd 0.11 with required tools
* phoenix-rtos-project commit: `e5b6904`

## 20220926

* **GCC version: 9.3.0**
* build: add custom entrypoint script for CI use-case (submodule out-of-tree building)
* phoenix-rtos-project commit: `e5b6904`

## 20220923

* **GCC version: 9.3.0**
* devel: add gdb-multiarch and jlink tools
* fix `git safe.directory` complaint
* phoenix-rtos-project commit: `e5b6904`

## 20220919

* **GCC version: 9.3.0**
* add `cmake`
* replace `vim-tiny` with `vim` because of the conflicts in base ubuntu 20.04 armv7 image
* add Thread Local Storage to the toolchain
* phoenix-rtos-project commit: `e5b6904`

## 20211115

* **GCC version: 9.3.0**
* add building qemu from Xilinx
* phoenix-rtos-project commit: `692db63`

## 20211105

* **GCC version: 9.3.0**
* images are now multi-architecture (linux/arm/v7, linux/amd64)
* phoenix-rtos-project commit: `692db63`

## 20210930

* **GCC version: 9.3.0**
* docker image is considerably smaller due to additional binaries stripping
* phoenix-rtos-project commit: `330f76c`

## 20210825

* **GCC version: 9.3.0**
* crtstuff on Cortex-M arch is relocatable
* first step for moving libc header files `${sysroot}/usr/include` -> `${sysroot}/include`
* phoenix-rtos-project commit: `52a3c74`

## 20210625

* **GCC version: 9.3.0**
* add stage2 compiler building (incorrect `limits.h` fixed)
* add bare C++ support (no libstdc++ yet)
* kernel headers and libphoenix embedded in the image

## 20210406

* **GCC version: 9.3.0**
* add `phoenixrtos/devel` image with developer-related set of tools (needed for automatic testing)

## 20201019

* **GCC version: 9.3.0**
* initial release: bare compilers and some tools needed for building
