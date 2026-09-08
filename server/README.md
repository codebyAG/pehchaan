# Pehchaan AI server (MVP)

> **Currently unused.** The app now calls OpenAI directly from the device
> using the key in `lib/core/constants/key_constants.dart` (solo/local
> testing only). This server is the secure alternative — switch back to
> it (point `AiImageService` at it again, like `server/README.md` history
> shows) before this app is ever shared with anyone else.

A tiny local backend that holds the OpenAI API key and proxies AI image
generation for the Flutter app. Pure `dart:io` — no external packages, no
database, nothing beyond what this one job needs.

## Why this exists

The OpenAI API key is a secret. It must never ship inside the Flutter app
(anyone could pull it out of the APK). This server is the minimum piece
needed to keep it off the client: it's the only thing that talks to
OpenAI, and the app only ever talks to this server.

## Setup

1. Put your OpenAI API key in a `.env` file — either here (`server/.env`)
   or one level up in the Flutter project root (`../.env`, i.e.
   `growlio/.env`). Either location works:

   ```
   OPENAI_API_KEY=sk-...
   ```

   (`CHAT_GPT_KEY` and `OPENAI_KEY` are also accepted as the variable
   name, in case you already have a `.env` using one of those.)

2. Run it:

   ```bash
   cd server
   dart run bin/server.dart
   ```

   You should see `Pehchaan AI server listening on http://0.0.0.0:8080`.
   Leave this running while you use the app.

   Alternative to a `.env` file — pass the key directly:

   ```bash
   OPENAI_API_KEY=sk-... dart run bin/server.dart          # bash
   $env:OPENAI_API_KEY="sk-..."; dart run bin/server.dart  # PowerShell
   ```

## Pointing the app at this server

The Flutter app defaults to `http://10.0.2.2:8080`, which is the Android
emulator's alias for your computer's `localhost`. That works out of the
box if you're running on an emulator.

- **Physical Android device on the same Wi-Fi**: find your computer's LAN
  IP (`ipconfig` on Windows, look for IPv4 Address) and run:
  ```bash
  flutter run --dart-define=AI_SERVER_URL=http://<your-lan-ip>:8080
  ```
- **iOS Simulator / Chrome / desktop**: `http://localhost:8080` works
  directly:
  ```bash
  flutter run --dart-define=AI_SERVER_URL=http://localhost:8080
  ```

## API

```
POST /generate-image
{ "request": "Jeera ka premium poster banao" }

200 { "success": true, "imageBase64": "..." }
4xx/5xx { "success": false, "error": "user-friendly message" }
```

## What it does internally

1. `generateImagePrompt()` — sends the request to OpenAI's Responses API
   (model `gpt-5.6-terra`) with creative-director system instructions
   that turn a one-line request into a detailed, production-quality
   image-generation prompt.
2. `generateImage()` — sends that prompt to OpenAI's image API (model
   `gpt-image-2`, `1024x1024`, `medium` quality) and returns the base64
   PNG.

Both live in `lib/openai_service.dart`, isolated from the HTTP plumbing
in `bin/server.dart` — swap models, add fields, or change providers there
without touching the request handling.

## Beyond local testing

This server has no auth, no rate limiting, and prints minimal logs — it's
built for one developer testing on one machine, not for deploying
publicly. Before putting it anywhere reachable by strangers, add at least
request auth (e.g. require the app to send a shared secret) and a rate
limit per client, since every request spends your OpenAI credits.
