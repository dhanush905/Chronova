# Chronova

[![GitHub Repository](https://img.shields.io/badge/GitHub-Chronova-4F46E5?logo=github)](https://github.com/dhanush905/Chronova)
[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend%20%26%20RLS-3ECF8E?logo=supabase)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Chronova is a modern, privacy-first cross-platform productivity workspace built with Flutter. Backed by Supabase PostgreSQL and Row Level Security (RLS), Chronova unifies calendar schedule planning, priority reminders, organized notes, and multi-format document imports into a clean, cohesive interface.

**Repository:** [https://github.com/dhanush905/Chronova](https://github.com/dhanush905/Chronova)

---

## 🎨 Design Philosophy & UI System

Chronova is crafted around a distraction-free, modern aesthetic:
- **Background**: Soft clean background (`#F4F7FE`) that reduces visual strain.
- **Brand Primary**: Vibrant Indigo (`#4F46E5`) with violet and cyan secondary accents.
- **Surfaces**: Pure white (`#FFFFFF`) rounded cards (`BorderRadius.circular(18)`) with subtle borders (`#E2E8F0`) and ambient shadows.
- **Responsive Layout**: Adapts gracefully from compact smartphones (bottom `NavigationBar`) to tablets, foldables, and desktops (side `NavigationRail` and max-width constrained content containers).
- **Customizable Categories**: Event and task categories are dynamic user entities with custom colors and labels—not hardcoded static enums.

---

## 📱 Features & App Architecture

### 1. Home Dashboard
- Live overview metrics (Upcoming Events, Active Reminders, Organized Notes, Imported Files).
- Quick action shortcuts (Add Event, New Reminder, New Note, Import Document).
- Today's chronological event timeline with category badges, tap-to-edit, and popup action menus.
- Priority reminders list with interactive completion toggles and alarm status.
- Recent notes and document previews with tap-to-edit.

### 2. Calendar & Event Planning
- Month and year navigation strip with interactive 7-day selector.
- Real-time search across event titles, descriptions, and locations without item loss or duplication.
- Dynamic category filter chips generated from custom user categories.
- Interactive event editor bottom sheet (`EventEditorSheet`):
  - Title validation with feedback.
  - Interactive date picker (`showDatePicker`).
  - Interactive start and end time pickers (`showTimePicker`) with duration consistency rules.
  - Dynamic category selection.
  - Cancel without modifying original event.
  - Save updates with stable identity (no duplicate records).
- Deletion with confirmation dialog before removing events.

### 3. Notes & Files (Notepad)
- **Notes Tab**:
  - Folder-based organization ("Work", "Architecture", "Personal", "Ideas") and search by title or body.
  - Dedicated note editor sheet (`NoteEditorSheet`) with isolated controllers and clean disposal.
  - Prefilled edit mode, pin toggling, and input validation.
  - Delete with confirmation dialog.
- **Files & Import Tab**: Centralized document manager with support for CSV, PDF, Spreadsheets (.xlsx), and Images. Includes a file import preview modal to confirm detected events prior to calendar ingestion.

### 4. Profile & Settings
- Profile card displaying authenticated user account email and cloud connection badge.
- Functional **Sign Out** flow with session cleanup.
- Cloud synchronization status indicator (connected to Mumbai Supabase instance with RLS active).
- Offline caching preference switch.
- Category management hub allowing users to create new custom-colored categories dynamically.
- Notification and audio alarm configuration with snooze intervals.
- About Chronova specifications (free tools, zero paid AI dependencies).

---

## 🛠️ Technologies & Dependencies

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `flutter` | SDK | Cross-platform UI toolkit |
| `supabase_flutter` | `^2.18.3` | Supabase GoTrue Auth, Postgrest Database, & Realtime |
| `flutter_local_notifications` | `^22.3.2` | Native Android alarms, scheduled notifications, and snooze actions |
| `timezone` | `^0.11.2` | Timezone database and absolute timestamp conversions |
| `intl` | `^0.20.3` | Date formatting and localization |
| `cupertino_icons` | `^1.0.8` | Cupertino companion iconography |

---

## 📂 Project Structure

```text
lib/
├── main.dart                          # Application entry point with Supabase & notification initialization
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
├── services/
│   └── notification_service.dart      # Native scheduled notifications, exact alarm engine, snooze & boot sync
├── screens/
│   ├── auth/
│   │   ├── auth_gate.dart             # Session router (ConfigGuide / Auth / MainNavigationShell)
│   │   ├── auth_screen.dart           # Email/password authentication, validation & error messages
│   │   └── config_guide_screen.dart   # Missing-configuration guide with diagnostics
│   ├── main_navigation_shell.dart     # Responsive shell (NavigationBar / NavigationRail)
│   ├── home/
│   │   └── home_screen.dart           # Home dashboard with interactive reminders, snooze & tap-to-edit
│   ├── calendar/
│   │   └── calendar_screen.dart       # Calendar, date strip, search, event creation & editing
│   ├── notes_files/
│   │   └── notes_files_screen.dart    # Notepad tab, folder filtering & file import preview
│   └── profile/
│       └── profile_settings_screen.dart # Profile, account email, live notification permissions & snooze duration
└── widgets/
    ├── custom_card.dart               # Elevated rounded card component
    ├── event_editor_sheet.dart        # Reusable event create/edit bottom sheet
    ├── note_editor_sheet.dart         # Reusable note create/edit bottom sheet
    ├── reminder_editor_sheet.dart      # Reusable reminder create/edit bottom sheet with alarm toggle
    ├── responsive_container.dart      # Adaptive max-width container
    ├── section_header.dart            # Standardized section header with action link
    └── status_badge.dart              # Pill status/category badge
```

---

## ⚡ Prerequisites & Installation

### Prerequisites
1. **Flutter SDK**: Ensure Flutter 3.11+ is installed (`flutter doctor`).
2. **Git**: Installed and configured.
3. **Supabase Project**: A Supabase project (hosted in the Mumbai region or any region of your choice).

### Installation
Clone the repository:
```bash
git clone https://github.com/dhanush905/Chronova.git
cd Chronova
flutter pub get
```

---

## ☁️ Supabase Cloud & Database Setup

Chronova uses Supabase for email/password authentication, PostgreSQL data persistence, and strict Row Level Security (RLS).

### 1. Database Schema & SQL Migration
The database migrations are version-controlled under `supabase/migrations/`:
- `supabase/migrations/20261015000000_phase2_schema_and_rls.sql`

#### Applying the Migration:
1. Open your [Supabase Dashboard](https://supabase.com/dashboard) and select your project.
2. Go to the **SQL Editor** tab from the left sidebar.
3. Click **New query**.
4. Copy the entire contents of [`supabase/migrations/20261015000000_phase2_schema_and_rls.sql`](supabase/migrations/20261015000000_phase2_schema_and_rls.sql).
5. Paste into the SQL Editor and click **Run**.
6. The script creates the `categories`, `events`, `notes`, and `reminders` tables with UUID primary keys, user foreign keys linked to `auth.users(id) ON DELETE CASCADE`, indexes, auto-updating `updated_at` timestamps, and enables Row Level Security (RLS) on all tables with strict `auth.uid() = user_id` ownership policies.

---

## 🚀 Running the Application

Credentials are provided securely at compile-time using `--dart-define` flags. **Never hardcode, commit, or share your secret service-role key or database password.** Only use your project URL and public `anon` publishable key.

### Windows PowerShell (Chrome Web)
```powershell
flutter run -d chrome `
  --web-browser-flag="--disable-cache" `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-anon-publishable-key
```

> [!TIP]
> The `--web-browser-flag="--disable-cache"` flag prevents Chrome from serving a stale service worker bundle from previous sessions.

### Android Device / Emulator
```powershell
flutter run -d android `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-anon-publishable-key
```

### Safe Diagnostics & Configuration Handling
If the application is launched without compile-time environment flags or with malformed values, Chronova does **not** crash or silently mask issues. Instead, `AuthGate` displays a setup guide (`ConfigGuideScreen`) showing safe diagnostics:
- **SUPABASE_URL Presence**: Indicates whether the environment variable was detected.
- **SUPABASE_URL Validity**: Validates `https://` scheme and non-empty host domain.
- **Parsed Scheme & Host**: Confirms extracted scheme and host domain without exposing credentials.
- **Publishable Key Presence**: Reports key presence, character length, and key type.
- **Local Sample Mode**: Provides a one-click button to explore Chronova in local sample mode without cloud sync.

---

## 🔒 Authentication & Data Isolation

- **Email & Password Authentication**: Fully functional Sign In and Sign Up flows with input validation (RFC email checks, minimum 6-character passwords, password matching confirmation).
- **Session Restoration**: When credentials are configured, `AuthGate` listens to `Supabase.instance.client.auth.onAuthStateChange` and inspects `currentSession` to restore the active user upon launch.
- **User Isolation**: `ChronovaDataStore` binds all CRUD operations to `currentUserId`. All events, notes, reminders, and categories are isolated per user under PostgreSQL RLS policies.
- **Session Cleanup**: Signing out calls `clearUserData()` on `ChronovaDataStore`, immediately purging in-memory data to prevent cross-account data leaks.

---

## 🔔 Native Notification & Alarm Engine (Phase 3.1)

Chronova provides native scheduled alarms and reminder notifications on Android via `flutter_local_notifications` and `timezone`:

### Features & Architecture
- **Deterministic 31-Bit Notification IDs**: Maps reminder UUIDs/string IDs deterministically into positive 31-bit integer identifiers (`reminderIdToNotificationId`), preventing collisions and duplicate alerts when reminders are modified or deleted.
- **Timezone-Aware Scheduling**: Leverages `timezone/data/latest_all.dart` and `tz.local` to schedule notifications at precise local times regardless of timezone shifts.
- **Interactive Action Buttons**:
  - **Snooze (+Xm)**: Reschedules the notification by the user-configured snooze interval (5m, 10m, or 15m) and increments the snooze counter.
  - **Mark as Done**: Marks the reminder completed and dismisses the notification.
- **Boot Recovery**: Declares `ScheduledNotificationBootReceiver` in AndroidManifest to re-register scheduled notifications after a device reboot.
- **Cross-Screen State Sync**: When a reminder is added, updated, toggled, or deleted via `ChronovaDataStore`, the store automatically coordinates with `NotificationService` to schedule or cancel notifications.
- **Safe Web & Headless Fallback**: Automatically detects headless testing environments and non-Android platforms with `isPlatformChannelAvailable`, cleanly executing mock flows without throwing `MissingPluginException` or unhandled platform errors.

### Android Permissions & Exact Alarm Configuration
To deliver reliable alarms even when the app is in the background or killed, the Android app is configured with:
- `android.permission.POST_NOTIFICATIONS`: Prompts the user on Android 13+ (API 33+) at runtime.
- `android.permission.SCHEDULE_EXACT_ALARM`: Enables exact timing via Android `AlarmManager`.
- `android.permission.USE_EXACT_ALARM`: Ensures compatibility with Android 14+ power policies for alarm applications.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Permits boot recovery of scheduled alerts.
- `android.permission.VIBRATE`: Enables haptic alerts.
- **Core Library Desugaring**: Configured in `android/app/build.gradle.kts` via `com.android.tools:desugar_jdk_libs:2.1.4` and Java 11 bytecode compatibility.

> [!NOTE]
> **Android 13/14+ Exact Alarm Permission**: On Android 13 and 14+, users can revoke exact alarm permissions in **Settings > Apps > Special app access > Alarms & reminders**. Chronova checks `canScheduleExactAlarms()` and falls back gracefully to `exactAllowWhileIdle` when permitted.

---

## 🧪 Verification & Testing

### Static Code Analysis
Run code analysis to ensure zero lint or syntax issues:
```powershell
flutter analyze
```

### Automated Unit & Widget Test Suite
All 43 tests run completely offline without needing live credentials, native plugins, or active network:
```powershell
flutter test
```

Test coverage includes:
- Compile-time configuration validation (`SupabaseConfig`).
- Model JSON serialization with UUID generation (`EventItem`, `NoteItem`, `ReminderItem`).
- Deterministic 31-bit notification ID generator (`reminderIdToNotificationId`).
- Timezone initialization, custom snooze intervals, and past-due date validation.
- In-memory repository CRUD operations and strict user data isolation.
- State store lifecycle, error propagation, reminder mutations, and sample mode switching.
- Auth screen validation, password confirmation, and authentication gate routing.
- Complete navigation shell, event management flow, notepad CRUD flows, and reminder creation/toggle flow.

---

## 🚀 Multi-Phase Roadmap

- **Phase 1 (Completed & Refined)**: UI foundation, responsive navigation shell, Material 3 light theme, unified in-memory reactive state manager, functional event create/edit/cancel/delete flows, functional notepad with folder organization, file import preview, and widget tests.
- **Phase 2 (Completed)**: Supabase integration, versioned SQL migration with RLS, email/password authentication, session restoration and sign out, repository layer with user isolation, compile-time credential handling, and automated test coverage.
- **Phase 3.1 (Completed)**: Native Notification and Alarm Engine — Android local notifications, exact alarms, boot receiver persistence, interactive snooze/done actions, snooze duration customization, and full reminder CRUD with bottom sheet editor.
- **Phase 3.2 (Upcoming)**: Offline SQLite caching with sync queue.
- **Phase 3.3 (Upcoming)**: Recurring event rules (daily, weekly, monthly, custom RRULE).
- **Phase 4 (Upcoming)**: Supabase Storage bucket integration for document uploads (PDF, CSV, Excel, Images).

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
