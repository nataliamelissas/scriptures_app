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

## Cloudflare Worker: Scripture API CORS Proxy

`openscriptureapi.org` returns valid responses but no `Access-Control-Allow-Origin` header, so browsers block them. Native (Android/iOS/desktop) platforms are unaffected. To fix web, scripture API traffic is routed through a Cloudflare Worker that re-emits the response with permissive CORS headers.

Source lives in [`workers/scripture-proxy/`](workers/scripture-proxy):

| File | Purpose |
|------|---------|
| `index.js` | Worker entry point. Handles `OPTIONS` preflight and forwards `GET` requests to `openscriptureapi.org`, attaching `Access-Control-Allow-Origin: *`. |
| `wrangler.jsonc` | Wrangler config. `name` controls the deployed subdomain (`scripture-proxy.<account>.workers.dev`). |

### Platform routing

[`lib/core/constants.dart`](lib/core/constants.dart) exposes `ApiConfig.baseUrl` as a `static get` that switches on `kIsWeb`:

- **Web** → Worker URL (`https://scripture-proxy.<account>.workers.dev/...`)
- **Android / iOS / desktop** → direct (`https://openscriptureapi.org/...`)

If you fork this repo, update `_proxyUrl` in `constants.dart` to point at your own deployed Worker.

### Deploy

One-time setup:

```bash
npm install -g wrangler
wrangler login
```

Deploy (from repo root):

```bash
cd workers/scripture-proxy
wrangler deploy
```

The first deploy prints the public Worker URL. Subsequent deploys reuse it.

### Gitignored Worker artifacts

- `.wrangler/` — local Wrangler cache, contains your Cloudflare account id/email. **Never commit.**
- `workers/**/node_modules/` — if you add npm deps to the Worker.

Both are already in `.gitignore`.

## Firebase

`firebase_core` is wired up as the foundation for future Auth, Firestore sync, and Storage features. No Firebase products are used at runtime yet beyond initialization.

### Configuration

Platform setup is managed by the FlutterFire CLI — do **not** hand-edit generated files.

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This (re)generates:

- `lib/firebase_options.dart` — non-secret platform identifiers. **Committed** to the repo so fresh clones work.
- `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `macos/Runner/GoogleService-Info.plist` — platform config files. **Gitignored** by convention; each developer regenerates them via `flutterfire configure`.

Re-run `flutterfire configure` whenever you add a new Firebase service or platform.

### New dependencies

Added in `pubspec.yaml`:

| Package | Purpose |
|---------|---------|
| `firebase_core` | Initializes the Firebase SDK. Required by every other Firebase package. |

Future additions (not yet installed): `firebase_auth`, `cloud_firestore`, `firebase_storage`.

## Architecture

See [CLAUDE.md](CLAUDE.md) for architecture details, conventions, and common commands.
