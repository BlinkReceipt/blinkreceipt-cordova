#!/bin/bash

HERE="$(dirname "$(test -L "$0" && readlink "$0" || echo "$0")")"
pushd "${HERE}/../src/ios/" > /dev/null

VERSION=1.7.3
LINK="https://github.com/BlinkReceipt/blinkreceipt-ios/releases/download/${VERSION}/BlinkReceiptStatic.framework-${VERSION}.zip"

FILENAME='blinkreceipt-ios.zip'

wget --version > /dev/null 2>&1 || { echo "ERROR: Please install wget to download BlinkReceipt framework," &&  exit 1; }
wget -O "${FILENAME}" "${LINK}" -nv --show-progress || ( echo "ERROR: Couldn't download BlinkReceipt framework, something went wrong while downloading framework from ${LINK}" && exit 1 )

echo "Unzipping ${FILENAME}"
unzip -v > /dev/null 2>&1 || { echo "ERROR: Couldn't unzip BlinkReceipt framework, please install unzip" && exit 1; }
unzip -o "${FILENAME}" > /dev/null 2>&1 && echo "Unzipped ${FILENAME}"

mkdir libs

mv -f BlinkReceiptStatic.framework libs/BlinkReceiptStatic.framework

echo "Removing unnecessary files"

rm "${FILENAME}" >/dev/null 2>&1

popd