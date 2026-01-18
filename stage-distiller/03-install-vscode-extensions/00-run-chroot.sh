#!/bin/bash -e
# Install VS Code extensions from Open VSX into code-server

# Format: "namespace:name:platform:strict"
# - platform: linux-arm64, universal, or empty (tries arm64 first, falls back to universal)
# - strict: if "strict", fail if platform-specific not found (no fallback)
EXTENSIONS=(
    "Anthropic:claude-code:linux-arm64:strict"
    "njzy:stats-bar"
    "pamir-ai:device-manager"
    "pamir-ai:pamir-welcome"
    "pamir-ai:distiller-ports"
    "pamir-ai:distiller-messaging"
)

TARGET_PLATFORM="linux-arm64"
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

download_and_install() {
    local namespace="$1" name="$2" platform="$3" strict="$4"
    local api_url download_url version metadata

    # Try platform-specific first unless explicitly "universal"
    if [ "$platform" != "universal" ]; then
        local try_platform="${platform:-$TARGET_PLATFORM}"
        api_url="https://open-vsx.org/api/$namespace/$name/$try_platform"
        echo "Fetching $namespace.$name ($try_platform) from Open VSX..."
        metadata=$(curl -sf "$api_url")

        # If strict mode and platform-specific not found, fail immediately
        if [ -z "$metadata" ] && [ "$strict" = "strict" ]; then
            echo "ERROR: $namespace.$name requires $try_platform but not available on Open VSX"
            return 1
        fi
    fi

    # Fallback to universal if platform-specific not found (and not strict)
    if [ -z "$metadata" ]; then
        api_url="https://open-vsx.org/api/$namespace/$name"
        echo "Fetching $namespace.$name (universal) from Open VSX..."
        metadata=$(curl -sf "$api_url")
    fi

    if [ -z "$metadata" ]; then
        echo "WARN: Failed to fetch metadata for $namespace.$name"
        return 1
    fi

    download_url=$(echo "$metadata" | grep -o '"download":"[^"]*"' | head -1 | cut -d'"' -f4)
    version=$(echo "$metadata" | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -z "$download_url" ]; then
        echo "WARN: No download URL for $namespace.$name"
        return 1
    fi

    local vsix_file="$TEMP_DIR/$namespace.$name-$version.vsix"
    echo "Downloading $namespace.$name v$version..."
    curl -Lf -o "$vsix_file" "$download_url"

    echo "Installing $namespace.$name..."
    su - "${FIRST_USER_NAME}" -c "code-server --install-extension '$vsix_file'" || {
        echo "WARN: Failed to install $namespace.$name"
        return 1
    }
    echo "OK: $namespace.$name installed"
}

echo "Installing VS Code extensions for user: ${FIRST_USER_NAME}"

for ext in "${EXTENSIONS[@]}"; do
    IFS=':' read -r namespace name platform strict <<< "$ext"
    if [ "$strict" = "strict" ]; then
        # Strict extensions must succeed or build fails
        download_and_install "$namespace" "$name" "$platform" "$strict"
    else
        # Non-strict extensions can fail gracefully
        download_and_install "$namespace" "$name" "$platform" "$strict" || true
    fi
done

echo "VS Code extension installation complete"
