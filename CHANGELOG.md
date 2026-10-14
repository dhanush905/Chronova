# Changelog

All notable changes to Chronova will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
