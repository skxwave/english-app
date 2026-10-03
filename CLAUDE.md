# English App

Free iOS vocabulary trainer (Reword-style prototype). Swipe cards, spaced repetition on the Ebbinghaus curve. Offline, no accounts.

## Stack
- SwiftUI + SwiftData, iOS 17+, Swift 6, iPhone only. No third-party dependencies (adding one needs explicit approval).
- No Xcode IDE usage: the user works from VSCode. Build and run via `just`. Hot reload was considered and dropped.
- `EnglishApp.xcodeproj` is hand-written (no XcodeGen). `EnglishApp/` is a file-system synchronized group, so new files under it are picked up automatically; don't edit the pbxproj to add sources.

## Commands
- `just build` — incremental simulator build (iPhone 17 Pro) into `build/`.
- `just run` — build, boot simulator, install, launch with console streaming (blocks; Ctrl+C stops streaming only).
- Lint / type-check / tests: none configured. No test target exists; don't add one unprompted.

## Domain
- `Pack` has many `Word`. Word status: `new`, `learning`, `known`, `learned`. A pack's "learned" count = known + learned.
- Swipe right on a new word → `known`. Swipe left → `learning`, step 0.
- SRS ladder in `SRS.swift`: 1 min, 20 min, 1 d, 3 d, 7 d, 30 d. Right on a learning word advances a step (past the last → `learned`); left resets to step 0.
- Study queue: due learning words first (earliest due), then random new words.
- Seed data: `EnglishApp/Resources/packs.json` (name, summary, words with term/meaning), loaded once when no packs exist. Changing the JSON does not affect an existing install; reset the simulator app to reseed.

## Layout
- `EnglishApp/Domain/` — `Word`, `Pack` (SwiftData models; `Pack.nextWord` is the study-queue rule), `SRS.swift` (ladder + `Word.swipe`).
- `EnglishApp/Data/Seeder.swift` — JSON import. `EnglishApp/Resources/packs.json` — seed packs.
- `EnglishApp/Views/` — `PackListView`, `StudyView` (session flow only), `SwipeCard` (gesture + reveal state).

## Not built yet
Custom packs / CSV import, review notifications, tests.

## Maintenance
Keep this file current: update it whenever commands, structure, domain rules or decisions change.
