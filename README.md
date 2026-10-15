# Chronova

Chronova is a modern, privacy-focused cross-platform productivity application designed for Android and expandable across iOS, web, and desktop. Chronova unifies calendar events, intelligent reminders, organized notes, and multi-format document imports into a clean, unified workspace backed by Supabase.

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
   - Profile card displaying authenticated user account email and cloud connection badge.
   - Functional **Sign Out** flow with session cleanup.
   - Cloud synchronization status indicator (connected to Mumbai Supabase instance with RLS active).
   - Offline caching preference switch.
   - Category management hub allowing users to create new custom-colored categories dynamically.
   - Notification and audio alarm configuration with snooze intervals.
   - About Chronova specifications (free tools, zero paid AI dependencies).

---

## ⚡ Phase 2: Supabase Cloud & Authentication Setup

Chronova integrates Supabase for email/password authentication, PostgreSQL data persistence, and strict Row Level Security (RLS).

### 1. Database Schema & SQL Migration
The database migrations are version-controlled under `supabase/migrations/`:
- `supabase/migrations/20261015000000_phase2_schema_and_rls.sql`

#### Applying the Migration to Supabase
1. Open your [Supabase Dashboard](https://supabase.com/dashboard) and navigate to your project (Mumbai region).
2. Go to the **SQL Editor** tab from the left sidebar.
3. Click **New query**.
4. Copy the entire contents of [`supabase/migrations/20261015000000_phase2_schema_and_rls.sql`](supabase/migrations/20261015000000_phase2_schema_and_rls.sql).
5. Paste into the SQL Editor and click **Run**.
6. The script creates the `categories`, `events`, `notes`, and `reminders` tables with UUID primary keys, user foreign keys linked to `auth.users(id) ON DELETE CASCADE`, indexes, auto-updating `updated_at` timestamps, and enables Row Level Security (RLS) on all tables with strict `auth.uid() = user_id` ownership policies.

---

### 2. Running Chronova with Credentials Locally

Credentials are provided securely at compile-time using `--dart-define` flags. **Never hardcode, commit, or share your secret service-role key or database password.** Only use the project URL and the public `anon` publishable key.

#### Exact PowerShell Command (Windows)

Replace `<YOUR_SUPABASE_URL>` and `<YOUR_SUPABASE_PUBLISHABLE_KEY>` with your actual project values:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL="https://your-project-ref.supabase.co" `
  --dart-define=SUPABASE_PUBLISHABLE_KEY="your-anon-publishable-key"
```

To run on an Android device or emulator:
```powershell
flutter run -d android `
  --dart-define=SUPABASE_URL="https://your-project-ref.supabase.co" `
  --dart-define=SUPABASE_PUBLISHABLE_KEY="your-anon-publishable-key"
```

#### Missing Configuration Handling
If the application is launched without compile-time environment flags, Chronova does **not** crash. Instead, the `AuthGate` displays a user-friendly setup guide (`ConfigGuideScreen`) showing the exact PowerShell command and provides a one-click button to explore the app in **Local Sample Mode**.

---

## 💾 State Management & Persistence Layer

- **Repository Pattern**:
  `ChronovaRepository` defines the contract for categories, events, notes, and reminders.
  - `SupabaseChronovaRepository`: Interacts asynchronously with Supabase Postgrest tables (`categories`, `events`, `notes`, `reminders`) under active RLS.
  - `InMemoryChronovaRepository`: Provides an isolated in-memory partitioned mock for unit/widget testing and offline demonstration without requiring live network access.
- **Unified Store (`ChronovaDataStore`)**:
  Serves as the single source of truth for the UI layer (`ChangeNotifier`). Manages session initialization (`initializeForUser`) upon login, real-time UI notifications via `ListenableBuilder`, and complete memory wipe (`clearUserData`) upon sign out to prevent cross-account session bleed.

---

## 📂 Project Structure

```
lib/
├── main.dart                          # Application entry point with Supabase initialization & AuthGate
├── core/
│   ├── config/
│   │   └── supabase_config.dart       # Safe compile-time configuration via --dart-define
│   └── theme/
│       ├── app_colors.dart            # Semantic color tokens and category palettes
│       └── app_theme.dart             # Material 3 ThemeData, CardThemeData & typography
├── models/
│   ├── event_item.dart                # EventItem and customizable EventCategory models + JSON serialization
│   ├── reminder_item.dart             # ReminderItem with alarm, snooze, and JSON serialization
│   ├── note_item.dart                 # NoteItem with folder, attachment support, and JSON serialization
│   └── file_item.dart                 # FileItem with FileTypeEnum icons & colors
├── data/
│   ├── sample_data.dart               # Baseline sample data
│   ├── repositories/
│   │   ├── chronova_repository.dart   # Abstract repository interface
│   │   ├── in_memory_chronova_repository.dart # Isolated mock repository for testing & offline mode
│   │   └── supabase_chronova_repository.dart  # Production Supabase Postgrest client implementation
│   └── chronova_data_store.dart       # Reactive state manager & repository bridge
├── screens/
│   ├── auth/
│   │   ├── auth_gate.dart             # Session router (ConfigGuide / Auth / MainNavigationShell)
│   │   ├── auth_screen.dart           # Email/password authentication, validation & error messages
│   │   └── config_guide_screen.dart   # Missing-configuration guide with PowerShell commands
│   ├── main_navigation_shell.dart     # Responsive shell (NavigationBar / NavigationRail)
│   ├── home/
│   │   └── home_screen.dart           # Home dashboard with tap-to-edit and live metrics
│   ├── calendar/
│   │   └── calendar_screen.dart       # Calendar, date strip, search, event creation & editing
│   ├── notes_files/
│   │   └── notes_files_screen.dart    # Notepad tab, folder filtering & file import preview
│   └── profile/
│       └── profile_settings_screen.dart # Profile, account email, cloud status & sign out
└── widgets/
    ├── custom_card.dart               # Elevated rounded card component
    ├── event_editor_sheet.dart        # Reusable event create/edit bottom sheet
    ├── note_editor_sheet.dart         # Reusable note create/edit bottom sheet
    ├── responsive_container.dart      # Adaptive max-width container
    ├── section_header.dart            # Standardized section header with action link
    └── status_badge.dart              # Pill status/category badge
```

---

## 🛠️ Verification & Testing

### Static Analysis
```powershell
flutter analyze
```

### Unit & Widget Test Suite
All 18 tests run completely offline without needing live credentials or active network:
```powershell
flutter test
```

---

## 🚀 Multi-Phase Roadmap

- **Phase 1 (Completed & Refined)**: UI foundation, responsive navigation shell, Material 3 light theme, unified in-memory reactive state manager, functional event create/edit/cancel/delete flows, functional notepad with folder organization, file import preview, and widget tests.
- **Phase 2 (Completed)**: Supabase integration, versioned SQL migration with RLS, email/password authentication, session restoration and sign out, repository layer with user isolation, compile-time credential handling, and automated test coverage.
- **Phase 3 (Upcoming)**: Android notification & alarm engine with snooze action drawer, offline SQLite caching, recurring event rules.
- **Phase 4 (Upcoming)**: Supabase Storage bucket integration for document uploads (PDF, CSV, Excel, Images).
