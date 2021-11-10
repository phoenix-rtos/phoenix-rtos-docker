# Changelog

## 20211105 (latest)
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
