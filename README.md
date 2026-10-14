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
   - Today's chronological event timeline with category badges and locations.
   - Priority reminders list with interactive completion toggles and alarm status.
   - Recent notes and document previews.

2. **Calendar**:
   - Month and year navigation strip with interactive 7-day selector.
   - Real-time search across event titles, descriptions, and locations.
   - Dynamic category filter chips generated from custom user categories.
   - Interactive event creation modal with customizable category selector.
   - Event management menu (Edit, Reschedule, Delete).
   - Responsive empty and loading states.

3. **Notes & Files**:
   - **Notes Tab**: Folder-based organization ("Work", "Architecture", "Personal"), keyword search, pinned notes, and attachment indicators.
   - **Files & Import Tab**: Centralized document manager with support for CSV, PDF, Spreadsheets (.xlsx), and Images. Includes a file import preview modal to confirm detected events prior to calendar ingestion.

4. **Profile & Settings**:
   - Profile summary with sync readiness status.
   - Cloud synchronization preview (prepared for Supabase integration in Phase 2).
   - Offline caching preference switch.
   - Category management hub allowing users to create new custom-colored categories.
   - Notification and audio alarm configuration with snooze intervals.
   - About Chronova specifications (free tools, zero paid AI dependencies).

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
│   └── sample_data.dart               # In-memory mock data repository for Phase 1
├── screens/
│   ├── main_navigation_shell.dart     # Responsive shell (NavigationBar / NavigationRail)
│   ├── home/
│   │   └── home_screen.dart           # Home dashboard and summary widgets
│   ├── calendar/
│   │   └── calendar_screen.dart       # Calendar, date strip, search, event creation
│   ├── notes_files/
│   │   └── notes_files_screen.dart    # Segmented notes & file import preview
│   └── profile/
│       └── profile_settings_screen.dart # Profile, category creator & preferences
└── widgets/
    ├── custom_card.dart               # Elevated rounded card component
    ├── responsive_container.dart      # Adaptive max-width container
    ├── section_header.dart            # Standardized section header with action link
    └── status_badge.dart              # Pill status/category badge
```

---

## 🛠️ Getting Started & Testing

### Prerequisites
- [Flutter SDK](https://flutter.dev) (version ^3.11.0 / Dart 3)
- Android Studio or VS Code with Flutter extension
- Connected Android device or emulator

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

- **Phase 1 (Completed)**: Initial UI foundation, responsive navigation shell, Material 3 light theme, mock models, interactive dashboard, calendar view, notes, file import preview, and widget test suite.
- **Phase 2**: Supabase authentication, PostgreSQL event/notes persistence, cloud file storage, and Android notification/alarm engine.
- **Phase 3**: Offline SQLite/caching layer, real CSV/PDF/Spreadsheet file parsing engine with preview dialog, recurring event rules, and cross-platform tablet/desktop optimizations.
