#!/bin/bash
set -e

# Configuration
APP_NAME="MemosMenuBar"
BUNDLE_ID="com.memos.menubar"
VERSION="1.0"
MIN_MACOS="13.0"

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/MemosMenuBar"
BUILD_DIR="$PROJECT_DIR/.build/release"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"

echo "🔨 Building $APP_NAME..."

# 1. Build release
cd "$PROJECT_DIR"
swift build -c release

# 2. Create app bundle structure
echo "📦 Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# 3. Copy executable
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# 4. Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>Memos Menu Bar</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_MACOS</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>de</string>
        <string>es</string>
        <string>fr</string>
        <string>tr</string>
    </array>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

# 5. Copy resource bundle (contains localizations)
RESOURCE_BUNDLE=$(find "$BUILD_DIR" -name "*.bundle" -type d | head -1)
if [ -n "$RESOURCE_BUNDLE" ] && [ -d "$RESOURCE_BUNDLE" ]; then
    echo "📂 Copying resource bundle..."
    cp -r "$RESOURCE_BUNDLE" "$APP_BUNDLE/Contents/Resources/"
fi

# 6. Copy localization files
echo "🌍 Copying localizations..."
for LPROJ in "$PROJECT_DIR/Sources/Resources"/*.lproj; do
    if [ -d "$LPROJ" ]; then
        cp -r "$LPROJ" "$APP_BUNDLE/Contents/Resources/"
    fi
done

# 7. Create .icns from AppIcon assets using iconutil
echo "🎨 Creating app icon..."
ICONSET_DIR="/tmp/AppIcon.iconset"
APPICONSET_DIR="$PROJECT_DIR/Sources/Resources/Assets.xcassets/AppIcon.appiconset"
if [ -d "$APPICONSET_DIR" ]; then
    rm -rf "$ICONSET_DIR"
    mkdir -p "$ICONSET_DIR"
    
    # Copy with iconutil naming convention
    cp "$APPICONSET_DIR/icon_16.png" "$ICONSET_DIR/icon_16x16.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_16@2x.png" "$ICONSET_DIR/icon_16x16@2x.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_32.png" "$ICONSET_DIR/icon_32x32.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_32@2x.png" "$ICONSET_DIR/icon_32x32@2x.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_128.png" "$ICONSET_DIR/icon_128x128.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_128@2x.png" "$ICONSET_DIR/icon_128x128@2x.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_256.png" "$ICONSET_DIR/icon_256x256.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_256@2x.png" "$ICONSET_DIR/icon_256x256@2x.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_512.png" "$ICONSET_DIR/icon_512x512.png" 2>/dev/null || true
    cp "$APPICONSET_DIR/icon_512@2x.png" "$ICONSET_DIR/icon_512x512@2x.png" 2>/dev/null || true
    
    # Convert to .icns
    iconutil -c icns "$ICONSET_DIR" -o "$APP_BUNDLE/Contents/Resources/AppIcon.icns" 2>/dev/null || echo "⚠️  Icon creation had warnings"
    rm -rf "$ICONSET_DIR"
fi

# 8. Create PkgInfo
echo -n "APPL????" > "$APP_BUNDLE/Contents/PkgInfo"

echo ""
echo "✅ Build complete!"
echo "📍 App bundle: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open \"$APP_BUNDLE\""
echo ""
echo "To sign the app (optional, for distribution):"
echo "  codesign --force --deep --sign \"Developer ID Application: Your Name\" \"$APP_BUNDLE\""
