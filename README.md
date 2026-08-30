# LightCast

**Mobile Church Livestream Production System**

LightCast turns Android phones into a complete livestream production studio — OBS + EasyWorship + Bible Projection + Facebook Live, all mobile-first.

## Version 0.1 — Features

- Director Dashboard with camera mode switching (Pastor / Crowd / PIP)
- Lyrics Library (CRUD + display on stream)
- Scripture Library (CRUD + display on stream)
- Logo Manager (upload / preview / show / hide)
- Lower Thirds overlay
- Mock camera switching (real WebRTC in v0.3)
- Mock streaming (real RTMP in v0.5)

## Build

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Tech Stack

- Flutter 3.x (stable)
- Riverpod (state management)
- SQLite (sqflite)
- Image Picker

## Next Versions

- v0.2 — Device discovery + camera client
- v0.3 — WebRTC video feeds
- v0.4 — Real camera switching + PIP
- v0.5 — Facebook Live via RTMP
- v0.6 — Full overlay system

**Package:** `com.sirdavid.lightcast`
