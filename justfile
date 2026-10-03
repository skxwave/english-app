set dotenv-load := true

device := env("SIMULATOR", "iPhone 17 Pro")
bundle_id := env("BUNDLE_ID", "com.example.englishapp")
app := "build/Build/Products/Debug-iphonesimulator/EnglishApp.app"

# Device, signing and bundle ids live in .env (gitignored); see .env.example.
# xcodebuild and devicectl identify the same phone with different ids.
phone_udid := env("PHONE_UDID", "")
phone_id := env("PHONE_ID", "")
team := env("TEAM_ID", "")
phone_app := "build/Build/Products/Release-iphoneos/EnglishApp.app"

build:
    xcodebuild -quiet -project EnglishApp.xcodeproj -scheme EnglishApp \
        -destination 'platform=iOS Simulator,name={{device}}' \
        -derivedDataPath build PRODUCT_BUNDLE_IDENTIFIER={{bundle_id}} CODE_SIGNING_ALLOWED=NO build

run: build
    open -a Simulator
    xcrun simctl bootstatus "{{device}}" -b
    xcrun simctl install booted {{app}}
    xcrun simctl launch --console-pty --terminate-running-process booted {{bundle_id}}

phone-build:
    xcodebuild -quiet -project EnglishApp.xcodeproj -scheme EnglishApp -configuration Release \
        -destination 'id={{phone_udid}}' -derivedDataPath build \
        PRODUCT_BUNDLE_IDENTIFIER={{bundle_id}} DEVELOPMENT_TEAM={{team}} -allowProvisioningUpdates build

phone-install: phone-build
    xcrun devicectl device install app --device {{phone_id}} {{phone_app}}

# Free-account installs expire after 7 days; rerun this to renew. App data survives reinstalls.
phone: phone-install
    xcrun devicectl device process launch --device {{phone_id}} --terminate-existing {{bundle_id}}
