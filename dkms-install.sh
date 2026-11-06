#!/bin/sh
# Install the driver with DKMS, so it is rebuilt for every new kernel.
# Usage: sudo ./dkms-install.sh            (for the running kernel)
#        sudo KERNELVER=<version> ./dkms-install.sh
set -e
[ "$(id -u)" -eq 0 ] || exec sudo KERNELVER="$KERNELVER" "$0" "$@"
cd "$(dirname "$0")"

NAME=$(sed -n 's/^PACKAGE_NAME="\(.*\)"/\1/p' dkms.conf)
VERSION=$(sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)
SRC="/usr/src/$NAME-$VERSION"

# Replace an earlier install of the same version.
if dkms status -m "$NAME" -v "$VERSION" | grep -q .; then
	dkms remove -m "$NAME" -v "$VERSION" --all
fi
rm -rf "$SRC"
mkdir -p "$SRC"
cp dkms.conf Makefile Kbuild ./*.c "$SRC"/

dkms add -m "$NAME" -v "$VERSION"
dkms install -m "$NAME" -v "$VERSION" ${KERNELVER:+-k "$KERNELVER"}
