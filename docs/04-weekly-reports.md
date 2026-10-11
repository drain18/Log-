# Weekly Increment Report

## Week of: September 20 to September 26, 2026

## What changed this week

- Completed the SharedPreferences spike test and verified it with a smoke test in test/widget_test.dart.
- Updated test/widget_test.dart to match the new simplified home screen structure. Still will be edited in the later future.

## Why

- To establish local data persistence foundations and ensure app state handling works correctly across widget rebuilds.

## What broke or what I got stuck on

- Aligning the primary home screen design and navigation layout to remove unwanted legacy UI components (streak banner, entries).

## What is left

- Further refinement of home screen views and updating project documentation.

## Week of: September 25 to September 27, 2026

## What changed this week

- Initialized the Flutter project structure and repository for "Log!" (virtual voice diary).
- Set up local storage persistence model (`StorageService` using `shared_preferences`) and core `Entry` data model (`lib/models/entry.dart`).
- Configured project dependencies (`table_calendar`, `device_preview`), design system theme settings, and GitHub Actions deployment workflow for GitHub Pages.
- Organized and added all initial planning documents to `docs/` (proposal, wireframes/mockups, design system, security & privacy checklist).

## Why

- To establish a robust architectural foundation and local data persistence layer before building out UI screens and voice features.
- To ensure CI/CD deployment and documentation standards are in place from the start of Phase 0.

## What broke or what I got stuck on

- Fine-tuning web deployment base href and ensuring `device_preview` framing rendered correctly across desktop and mobile browser views.
- Designing clean serialization logic in `StorageService` for storing and retrieving lists of journal entries locally without a complex database backend.

## What is left

- Phase 1: Calendar view and home screen UI implementation with streak counters.
- Phase 2: Voice recording integration and fallback text input.
- Phase 3: Gemini AI API integration for automated journal summarization.  

## Week of: September 27 to October 11, 2026

## What changed this week

- Implemented the calendar-based Home screen with streak tracking (`table_calendar`) and interactive daily entry lists.
- Built the live voice recording screen (`RecorderScreen`) using `speech_to_text` for real-time transcription.
- Implemented entry detail modal views supporting local persistence, delete confirmation dialogs, and AI summarization.
- Integrated Google Gemini AI via `SummaryService` (using `gemini-1.5-flash` on the stable `v1` endpoint) to generate automated 1-2 sentence journal summaries.
- Secured the repository by adding `*.log` to `.gitignore` to prevent accidental credential leaks.

## Why

- To execute Phases 1, 2, and 3 of the project build plan—moving from offline storage persistence to fully operational voice recording and AI-powered journal analysis.

## What broke or what I got stuck on

- Gemini API 404 Not Found errors due to legacy `v1beta` endpoint versioning and model mismatches (`gemini-1.5-flash`, `gemini-pro`), resolved by migrating to the stable `v1` endpoint with `gemini-1.5-flash`.
- GitHub push protection blocking commits due to a hardcoded service account API key inside local log files, resolved by updating `.gitignore` with `*.log`.

## What is left

- Phase 4: Final visual polish against wireframes and responsive layout checks.