# AGENTS.md

Repository architecture and testing guide for AI agents.

## Project Overview

Flutter-based LDS scripture reading app with study projects, highlights, notes, and bookmarks across the five standard works.

**Tech Stack:**

- Flutter/Dart
- Riverpod (state management)
- Drift (SQLite persistence)
- Firebase Core (configured, not fully used)
- Cloudflare Workers (web deployment + CORS proxy)

## Architecture

Clean architecture with three layers:

```
lib/
├── domain/           # Entities + abstract repository interfaces (no Flutter deps)
│   ├── entities/     # Scripture, StudyProject
│   └── repositories/ # NoteRepository, ProjectRepository, ScriptureRepository
├── data/             # Concrete implementations, SQLite DB, HTTP/local sources
│   ├── datasources/  # app_database.dart, local_scripture_source.dart, open_scripture_api.dart
│   └── repositories/ # *_impl.dart files
├── presentation/     # Riverpod providers, screens, widgets
│   ├── screens/      # 8 screens (home, reader, volumes, books, etc.)
│   ├── providers/   # Riverpod state providers
│   ├── controllers/  # UI controllers
│   └── widgets/      # Reusable widgets
├── core/             # Constants, theme
├── firebase_options.dart
└── main.dart
```

**Data Flow:**

- Scripture content: OpenScriptureAPI.org → local markdown fallback
- Database: SQLite via Drift (projects + notes tables)
- Web routing: CORS proxy worker for API calls

## Key Commands

### Development

```bash
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device
flutter run -d chrome --web-port=8080  # Web (port 8080 required for persistence)
flutter analyze                    # Lint check
```

### Testing

```bash
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run single test file
```

### Build

```bash
flutter build apk                  # Android production build
flutter build web                  # Web production build (output: build/web/)
```

### Deployment

```bash
# Cloudflare Worker (CORS proxy)
cd workers/scripture-proxy
wrangler deploy

# Web app (after build)
npx wrangler deploy
```

## Critical Notes

### Web Persistence

**IMPORTANT:** Web database lives in IndexedDB, partitioned by origin (`scheme://host:port`). Always use `--web-port=8080` for development to avoid ephemeral ports that wipe data on each launch.

### CORS Proxy

`openscriptureapi.org` lacks CORS headers. Web traffic routes through Cloudflare Worker (`workers/scripture-proxy/`) that adds `Access-Control-Allow-Origin: *`. Native platforms call API directly.

### Platform-Specific Routing

`lib/core/constants.dart` switches API base URL:

- Web → Worker URL
- Android/iOS/desktop → Direct API URL

### Firebase (Under Construction)

Configured via FlutterFire CLI. Run `flutterfire configure` to regenerate platform files when adding services. Currently only `firebase_core` is initialized; Auth, Firestore sync, and Storage features are not yet implemented.

### Database Schema

Two tables in `lib/data/datasources/app_database.dart`:

- `projects` — study project metadata + last reading position
- `notes` — verse annotations (highlights, text notes, bookmarks)

### Navigation Flow

`HomeScreen` → `VolumesScreen` → `BooksScreen` → `ReaderScreen` → `VerseActionSheet`

### Highlight Colors

Highlight colors are stored as ARGB32 integers; the five palette colors are defined in `lib/core/theme.dart`
