# رفيقي في الإنجليزية — English Coach 90

A **fully offline** Android app that coaches an Arabic-speaking Moroccan
beginner through learning English over 90 days. The whole experience
(content, UI, progress, SRS reviews, daily reminder notifications) lives
on the device. After install, the app needs zero internet.

- **Stack**: Flutter (Dart) · Riverpod · sqflite · flutter_local_notifications · record · just_audio · flutter_tts · google_fonts (Cairo)
- **Target**: Android 8.0+ (minSdk 26)
- **Locale**: Arabic, RTL, Western numerals (1, 2, 3)
- **Content**: 90 days · 3 phases · 13 weeks · ~1980 words · ~990 sentences · 540 tasks

---

## What's inside

- 9 screens: Today, Vocabulary, Sentences, Review (SRS), Progress,
  Onboarding, Task Detail, Day Complete, Settings
- Bottom navigation (RTL): **اليوم · كلمات · جمل · مراجعة · تقدّم**
- Simplified SM-2 spaced-repetition algorithm
  (صعبة resets · جيدة steps forward · سهلة skips two)
- Streak counter, level badge (A1 → A2 → B1 → B2), 28-day calendar
- Daily local reminder notification at user-chosen time
- "5 دقائق فقط" emergency mode to keep the streak alive on busy days
- Day Complete celebration screen

---

## Run from a fresh machine — exact commands, in order

Prerequisites (one-time):

- **Flutter SDK** (latest stable, ≥ 3.19) — <https://docs.flutter.dev/get-started/install>
- **Android Studio** with Android SDK Platform 34 + cmdline-tools + a real
  or emulated device — <https://developer.android.com/studio>
- **Java 17** (Android Studio bundles a compatible JDK)
- Run `flutter doctor` and fix any X marks before continuing.

Build & install — copy/paste these in order from the project root:

```bash
# 1) Clone (or download) the project
git clone https://github.com/bengarin/90-day.git
cd 90-day

# 2) Re-generate the 90 days of content into assets/data/
#    (the JSON files are already committed, but it's safe to re-run)
python3 tools/generate_content.py

# 3) Backfill platform scaffolding (gradle wrapper, default ic_launcher,
#    etc.) without touching files we already provide.
flutter create --org com.englishcoach --project-name english_coach_90 --platforms=android .

# 4) Install Dart dependencies
flutter pub get

# 5) Sanity check (optional)
flutter analyze

# 6) Build the release APK
flutter build apk --release
```

The APK will be written to:

```
build/app/outputs/flutter-apk/app-release.apk
```

> Note on `flutter create` in step 3: it only writes files that don't
> already exist. The `AndroidManifest.xml`, `build.gradle.kts`, and Kotlin
> `MainActivity` we ship here are kept; only missing scaffolding (gradle
> wrapper jar, default launcher icon, etc.) is filled in.

---

## Install the APK on your Android phone — step by step

1. **Transfer the APK to your phone**. Pick one:
   - USB cable: connect the phone to your computer, copy
     `build/app/outputs/flutter-apk/app-release.apk` to the phone's
     `Downloads` folder.
   - Email/Drive: upload the APK to Google Drive / send it to yourself
     by email, then download it on the phone.
   - `adb install`: if your phone has USB debugging on, run from the
     project root:
     ```bash
     adb install -r build/app/outputs/flutter-apk/app-release.apk
     ```
     (Skip the next steps if you used `adb`.)
2. **Allow install from unknown sources** (only the first time):
   - Open the phone's **Settings → Apps → Special access → Install
     unknown apps**.
   - Pick the app you'll open the APK from (usually your **Files**
     or **Chrome** app) and toggle **Allow from this source** on.
3. **Tap the APK** in your file manager. Confirm "Install" on the
   prompt. After it finishes, tap **Open**.
4. The app launches in Arabic, runs the onboarding once (name + goal +
   reminder time), and you're on day 1.

If Android Play Protect warns you, tap **Install anyway** — the app is
unsigned (debug-signed), which is fine for personal use. You can wire up
a real keystore later if you want to publish.

---

## Project layout

