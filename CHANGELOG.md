# Changelog

All notable changes to Chronova will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-10-15 (Phase 2 - Supabase Cloud, Auth & RLS Integration)

### Added
- **Supabase Integration & Compile-Time Configuration**:
  - Integrated official `supabase_flutter: ^2.18.3` package.
  - Implemented `SupabaseConfig` reading `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from compile-time environment flags (`String.fromEnvironment`), preventing hardcoded secrets.
  - Created `.env.example` as a template and updated `.gitignore` to protect all local `.env*` files.
- **SQL Migration & Row Level Security (RLS)**:
  - Added versioned SQL migration under `supabase/migrations/20261015000000_phase2_schema_and_rls.sql`.
  - Created PostgreSQL tables: `categories`, `events`, `notes`, and `reminders` with UUID primary keys and `user_id` foreign keys cascading from `auth.users(id)`.
  - Enabled Row Level Security (RLS) on all 4 tables with strict `auth.uid() = user_id` ownership policies for SELECT, INSERT, UPDATE, and DELETE.
  - Created automatic `update_updated_at_column()` trigger and indexes for performance.
- **Authentication Flows (`AuthScreen` & `AuthGate`)**:
  - Designed `AuthScreen` matching Chronova's `#F4F7FE` and Indigo `#4F46E5` design theme.
  - Supported Sign In, Sign Up with password confirmation, input validations, loading indicators, and user-friendly error messages.
  - Handled email confirmation message when Supabase project settings require email verification.
  - Created `AuthGate` to route between `ConfigGuideScreen` (when credentials are unset), `AuthScreen` (when unauthenticated), and `MainNavigationShell` (when authenticated).
- **Repository Architecture & Session Isolation**:
  - Defined `ChronovaRepository` contract.
  - Implemented `SupabaseChronovaRepository` for live Postgrest communication.
  - Implemented `InMemoryChronovaRepository` with per-user data partition isolation for test reliability and offline demo fallback.
  - Updated `ChronovaDataStore` to support repository injection, asynchronous operations, `initializeForUser(userId)`, and `clearUserData()` on logout to avoid session bleed across accounts.
- **Profile Screen Integration**:
  - Added active authenticated user email display and "Supabase Cloud Connected" status badge in `ProfileSettingsScreen`.
  - Implemented functional "Sign Out of Chronova" action with confirmation dialog, which clears in-memory state and calls `supabase.auth.signOut()`.
- **Automated Tests**:
  - Added `test/auth_and_repository_test.dart` verifying `SupabaseConfig`, `InMemoryChronovaRepository` user isolation, `ChronovaDataStore` user lifecycle, `ConfigGuideScreen`, and `AuthScreen` form validation.
  - Total test suite now covers 18 unit and widget tests passing offline.

---

## [1.0.1] - 2026-10-15 (Event & Notepad Functionality Fixes)

### Fixed
- **Event Editing Flow**:
  - Implemented `EventEditorSheet` providing prefilled fields (title, description, location, category, date, and start/end times).
  - Wired unhandled `Edit` popup menu and tap callbacks in both `CalendarScreen` and `HomeScreen`.
  - Added input validation ensuring non-empty titles with descriptive error messages.
  - Added date picker (`showDatePicker`) and time pickers (`showTimePicker`) with duration consistency.
  - Ensured edits preserve the event's original ID without creating duplicate entries.
  - Added Cancel action that safely discards edits without modifying the original event.
- **Notepad & Note Editing**:
  - Created `NoteEditorSheet` enabling full edit mode with prefilled title and content.
  - Provided isolated `TextEditingController` instances per sheet session with proper disposal.
  - Added tap-to-edit and more-menu actions on note cards in `NotesFilesScreen` and `HomeScreen`.
  - Added input validation for note titles.
  - Preserved folder categories, attachment indicators, and pinned status during editing.
- **State Management & Cross-Screen Synchronization**:
  - Introduced `ChronovaDataStore` as the single source of truth for in-memory session data.
  - Connected `HomeScreen`, `CalendarScreen`, `NotesFilesScreen`, and `ProfileSettingsScreen` via Flutter's `ListenableBuilder`.
  - Fixed cross-screen divergence where edits on one screen were not reflected on others.
- **Delete Confirmation Safeguards**:
  - Added confirmation dialogs before deleting events or notes to prevent accidental removals.
- **Layout & Overflow Prevention**:
  - Redesigned date and time picker rows in `EventEditorSheet` to eliminate flex layout overflows on narrow mobile screens.

### Added
- **Unit & Widget Test Suites**:
  - Added unit test suite in `test/chronova_data_store_test.dart` testing event and note creation, in-place updates, and deletions.
  - Expanded `test/widget_test.dart` with end-to-end tests verifying the complete event and note creation, editing, cancellation, and confirmed deletion flows.

---

## [1.0.0] - 2026-10-14 (Phase 1 Baseline)

### Added
- **UI System & Theme Engine**:
  - Implemented `AppColors` token repository with `#F4F7FE` background and `#4F46E5` primary indigo.
  - Implemented `AppTheme` with Material 3 styling, `CardThemeData`, custom `NavigationBar` themes, and rounded inputs.
  - Added `ResponsiveContainer`, `CustomCard`, `StatusBadge`, and `SectionHeader` reusable widgets.
- **Main Navigation Shell**:
  - Created responsive navigation shell (`MainNavigationShell`) supporting both mobile `NavigationBar` and desktop/tablet `NavigationRail`.
- **Home Dashboard (`HomeScreen`)**:
  - Live metric summary grid (Events, Reminders, Notes, Files).
  - Quick action shortcuts (Add Event, New Reminder, New Note, Import File).
  - Chronological schedule timeline with category color indicators.
  - Priority reminders list with interactive checkbox toggles and alarm status.
  - Recent notes and document preview cards.
- **Calendar & Scheduling (`CalendarScreen`)**:
  - Month/year navigator with 7-day selector strip.
  - Dynamic category filter chips generated from user-customized categories (no hardcoded lists).
  - Real-time search query filtering over event titles, descriptions, and locations.
  - Event creation modal bottom sheet with category picker and time slots.
  - Interactive event options menu (Edit, Delete).
  - Dedicated empty and loading state UI.
- **Notes & File Management (`NotesFilesScreen`)**:
  - Segmented tab view for Notes and Files Hub.
  - Folder-based notes filtering ("All", "Work", "Architecture", "Personal").
  - Note creation modal with content editor.
  - File management with `FileTypeEnum` categorization (PDF, CSV, Spreadsheet, Document, Image).
  - Document import modal with multi-event detection preview and confirmation flow before calendar sync.
- **Profile & Settings (`ProfileSettingsScreen`)**:
  - User profile header with sync readiness indicator.
  - Cloud synchronization card with Phase 2 Supabase integration preview.
  - Dynamic category manager allowing runtime creation of custom categories with color selection.
  - Notification and audio alarm toggle with configurable snooze durations (5m, 10m, 15m).
  - About Chronova dialog detailing privacy policies and free open-source dependencies.
- **Data Models & In-Memory Store**:
  - `EventItem` and customizable `EventCategory`.
  - `ReminderItem` with snooze and alarm properties.
  - `NoteItem` with folders and attachment indicators.
  - `FileItem` with file metadata and linked event counters.
  - `SampleData` repository populating mock entities for Phase 1.
- **Automated Tests**:
  - Implemented end-to-end smoke and navigation tests in `test/widget_test.dart` verifying all 4 tabs and primary interactions.
