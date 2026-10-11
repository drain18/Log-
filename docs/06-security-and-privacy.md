# Security and privacy

This repository is public. This document summarizes our security and privacy posture (see `SECURITY-CHECKLIST.md` for the full audited checklist).

**Last checked:** 2026-10-12

## What this app stores

| Data | Where it lives | Who can see it |
| --- | --- | --- |
| Journal entries, transcripts, summaries | On the device (`shared_preferences`) | Only the local device user |

## Secrets

- **Values my app needs at run time:** `GEMINI_API_KEY`
- **Where they live locally:** `.env` (git-ignored), with `.env.example` committed as a template.
- **Where the deploy workflow gets them:** Local web build / development setup (no production server secret required).
- **Deployed web build exposure:** Client-side static web build containing REST API calls to Google Gemini.

## What protects the data on the service side

- **Backend:** App is fully local with no remote database backend. All data stays on-device via `shared_preferences`.
- **AI API:** Anonymized journal text payloads are sent to Gemini solely for summarization upon user request.

## Checklist Summary

- [x] `.env` is in `.gitignore`, and `.env.example` is committed
- [x] `git log -p` finds no real API keys or passwords
- [x] No keystores or signing credentials tracked in repository
- [x] No real personal data in sample data or screenshots
- [x] Secret scanning and push protection enabled on GitHub repository

