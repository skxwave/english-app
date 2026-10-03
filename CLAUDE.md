# English App

Free iOS vocabulary trainer (Reword-style prototype). Swipe cards, spaced repetition on the Ebbinghaus curve. Offline, no accounts.

## Stack
- SwiftUI + SwiftData, iOS 17+, Swift 6, iPhone only. No third-party dependencies (adding one needs explicit approval).
- No Xcode IDE usage: the user works from VSCode. Build and run via `just`. Hot reload was considered and dropped.
- `EnglishApp.xcodeproj` is hand-written (no XcodeGen). `EnglishApp/` is a file-system synchronized group, so new files under it are picked up automatically; don't edit the pbxproj to add sources.

## Commands
- `just build` — incremental simulator build (iPhone 17 Pro) into `build/`.
- `just run` — build, boot simulator, install, launch with console streaming (blocks; Ctrl+C stops streaming only).
- Device ids and the signing team live in `.env` (gitignored; template in `.env.example`: `PHONE_UDID`, `PHONE_ID`, `TEAM_ID`, `BUNDLE_ID`, `SIMULATOR`), loaded by the justfile. The project file only holds the placeholder bundle id `com.example.englishapp`; the justfile overrides it with `BUNDLE_ID` on every build. Never hardcode these values or commit `.env`.
- `just phone` — Release build signed with the free Personal Team from `.env`, install on the connected iPhone, launch (`phone-build` / `phone-install` for the parts). Free signing expires after 7 days; rerun to renew. Needs Developer Mode on and the profile trusted on the phone (Settings → General → VPN & Device Management).
- Lint / type-check / tests: none configured. No test target exists; don't add one unprompted.