```
lib/
  main.dart
  core/                theme, colors, constants, date_utils, notifications
  data/
    database/          db_helper.dart  (schema + first-run seeding)
    models/            models.dart     (Phase, Day, Word, Sentence, Task, ...)
    repositories/      day_repo, vocab_repo, srs_repo, stats_repo
    providers.dart     (Riverpod providers)
  features/
    home/              home_shell.dart (bottom nav)
    today/             today_screen.dart
    vocabulary/        vocabulary_screen.dart
    sentences/         sentences_screen.dart
    review/            review_screen.dart   (SRS)
    progress/          progress_screen.dart
    onboarding/        onboarding_screen.dart
    task_detail/       task_detail_screen.dart
    day_complete/      day_complete_screen.dart
    settings/          settings_screen.dart
  shared/
    tts.dart
    widgets/           task_tile, word_card, sentence_card, progress_bar,
                       streak_badge, pill
assets/
  data/                phases.json, days.json, words.json,
                       sentences.json, tasks.json
tools/
  generate_content.py  (regenerates the seed JSON)
android/                (manifest + gradle config)
```

---

## How the data flows

- On **first launch**, `DbHelper._open()` creates the SQLite schema and
  copies the JSON in `assets/data/` into the database in a single
  transaction. Subsequent launches reuse the existing DB.
- Content tables (`phases`, `days`, `words`, `sentences`, `tasks`) are
  read-only at runtime. State tables (`user_stats`, `day_state`,
  `task_state`, `srs`, `settings`) capture progress and reviews.
- "Today" is computed as `daysBetween(first_open_date, today()) + 1`,
  clamped to 1..90. So if you skip a day, the app still moves forward.
- When you complete a task, its row in `task_state` flips to done, the
  day's `minutes_spent` is bumped, and (for the vocabulary task) the
  day's words are added to the `srs` table — one of them is set as due
  today so the Review tab isn't empty.
- When all 6 tasks for the day are done, the day is marked completed,
  your streak increments, level is recomputed, and the **Day Complete**
  celebration screen pops up.

---

## SRS (simplified SM-2)

- Each `srs` row keeps `ease_factor`, `interval_days`, `repetitions`,
  and `next_review_date`.
- On the Review screen you tap **صعبة / جيدة / سهلة**:
  - **صعبة** — `interval_days` resets to 1, ease lowers.
  - **جيدة** — moves up the interval ladder `[1, 3, 7, 16, 35, 70]`.
  - **سهلة** — skips a step + raises ease.
- Cards with `next_review_date <= today` appear in the Review queue,
  grouped by the day they came from at the bottom of the screen.

---

## Anti-procrastination features

- **Streak** (current + longest) — visible on every load of the Today
  screen.
- **"5 دقائق فقط"** emergency button on Today — marks the vocabulary
  task done so the day's words get seeded into SRS, and prompts you to
  knock out a couple of reviews. Keeps the streak alive.
- **Daily reminder** — scheduled via `flutter_local_notifications` at
  the time you picked in onboarding. The message changes based on your
  streak (more motivating after milestones at 1/3/7/14/30/60/89 days).
- **Day Complete** screen — small celebration with the new streak.

---

## Regenerating the 90-day content

`tools/generate_content.py` produces every JSON file in `assets/data/`
from topic-bucketed word banks, sentence templates, and per-day topic
maps. Run it any time you want to tweak content:

```bash
python3 tools/generate_content.py
```

Then rebuild the app. Because we keep content and state in different
tables, you can re-seed content (in a future migration) without wiping
progress.

---

## Known limitations / scope notes

- **Fonts**: we use `google_fonts` (Cairo). The first launch on a fresh
  install downloads the font in the background **once**; from then on
  the app is fully offline. If there's no network on first launch, the
  app still works — it just falls back to the system Arabic font until
  the next time it can fetch.
- **Audio**: the "listen" buttons use the device's on-device TTS engine
  via `flutter_tts`. On modern Android the English voice is available
  offline; if not, the button silently no-ops.
- **Notifications**: timezone is initialized via `timezone` defaults.
  The reminder fires at the chosen HH:mm but does not auto-shift on
  DST transitions. Re-pick the time after a DST change if needed.
- **Backup/export**: this build ships with **Reset progress** in
  Settings. A file-based export of the SQLite DB is on the to-do list.

---

## License

Personal use. No warranty.
