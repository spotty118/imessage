#!/bin/bash
# Improved shebang to explicitly use bash due to advanced features used in the script

build_tags=""

# Use a more reliable method to detect architecture
arch=$(uname -m)
echo "Detected architecture: $arch"

# Setting default paths
default_lib_path="/usr/local/lib"
default_include_path="/usr/local/include"

# Check for arm64 architecture and the existence of /opt/homebrew
if [[ "$arch" == "arm64" && -d /opt/homebrew ]]; then
    echo "Using /opt/homebrew for library paths"
    export LIBRARY_PATH=${LIBRARY_PATH:-/opt/homebrew/lib}
    export CPATH=${CPATH:-/opt/homebrew/include}
    HEIF_PATH="$LIBRARY_PATH"
else
    HEIF_PATH="$default_lib_path"
    export LIBRARY_PATH=${LIBRARY_PATH:-$default_lib_path}
    export CPATH=${CPATH:-$default_include_path}
fi

# Check for libheif
if [[ -f "$HEIF_PATH/libheif.1.dylib" ]]; then
    echo "libheif found in $HEIF_PATH, compiling with heif support"
    build_tags="libheif"
else
    echo "libheif not found in $HEIF_PATH, compiling without heif support"
fi

# Building with determined tags and ldflags
go build -tags "$build_tags" -ldflags "-X main.Tag=$(git describe --exact-match --tags 2>/dev/null) -X main.Commit=$(git rev-parse HEAD) -X 'main.BuildTime=$(date '+%b %_d %Y, %H:%M:%S')'"

# Check for successful build
if [[ $? -eq 0 ]]; then
    echo "Build completed successfully."
else
    echo "Build failed."
    exit 1
fi
