#!/bin/bash

set -e

lib_name="metadata_shortener"
output_dir="./xcframework"
release_dir="./target"

rm -rf $output_dir
mkdir -p $output_dir

echo "Building .a libraries"

cargo build --release --target aarch64-apple-darwin
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim

# We need single folder with headers to put module map within it
headers_temp_dir="./metadata-shortener/headers"
mkdir -p $headers_temp_dir
cp "./metadata-shortener/Generated/SwiftBridgeCore.h" $headers_temp_dir
cp "./metadata-shortener/Generated/metadata-shortener/metadata-shortener.h" $headers_temp_dir

echo "Copied headers to temporary folder: $headers_temp_dir"

# Create module.modulemap file
cat <<EOF >$headers_temp_dir/module.modulemap
module ${lib_name} {
    header "SwiftBridgeCore.h"
    header "metadata-shortener.h"
    export *
}
EOF

echo "Created module map at: $headers_temp_dir/module.modulemap"

# Here we need 2 lines (-library and -headers) for each architecture
xcodebuild -create-xcframework \
    -library "${release_dir}/aarch64-apple-ios/release/lib${lib_name}.a" \
    -headers $headers_temp_dir \
    -library "${release_dir}/aarch64-apple-ios-sim/release/lib${lib_name}.a" \
    -headers $headers_temp_dir \
    -library "${release_dir}/aarch64-apple-darwin/release/lib${lib_name}.a" \
    -headers $headers_temp_dir \
    -output "$output_dir/${lib_name}.xcframework"

echo "XCFramework created at $output_dir/${lib_name}.xcframework"

rm -rf $headers_temp_dir

echo "Cleanup finished"