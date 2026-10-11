# Proposal

## The problem, in one sentence
Not everyone wants to bother manually typing about their day on the phone; they'd want to do it quickly and easily.

## Who it is for
This is for people who want to skip the typing and prioritize using their voice to write their diary entries.

## Core features
- **Interactive Calendar Home:** View and track journal entry days on an intuitive calendar with streak indicators.
- **Voice Recording & Transcription:** Record entries via microphone with speech-to-text transcription and fallback typing support.
- **AI-Powered Summarization:** Condense lengthy entries into concise summaries using the Gemini AI API (`SummaryService`).
- **Local Persistence & Management:** Save, read, edit, and delete journal entries securely on-device using local `shared_preferences`.

## Out of scope, and why
- **Cloud synchronization / multi-device login:** Skipped for v1 to maintain simplicity and strict local privacy without requiring a remote database backend.
- **Real-time conversational AI chat:** Deferred to future versions; v1 focuses exclusively on one-touch AI summarization.

## Data the app remembers, and where it is saved
All journal entries, transcripts, dates, and AI summaries are stored strictly on-device in local storage (`shared_preferences`). No personal diary data is transmitted to external servers except anonymous text payloads sent to the Gemini API solely for summarization.

## Risks
- **API Availability & Rate Limits:** Gemini API calls might fail if offline or rate-limited; mitigated with robust error handling and offline fallback states.
- **Speech-to-Text Support:** Browser/device audio permission issues; mitigated with a fully functional typing fallback.

## Changes since the last version
- **October 2026:** Finalized v1 implementation with working calendar, audio/text entry workflow, and Gemini AI summary integration.

