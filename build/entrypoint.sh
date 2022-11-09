#!/bin/bash

if [ "$(id -u)" = '0' ]; then
	echo "Running as root! Changing user to builder and matching uid/gid with a host"
	HOST_UID=$(stat -c "%u" .)
	HOST_GID=$(stat -c "%g" .)
	BUILDER_UID="$(id -u builder)"
	BUILDER_GID="$(id -g builder)"

	usermod -u "$HOST_UID" -o builder
	groupmod -g "$HOST_GID" -o builder

	COMPILER=""
	if [[ "$TARGET" == arm* ]]; then
		COMPILER="arm-phoenix"
	elif [[ "$TARGET" == ia32* ]]; then
		COMPILER="i386-pc-phoenix"
	elif [[ "$TARGET" == riscv64* ]]; then
		COMPILER="riscv64-phoenix"
	fi

	if [ -n "$COMPILER" ]; then
		echo "Fixing compiler headers permissions"
		chown -R builder:builder /opt/phoenix/"$COMPILER"/"$COMPILER"/usr/include
	fi

	exec gosu builder "$0" "$@"
fi

# CI: support building submodule out-of tree (CI_CUSTOM_BUILDROOT is a path to phoenix-rtos-project with submodule as a symlink)
if [ -n "$CI_CUSTOM_BUILDROOT" ]; then
       ln -sf "$(pwd)/$CI_CUSTOM_BUILDROOT"/phoenix-rtos-build ../phoenix-rtos-build
       cd "$CI_CUSTOM_BUILDROOT" || exit 1
fi

exec ./phoenix-rtos-build/build.sh "$@"
