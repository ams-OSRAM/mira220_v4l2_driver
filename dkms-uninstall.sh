#!/bin/sh
# Remove the driver from DKMS and from every kernel it was built for.
set -e
[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
cd "$(dirname "$0")"

NAME=$(sed -n 's/^PACKAGE_NAME="\(.*\)"/\1/p' dkms.conf)
VERSION=$(sed -n 's/^PACKAGE_VERSION="\(.*\)"/\1/p' dkms.conf)

dkms remove -m "$NAME" -v "$VERSION" --all
rm -rf "/usr/src/$NAME-$VERSION"
