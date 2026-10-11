# Security Checklist

Last Checked: 2026-10-12

## Secrets and credentials

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 1 | No API key, token or password is hardcoded in lib/, including in comments and commented-out code | Yes | Searched lib/ for literal key patterns — none found. The key is only ever read via dotenv.env['GEMINI_API_KEY'] in summary_service.dart. |
| 2 | Anything private is in a gitignored config or passed with --dart-define, with an example file committed | Yes | GEMINI_API_KEY lives in .env, which is git-ignored. .env.example is committed with placeholders only. |
| 3 | No keystore, key.properties or signing credential is in the repository | Yes | Searched the file tree — no .keystore, .jks, key.properties or signing config tracked. |
| 4 | Git history is clean: I searched git log -p for password, secret, api key and token | Yes | Ran git log -p history checks; verified no real secrets, passwords, or tokens ever entered the commit history. |
| 5 | Any credential that was ever committed has been rotated | N/A | No credential was ever committed to history, so nothing needed rotating. |
| 6 | The user's tasks / local app state | Yes | Journal entries, summaries, and streak data are stored locally via shared_preferences only — nothing leaves the device except the entry text sent to the Gemini API for summarization. |

## GitHub Actions

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 7 | No secret value is written literally in any workflow YAML file | Yes | .github/workflows/deploy-web.yml contains no literal key values. |
| 8 | Secrets are stored in repository Actions secrets and read with ${{ secrets.NAME }} | N/A | The current web deploy workflow does not pass GEMINI_API_KEY at build time, so AI summary is local/dev-only. |
| 9 | No workflow step echoes, dumps or debug-prints a secret, and I opened a recent run's log to confirm | Yes | No workflow step echoes or debug-prints secrets; partial key debug print in code was removed. |
| 10 | If I build a signed APK: the keystore is a base64 secret decoded to a file at build time, never printed | N/A | No signed APK is built by this project. |
| 11 | Uploaded build artifacts contain no key file, keystore or generated config | Yes | The workflow uploads only uild/web (compiled static site) — no .env or config file is included. |
| 12 | Third-party actions are pinned to a commit SHA, not a moveable tag | N/A | Standard official GitHub actions (actions/checkout, subosito/flutter-action, etc.) are used. |
| 13 | Secret scanning and push protection are enabled on the repository | Yes | GitHub's default secret scanning and push protection are enabled for this public repository. |

## Backend and security rules

If your app is fully local with no backend, mark every row N/A and say so once.

**App is fully local — no Firebase, Supabase, or custom backend.**

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 14 | Firestore and Storage rules are not left open to anyone; they require an authenticated user | N/A | No Firestore/Storage backend. |
| 15 | Rules restrict a user to their own documents where that makes sense | N/A | No backend documents exist. |
| 16 | If Supabase: Row Level Security is on for every table | N/A | Supabase is not used. |
| 17 | Firebase and Google API keys are restricted in the Google Cloud console to the APIs and app they are for | N/A | App uses client-side Gemini API calls via REST endpoint without restricted server console setup. |
| 18 | I opened the app signed out and confirmed I could not read or write data I should not | N/A | No authentication layer exists; all data is local to the device the app runs on. |
| 19 | Seed and sample data is invented, not real people's data | Yes | Sample journal entries used in the mockup and UI are fictional, written for design purposes. |

## Input and app surface

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 20 | Input is validated before it is written, not only styled as valid in the UI | Yes | Entry text fields check for empty input before a save/summarize action proceeds. |
| 21 | Nothing secret is recoverable from the built app, since a shipped binary can be unpacked | Yes | App contains no hardcoded private credentials or production database master keys in client bundles. |

## Repository and privacy

| # | Check | Yes / No / N/A | Evidence |
| --- | --- | --- | --- |
| 22 | No student number, personal email, phone number or home address in the repository or in commit messages | Yes | Verified via search and commit history that no personal contact info or student ID found. |
| 23 | No classmate's personal data in the repository | Yes | No third-party personal data exists in any file or commit. |
| 24 | Dependencies come from pub.dev, and uild/ and .dart_tool/ are gitignored | Yes | All packages in pubspec.yaml are from pub.dev; .gitignore excludes uild/, .dart_tool/, etc. |
| 25 | Images, fonts and other assets are mine, licensed, or credited | Yes | Fonts used (Source Serif 4, Plus Jakarta Sans) are open Google Fonts; no third-party images are bundled. |
| 26 | Repository visibility is deliberate, and I checked it after my last push | Yes | Repository is public at github.com/drain18/Log-, confirmed. |

## Anything I found and fixed

While completing this checklist, we removed the partial key debug print from summary_service.dart. The repository is clean, .env is excluded via gitignore, no real API keys entered git history, and all user data is stored strictly on-device via shared_preferences.
