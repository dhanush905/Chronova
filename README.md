# Chronova

Chronova is a modern, privacy-focused cross-platform productivity application designed for Android and expandable across iOS, web, and desktop. Chronova unifies calendar events, intelligent reminders, organized notes, and multi-format document imports into a clean, unified workspace.

---

## 🎨 Design Philosophy & UI System

Chronova is built around a modern, distraction-free light aesthetic:
- **Background**: Soft clean background (`#F4F7FE`) that reduces visual strain.
- **Brand Primary**: Vibrant Indigo (`#4F46E5`) with violet and cyan secondary accents.
- **Surfaces**: Pure white (`#FFFFFF`) rounded cards (`BorderRadius: 18`) with subtle borders (`#E2E8F0`) and soft ambient shadows.
- **Responsive Layout**: Adapts gracefully from compact smartphones (bottom `NavigationBar`) to tablets, foldables, and desktops (side `NavigationRail` and max-width constrained content containers).
- **Customizable Categories**: Event and task categories are dynamic user entities with custom colors and labels—not hardcoded static enums.

---

## 📱 Navigation & App Structure

Chronova features four primary navigation destinations:

1. **Home**:
   - Live overview metrics (Upcoming Events, Active Reminders, Organized Notes, Imported Files).
   - Quick action shortcuts (Add Event, New Reminder, New Note, Import Document).
   - Today's chronological event timeline with category badges, tap-to-edit, and popup action menus.
   - Priority reminders list with interactive completion toggles and alarm status.
   - Recent notes and document previews with tap-to-edit.

2. **Calendar**:
   - Month and year navigation strip with interactive 7-day selector.
   - Real-time search across event titles, descriptions, and locations without item loss or duplication.
   - Dynamic category filter chips generated from custom user categories.
   - Interactive event editor sheet (`EventEditorSheet`) supporting:
     - Title validation with feedback.
     - Interactive date picker (`showDatePicker`).
     - Interactive start and end time pickers (`showTimePicker`) with duration consistency rules.
     - Dynamic category selection.
     - Cancel without modifying original event.
     - Save updates with stable identity (no duplicate records).
   - Deletion with confirmation dialog before removing events.

3. **Notes & Files (Notepad)**:
   - **Notes Tab**:
     - Folder-based organization ("Work", "Architecture", "Personal", "Ideas") and search by title or body.
     - Dedicated note editor sheet (`NoteEditorSheet`) with isolated controllers and clean disposal.
     - Prefilled edit mode, pin toggling, and input validation.
     - Delete with confirmation dialog.
   - **Files & Import Tab**: Centralized document manager with support for CSV, PDF, Spreadsheets (.xlsx), and Images. Includes a file import preview modal to confirm detected events prior to calendar ingestion.

4. **Profile & Settings**:
   - Profile summary with sync readiness status.
   - Cloud synchronization preview (prepared for Supabase integration in Phase 2).
   - Offline caching preference switch.
   - Category management hub allowing users to create new custom-colored categories dynamically.
   - Notification and audio alarm configuration with snooze intervals.
   - About Chronova specifications (free tools, zero paid AI dependencies).

---

## 💾 State Management & Data Persistence Notice

- **Phase 1 In-Memory Reactive Architecture**:
  The application utilizes `ChronovaDataStore`, a unified in-memory repository implementing `ChangeNotifier`. Any event, note, category, or reminder modification made in any screen immediately notifies and updates all other screens in real time via Flutter's `ListenableBuilder`.
- **Session Lifecycle & Persistence Limitation**:
  In Phase 1, data persistence is in-memory only. Changes made during a session (events/notes created, edited, deleted, or categories added) persist throughout the active runtime session, but **reset to baseline sample data upon app restart**. Permanent multi-device persistence across app restarts will be introduced via Supabase (PostgreSQL & Cloud Storage) in Phase 2.

---

## 📂 Project Architecture

```
lib/
├── main.dart                          # Application entry point with light theme
├── core/
│   └── theme/
│       ├── app_colors.dart            # Semantic color tokens and category palettes
│       └── app_theme.dart             # Material 3 ThemeData, CardThemeData & typography
├── models/
│   ├── event_item.dart                # EventItem and customizable EventCategory models
│   ├── reminder_item.dart             # ReminderItem with alarm and snooze state
│   ├── note_item.dart                 # NoteItem with folder and attachment support
│   └── file_item.dart                 # FileItem with FileTypeEnum icons & colors
├── data/
│   ├── sample_data.dart               # Default baseline data
│   └── chronova_data_store.dart       # Reactive in-memory state manager (ChangeNotifier)
├── screens/
│   ├── main_navigation_shell.dart     # Responsive shell (NavigationBar / NavigationRail)
│   ├── home/
│   │   └── home_screen.dart           # Home dashboard with tap-to-edit and live metrics
│   ├── calendar/
│   │   └── calendar_screen.dart       # Calendar, date strip, search, event creation & editing
│   ├── notes_files/
│   │   └── notes_files_screen.dart    # Notepad tab, folder filtering & file import preview
│   └── profile/
│       └── profile_settings_screen.dart # Profile, category creator & preferences
└── widgets/
    ├── custom_card.dart               # Elevated rounded card component
    ├── event_editor_sheet.dart        # Reusable event create/edit bottom sheet
    ├── note_editor_sheet.dart         # Reusable note create/edit bottom sheet
    ├── responsive_container.dart      # Adaptive max-width container
    ├── section_header.dart            # Standardized section header with action link
    └── status_badge.dart              # Pill status/category badge
```

---

## 🛠️ Getting Started & Testing

### Prerequisites
- [Flutter SDK](https://flutter.dev) (version ^3.11.0 / Dart 3)
- Android Studio or VS Code with Flutter extension
- Connected Android device, Chrome, or emulator

### Run the App
```bash
flutter pub get
flutter run
```

### Static Analysis
```bash
flutter analyze
```

### Unit & Widget Tests
```bash
flutter test
```

---

## 🚀 Multi-Phase Roadmap

- **Phase 1 (Completed & Refined)**: UI foundation, responsive navigation shell, Material 3 light theme, unified in-memory reactive state manager, functional event create/edit/cancel/delete flows, functional notepad with folder organization, file import preview, and comprehensive test suite.
- **Phase 2**: Supabase authentication, PostgreSQL event/notes cloud persistence, cloud file storage, and Android notification/alarm engine.
- **Phase 3**: Offline SQLite/caching layer, real CSV/PDF/Spreadsheet file parsing engine with preview dialog, recurring event rules, and cross-platform tablet/desktop optimizations.
