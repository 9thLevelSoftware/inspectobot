# Technology Stack

**Analysis Date:** 2026-03-04

## Languages

**Primary:**
- Dart (SDK constraint `>=3.10.1 <4.0.0`) for application code in `lib/main.dart`, `lib/app/app.dart`, and feature modules under `lib/features/` (constraint declared in `pubspec.yaml` and locked in `pubspec.lock`).

**Secondary:**
- Kotlin (Android build scripting/plugin layer) in `android/app/build.gradle.kts` and `android/settings.gradle.kts`.
- Swift/Objective-C (iOS host shell) in `ios/Runner/AppDelegate.swift` and `ios/Runner/GeneratedPluginRegistrant.m`.
- XML/Plist for mobile platform configuration in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.

## Runtime

**Environment:**
- Flutter app runtime with stable channel metadata in `.metadata` and Flutter SDK requirement `>=3.38.0` in `pubspec.lock`.

**Package Manager:**
- Dart/Flutter `pub` via `pubspec.yaml`.
- Lockfile: present at `pubspec.lock`.

## Frameworks

**Core:**
- Flutter Material and Widgets for UI/app shell in `lib/app/app.dart` and `lib/main.dart`.

**Testing:**
- `flutter_test` (SDK dependency) declared in `pubspec.yaml` and pinned in `pubspec.lock`.

**Build/Dev:**
- Flutter lints (`flutter_lints`) enabled through `analysis_options.yaml`.
- Android Gradle plugin `8.11.1` and Kotlin Android plugin `2.2.20` in `android/settings.gradle.kts`.
- Gradle wrapper `8.14` in `android/gradle/wrapper/gradle-wrapper.properties`.

## Key Dependencies

**Critical:**
- `image_picker` for camera capture flow in `lib/features/media/media_capture_service.dart`.
- `flutter_image_compress` for on-device photo compression in `lib/features/media/media_capture_service.dart`.
- `pdf` for report generation in `lib/features/pdf/on_device_pdf_service.dart`.
- `path_provider` for filesystem paths in `lib/features/media/local_media_store.dart`, `lib/features/media/pending_media_sync_store.dart`, and `lib/features/pdf/on_device_pdf_service.dart`.

**Infrastructure:**
- Flutter plugin bootstrap on iOS via `ios/Runner/GeneratedPluginRegistrant.m` and Android via `android/app/src/main/AndroidManifest.xml` + Flutter Gradle plugin in `android/app/build.gradle.kts`.

## Configuration

**Environment:**
- Use local machine Flutter/Android SDK paths through `android/local.properties` (`flutter.sdk`, `sdk.dir`).
- No runtime `.env` files detected in project root `C:/Users/dasbl/AndroidStudioProjects/InspectoBot`.
- iOS generated build environment variables are in `ios/Flutter/Generated.xcconfig` and `ios/Flutter/flutter_export_environment.sh`.

**Build:**
- Dart analyzer/lint config in `analysis_options.yaml`.
- Android build config in `android/build.gradle.kts`, `android/app/build.gradle.kts`, `android/settings.gradle.kts`.
- iOS app metadata/permissions in `ios/Runner/Info.plist`.

## Platform Requirements

**Development:**
- Flutter SDK installed locally (path reference in `android/local.properties` and `ios/Flutter/Generated.xcconfig`).
- Android toolchain with Java 17 compatibility (`android/app/build.gradle.kts`).
- Xcode/iOS toolchain implied by iOS runner files in `ios/Runner/` and Flutter iOS config in `ios/Flutter/`.

**Production:**
- Mobile deployment targets are Android and iOS app bundles via Flutter runners in `android/app/` and `ios/Runner/`.

---

*Stack analysis: 2026-03-04*