## Domain
- `Pack` has many `Word`. Word status: `new`, `learning`, `known`, `learned`. A pack's "learned" count = known + learned.
- Swipe right on a new word → `known`. Swipe left → `learning` with `step` 0 and `dueDate` = now (persisted immediately, so an abandoned round loses nothing).
- SRS ladder in `SRS.swift`: 30 min, 2 h, 1 d, 3 d, 7 d, 30 d. `Word.step` counts successful recalls; step 0 = not recalled yet. A right swipe on a learning word moves to step k and schedules `intervals[k-1]`; a recall after the last interval → `learned`. Any left swipe resets to step 0.
- Two study modes (`StudyMode`), each run as a `StudySession` (in-memory queue, `Domain/StudySession.swift`): `learnNew` queues as many random `new` words from the selected packs (`Pack.isSelected`; first seed pack starts selected) as the remaining daily goal; `review` queues all due `learning` words across all packs (earliest due first). A missed (left-swiped) word is re-inserted into the queue after 5, then 3, then 1 other cards (gap shrinks with each miss) and the round ends only when the queue is empty, i.e. every word was swiped right. When a missed word is finally swiped right it gets step 1 (due in 30 min), so it shows up in Repeat as the second pass. In Learn, a right swipe on a new word (`known`) doesn't count toward the goal, so it is replaced by another new word. The exact ReWord algorithm isn't published; this follows the user's description plus ReWord reviews (~30 min, then ~2 h).
- Every swipe logs a `StudyEvent` (`learned` = left on new, `known` = right on new, `repeated` = any swipe on a learning word). Dashboard heatmap and weekly chart read these.
- Daily goal (`@AppStorage`, chosen on the Learn dashboard, default 10) caps newly-learned words per day: `learned` events today (words swiped as unknown; `known` swipes do not count). `StudyView` shows the "great learner" screen only once the goal is reached and the round's queue is empty; Repeat is never capped.
- Streak = consecutive days with any `StudyEvent`; today being empty doesn't break it yet (`ActivityStats.streak`).
- Display name and daily goal live in `@AppStorage` (keys in `Preferences`). In Vocabulary, tapping a row toggles selection; the right chevron opens the pack's word list.
- Seed data: `EnglishApp/Resources/packs.json`, generated from the Oxford 3000/5000 Anki deck (`Oxford_3000_and_5000_English_with_Ukrainian_Translation.apkg`, gitignored): one pack per CEFR level ("Oxford A1"…"C1", 5948 words). Word fields: `term`, `pos`, Ukrainian `translation` (machine-translated, some are poor), `ipaUK/US`, `audioUK/US` (remote mp3), `image` (remote, empty for placeholders), 5 `examples` (`en`/`uk`, target word wrapped in `**`). `Seeder.syncIfNeeded` runs the import only when `contentVersion` (in `Seeder.swift`) differs from the stored one — bump it whenever packs.json changes. The import upserts by pack name and word (term + pos), preserves progress, deletes packs missing from the bundle, and selects the first pack if none is selected. Import takes several seconds on first launch (debug build ~6 s).
- Word display: card back and `WordDetailView` use `WordInfo` (image, translation, POS, UK/US IPA with play buttons via `Pronunciation`, examples). Audio and images need network. Only Ukrainian exists in the data; the earlier Ukrainian/Russian switcher was removed.
- Study card flips on tap (`FlipCard` in `SwipeCard.swift`, Y-axis, face swaps at 90°). Vocabulary word list dims mastered (known/learned) words.
- Backup (`Data/Backup.swift`, `Views/Menu/BackupSection.swift`): Menu → Create backup (JSON via `fileExporter`) / Restore (via `fileImporter`). Contains non-new word progress keyed by pack name + term + pos, pack selection, all `StudyEvent`s and the three settings. Restore is a full replace after confirmation. Bump `Backup.currentVersion` if the format changes.
- Theme: Menu picker System / Light / Dark (`AppTheme`, applied via `preferredColorScheme` in `RootView`). Palette in `Views/Theme/Theme.swift` (background / card / accent / highlight, light and dark variants from the user's hex palettes); use these tokens, not system colors, for surfaces. Screens apply `themedScreen()` for the background.

## Layout
- `README.md` — public-facing overview + setup; screenshots in `docs/screenshots/` (taken from a throwaway simulator with synthetic activity data). Update both when features or setup steps change.
- `EnglishApp/Domain/` — SwiftData models `Word`, `Pack`, `StudyEvent`; `SRS.swift` (ladder + `Word.swipe`, returns the event kind); `StudySession.swift` (round queue), `StudyQueue.swift` (`StudyMode`, due-word helpers); `ActivityStats.swift` (heatmap/weekly aggregation).
- `EnglishApp/Assets.xcassets/AppIcon.appiconset` — app icon (1024 px PNG, made from the root `icon.jpeg`; the feather quill). Single-size icon set, no alpha.
- `EnglishApp/Data/` — `Seeder` (JSON import), `Backup`, `Pronunciation` (AVPlayer). `EnglishApp/Resources/packs.json` — seed packs.
- `EnglishApp/Views/` — `RootView` (tab bar: Learn / Vocabulary / Menu), `Learn/` (dashboard with streak, `DailyGoalCard`, `ActivityHeatmap` = last 6 months in per-month blocks with weekday labels, `WeeklyChart` via Swift Charts), `Vocabulary/` (pack list, pack words with search and A–Z / status sort), `Word/` (`WordInfo`, `WordDetailView`), `Study/` (`StudyView` session flow, `SwipeCard` gesture + reveal), `Menu/` (name, theme, backup, reset progress, version), `Theme/` (palette + `AppTheme`).

- Reminders (`Domain/ReminderPlan.swift` pure planning, `Data/ReminderScheduler.swift` UNUserNotificationCenter, toggle in Menu): local notifications rebuilt whenever the app goes to background and cleared when it becomes active (so follow-ups stop once the user returns). Review reminders fire at word due times, learn reminders at 10:00 and 19:00 for the next 3 days (skipped when the goal is reached today or no new words are selected). Each reminder is a burst of 3 pings (+0, +15, +45 min). Quiet hours 22:00–08:00: a burst start inside them moves to 08:00, follow-ups inside them are dropped. Stays under the 64 pending-notification limit.

## SwiftData rules
Every new non-optional `@Model` property needs a default value, otherwise the store fails to migrate on existing installs (the app then crashes at launch).

## Not built yet
Custom packs / CSV import, review notifications, tests.

## Maintenance
Keep this file current: update it whenever commands, structure, domain rules or decisions change.
