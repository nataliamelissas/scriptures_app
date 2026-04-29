# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter-based LDS scripture reading app supporting multiple independent study projects with highlights, notes, and bookmarks across the five standard works.

## Common Commands

```bash
flutter run                  # Run on connected device/emulator
flutter analyze              # Lint check
flutter test                 # Run all tests
flutter test test/path_to_test.dart  # Run a single test file
flutter build apk            # Android production build
flutter build web            # Web production build
```

## Architecture

Clean architecture with three layers under `lib/`:

```
domain/        → entities + abstract repository interfaces (no Flutter deps)
data/          → concrete repository implementations, SQLite DB, HTTP/local data sources
presentation/  → Riverpod providers, screens, widgets
```

### Data Flow

Scripture content is fetched from OpenScriptureAPI.org first; on failure, it falls back to local markdown files. The local path is currently hardcoded in `providers.dart` — treat it as a platform-specific config value.

### Database Schema (SQLite via sqflite)

Two tables in [`lib/data/datasources/app_database.dart`](lib/data/datasources/app_database.dart):
- `projects` — study project metadata + last reading position
- `notes` — all verse annotations (highlights, text notes, bookmarks), indexed on `(project_id, volume, book_api_id, chapter)`

### Navigation

`HomeScreen` → `VolumesScreen` → `BooksScreen` → `ReaderScreen` → `VerseActionSheet` (bottom sheet)

`ReaderScreen` is a `ConsumerStatefulWidget` that saves reading position on every chapter change and builds a `Map<int, List<StudyNote>>` for O(1) verse note lookup.

### Key Conventions

- Highlight colors are stored as ARGB32 integers; the five palette colors are defined in [`lib/core/theme.dart`](lib/core/theme.dart)
- Local markdown fallback expects files at `{basePath}/{StandardWork.displayName}/{BookTitle}/{BookTitle} {ChapterNumber}.md` with one verse per line
