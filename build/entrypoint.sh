#!/bin/bash

# CI: support building submodule out-of tree (CI_CUSTOM_BUILDROOT is a path to phoenix-rtos-project with submodule as a symlink)
if [ -n "$CI_CUSTOM_BUILDROOT" ]; then
       ln -sf "$(pwd)/$CI_CUSTOM_BUILDROOT"/phoenix-rtos-build ../phoenix-rtos-build
       cd "$CI_CUSTOM_BUILDROOT" || exit 1
fi

exec ./phoenix-rtos-build/build.sh "$@"
