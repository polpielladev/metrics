#!/bin/bash

set -eu

product=$1

# Compile using a docker instance
docker run \
    --rm \
    --volume "$(pwd)/:/src" \
    --workdir "/src/" \
    swift:5.7-amazonlinux2 \
    swift build --product $product -c release -Xswiftc -static-stdlib

# Package into a `.zip` file for upload
# This script is available at:
# https://fabianfett.dev/getting-started-with-swift-aws-lambda-runtime

target=.build/lambda/$product
rm -rf "$target"
mkdir -p "$target"
cp ".build/release/$product" "$target/"
cd "$target"
ln -s "$product" "bootstrap"
zip --symlinks lambda.zip *
