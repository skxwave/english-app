device := "iPhone 17 Pro"
bundle_id := "com.skxwave.englishapp"
app := "build/Build/Products/Debug-iphonesimulator/EnglishApp.app"

build:
    xcodebuild -quiet -project EnglishApp.xcodeproj -scheme EnglishApp \
        -destination 'platform=iOS Simulator,name={{device}}' \
        -derivedDataPath build CODE_SIGNING_ALLOWED=NO build

run: build
    open -a Simulator
    xcrun simctl bootstatus "{{device}}" -b
    xcrun simctl install booted {{app}}
    xcrun simctl launch --console-pty --terminate-running-process booted {{bundle_id}}
