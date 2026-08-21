#!/bin/bash

required_tools=("curl" "wget" "tar" "jq")
for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is required but not installed. Aborting."
        exit 1
    fi
done

if ! python3 -c "import PySide6" &> /dev/null; then
    echo "pyside6 is required but not installed. Aborting."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_DIR="$(dirname "$SCRIPT_DIR")"
TARGET_DIR="$MAIN_DIR/resources"
LAUNCHER_DIR="$MAIN_DIR/launcher"

cd "$SCRIPT_DIR" || exit
mkdir -p "$TARGET_DIR"

TEMURIN_API_URL="https://api.github.com/repos/adoptium/temurin17-binaries/releases/latest"
TEMURIN_DOWNLOAD_URL=$(curl -s "$TEMURIN_API_URL" | jq -r '.assets[] | select(.name | contains("jdk_x64_linux_hotspot") and endswith(".tar.gz")).browser_download_url')
TEMURIN_FILENAME=$(basename "$TEMURIN_DOWNLOAD_URL")

EXPECTED_DIR=$(echo "$TEMURIN_FILENAME" | sed 's/OpenJDK17U-jdk_x64_linux_hotspot_//; s/\.tar\.gz//; s/_/+/')
EXPECTED_DIR_PATH="$TARGET_DIR/jdk-$EXPECTED_DIR"

if [ ! -d "$EXPECTED_DIR_PATH" ]; then
    echo "Downloading latest Temurin JDK..."
    wget -O "$TARGET_DIR/$TEMURIN_FILENAME" "$TEMURIN_DOWNLOAD_URL"
    tar xfv "$TARGET_DIR/$TEMURIN_FILENAME" -C "$TARGET_DIR"
    rm "$TARGET_DIR/$TEMURIN_FILENAME"
fi

version_greater() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | tail -n 1)" == "$1" ]
}

newest_temurin=""
for dir in "$TARGET_DIR"/jdk-*; do
    if [[ -d "$dir" ]]; then
        current_version="${dir#"$TARGET_DIR"/jdk-}"
        if [[ -z "$newest_temurin" || $(version_greater "$current_version" "${newest_temurin#"$TARGET_DIR"/jdk-}") ]]; then
            newest_temurin="$dir"
        fi
    fi
done

for dir in "$TARGET_DIR"/jdk-*; do
    if [[ -d "$dir" && "$dir" != "$newest_temurin" ]]; then
        echo "Removing older directory: $dir"
        rm -rf "$dir"
    fi
done

echo "Newest Temurin JDK retained: $newest_temurin"

cd ..

if [ -f "$HOME/.config/user-dirs.dirs" ]; then
    source "$HOME/.config/user-dirs.dirs"
    DESKTOP_PATH="${XDG_DESKTOP_DIR:-$HOME/Desktop}"
else
    DESKTOP_PATH="$HOME/Desktop"
fi

DESKTOP_FILE="$DESKTOP_PATH/cultris2.desktop"

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=9.5
Type=Application
Name=Cultris II Patch Launcher
Path=$MAIN_DIR
Exec=/usr/bin/python3 "$MAIN_DIR/c2-launcher.py"
Icon=$MAIN_DIR/launcher/resources/icon.png
Terminal=false
Categories=Game;
EOF

chmod +x "$DESKTOP_FILE"
echo "Shortcut created at $DESKTOP_PATH"

echo "Done!"
