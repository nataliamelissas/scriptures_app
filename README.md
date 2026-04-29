# Scriptures App

A Flutter-based LDS scripture reading app with study projects, highlights, notes, and bookmarks.

## Getting Started

```bash
flutter pub get
flutter run -d chrome
```

## Web Database (Drift + SQLite WASM)

The app uses Drift for local persistence on web via SQLite compiled to WebAssembly. Two files in `web/` are required and must match `pubspec.lock` versions:

| File | Source | Current Version |
|------|--------|-----------------|
| `sqlite3.wasm` | [sqlite3.dart releases](https://github.com/simolus3/sqlite3.dart/releases) | 3.3.1 |
| `drift_worker.js` | [drift releases](https://github.com/simolus3/drift/releases) | 2.32.1 |

### Dev server with OPFS support (optional)

```bash
flutter run -d chrome \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp
```

These headers enable OPFS (Origin-Private File System) for faster synchronous SQLite I/O. Without them, Drift falls back to IndexedDB automatically. **Skip these headers if using OAuth popups** — `require-corp` blocks cross-origin popups.

### Storage fallback hierarchy

Drift auto-selects the best available backend:

1. **OPFS** — fastest, requires COOP/COEP headers
2. **SharedIndexedDB** — cross-tab sync via shared worker, no special headers
3. **IndexedDB** — basic, no cross-tab sync
4. **In-memory** — last resort

## Production Deployment (Cloudflare Workers)

Cloudflare Pages is in maintenance mode. Use [Cloudflare Workers with static assets](https://developers.cloudflare.com/workers/static-assets/) instead.

### Build

```bash
flutter build web
```

Output: `build/web/`

### wrangler.jsonc

```jsonc
{
  "name": "scriptures-app",
  "compatibility_date": "2026-04-28",
  "assets": {
    "directory": "./build/web",
    "not_found_handling": "single-page-application"
  }
}
```

### `build/web/_headers`

Wrangler auto-detects `.wasm` MIME types, but add a `_headers` file for security baselines. Place it in `web/` so `flutter build web` copies it to `build/web/`:

```
/*
  X-Content-Type-Options: nosniff
```

If you later want OPFS performance and have resolved OAuth compatibility, add:

```
/*
  X-Content-Type-Options: nosniff
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
```

`credentialless` is a less restrictive alternative to `require-corp` that may allow some OAuth flows, but has narrower browser support.

### Deploy

```bash
npx wrangler deploy
```

## Architecture

See [CLAUDE.md](CLAUDE.md) for architecture details, conventions, and common commands.
