### 1. How I used AI

1. **Gemini AI Summary Service:**
   - Tool: Claude web chat
   - Date: Oct 4, 2026
   - What I asked it for: How to integrate `google_generative_ai` into a Flutter service for text summarization.
   - What it gave back: HTTP/client request boilerplate for text summaries.
   - What I kept, changed, and why: Kept the core API client structure, but added error handling and loading states.
   - A link to the commit where that work landed: `71ca5be`

2. **Calendar Widget & Date Filtering:**
   - Tool: Kimi-K3 through Cline
   - Date: Oct 2, 2026
   - What I asked it for: How to set up `table_calendar` and filter entries by selected date.
   - What it gave back: Calendar controller setup and selected-day entry filtering logic.
   - What I kept, changed, and why: Kept the calendar builder structure, adjusted date formatting to match local time zones.
   - A link to the commit where that work landed: `1907e63`

3. **Secure API Key Management via Dotenv:**
   - Tool: Minimax-m2.5 through Cline
   - Date: Oct 11, 2026
   - What I asked it for: How to hide Gemini API keys using `.env` without hardcoding.
   - What it gave back: Code snippets for loading `.env` in `main.dart`.
   - What O kept, changed, and why: Kept dotenv initialization, added `pubspec.yaml` asset declaration so files bundle properly.
   - A link to the commit where that work landed: `454c26a`, `e707534`

4. **Bottom Action Bar & Floating Action Button:**
   - Tool: Claude web chat
   - Date: Oct 2, 2026
   - What I asked it for: Layout design for the bottom action bar matching wireframes.
   - What it gave back: Row and container alignment snippets adhering to 8px spacing rules.
   - What I kept, changed, and why: Kept the spacing constants and padding, adapted widget structure into `BottomActionBar`.
   - A link to the commit where that work landed: `d80b9d4`

5. **Entry Edit & Deletion Workflow:**
   - Tool: Kimi-K3 through Cline
   - Date: Oct 11, 2026
   - What I asked it for: How to implement inline text editing and confirmation dialogs for deleting journal entries.
   - What it gave back: `StatefulWidget` template for detail screen and `showDialog` code.
   - What I kept, changed, and why: Kept the dialog structure, added `StorageService.updateEntry` persistence.
   - A link to the commit where that work landed: `c815fee`

6. **Audio Recorder State Handling:**
   - Tool: Minimax-m2.5 through Cline
   - Date: Oct 2, 2026
   - What I asked it for: How to structure audio recording timer state and UI representation.
   - What it gave back: Timer stream implementation and stop/discard button state logic.
   - What I kept, changed, and why: Kept the timer subscription, adjusted state resets on cancel.
   - A link to the commit where that work landed: `d80b9d4`

### 2. Where the AI got it wrong

Case 1 - Gemini API Endpoint & Model Versioning
- What it gave me: Suggested using `v1beta` API endpoints and older model names.
- What was wrong with it: Caused 404/400 response errors because the endpoint/model identifiers were deprecated.
- What I did instead: Switched to stable `v1` endpoint and valid models (`gemini-1.5-flash`, `gemini-pro`, `gemini-3.5-flash-lite`). 
- Commit: `43ff92e`, `4a840e3`, `ffce62b`

Case 2 - Environment File Asset Bundling
- What it gave me: Suggested loading `.env` via `flutter_dotenv` without declaring it in `pubspec.yaml` assets.
- What was wrong with it: App threw file-not-found exceptions at startup because `.env` wasn't packaged into the asset bundle.
- What I did instead: Explicitly declared `.env` under `flutter: assets:` in `pubspec.yaml`.
- Commit: `e707534`, `454c26a`

Case 3 - Async State Lifecycle Management
- What it gave me: Suggested direct `setState` calls inside asynchronous AI response callbacks without lifecycle checks.
- What was wrong with it: Risk of calling `setState` or accessing unmounted `BuildContext` if the user navigated away during generation.
- What I did instead: Added strict `if (!mounted) return;` guards before every state change or navigation.
- Commit: `c815fee`

### 3. Who Wrote What

Honest Note: Majority of the work was not done by me and was heavily-assisted by AI. Other than the idea (of Log!), HomeScreen, BottomActionBar, and SummaryService being mine, it has done most of the coding. I simply kept revising with the agent and kept driving it until it gave me an output I was satisfied with.

- **User's own code (HomeScreen & BottomActionBar):**
  - File: `lib/screens/home_screen.dart` and `lib/widgets/bottom_action_bar.dart`
  - Commit: `1907e63`, `d80b9d4`, `c815fee`
  - Explanation: You designed and implemented the main calendar view, entry list filtering, and bottom action bar layout following the design system wireframes (`/docs/02-mockup.md`). This keeps navigation clean and UI logic structured around 8px spacing rules.

- **AI-written piece (SummaryService):**
  - File: `lib/services/summary_service.dart`
  - Commit: `71ca5be`
  - Explanation: The AI generated the Gemini API client integration to send journal text prompts and receive summaries. You understand it because it initializes `GenerativeModel`, sends the prompt, and extracts the response text cleanly into our entry model.
