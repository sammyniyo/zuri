# ZURI — Rwanda's Hyper-Local Discovery App

> Discover the best places around you. Restaurants, cafés, rooftops, and hidden gems — all in one beautiful app built for Rwanda.

---

## Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Environment Setup](#environment-setup)
- [Running the App](#running-the-app)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Features](#features)
- [API Keys & Services](#api-keys--services)
- [Production Checklist](#production-checklist)
- [Design System](#design-system)
- [Troubleshooting](#troubleshooting)

---

## Overview

ZURI is a Flutter-based mobile application designed for Rwanda that helps users discover nearby places — restaurants, cafés, hotels, gyms, and more. It features real-time location, interactive maps, user reviews, and a Pro subscription powered by Flutterwave (MTN MoMo + Card).

| Detail         | Value                              |
|----------------|------------------------------------|
| App Name       | ZURI                               |
| Platform       | Android (iOS ready)                |
| Version        | 1.0.0+1                            |
| Language       | Dart / Flutter                     |
| Min Android    | 5.0 Lollipop (API 21)              |
| Currency       | RWF (Rwandan Franc)                |

---

## Requirements

### System Requirements

| Tool            | Minimum Version | How to Check           |
|-----------------|-----------------|------------------------|
| Flutter         | 3.10.0+         | `flutter --version`    |
| Dart            | 3.0.0+          | `dart --version`       |
| Android Studio  | 2022.3+         | Help → About           |
| Android SDK     | API 21+         | SDK Manager            |
| Java (JDK)      | 17+             | `java -version`        |
| Git             | Any             | `git --version`        |

### Device Requirements

**Physical Android Device:**
- Android 5.0 (Lollipop) or higher
- USB Debugging enabled
- USB cable connected to your computer

**Android Emulator:**
- Android Studio installed
- AVD (Virtual Device) with API 21 or higher
- At least 4 GB RAM recommended

---

## Getting Started

### Step 1 — Install Flutter

If Flutter is not installed:

```bash
# Download Flutter SDK from https://flutter.dev/docs/get-started/install
# Extract and add flutter/bin to your system PATH

# Verify installation
flutter doctor
```

> Make sure `flutter doctor` shows no critical errors before continuing.

---

### Step 2 — Open the Project

```bash
cd C:\Users\samsh\Documents\MobileProjects\zuri
```

---

### Step 3 — Create Required Asset Folders

The app references asset folders that must exist:

```bash
# Windows
mkdir assets\images
mkdir assets\icons

# macOS / Linux
mkdir -p assets/images assets/icons
```

---

### Step 4 — Install Dependencies

```bash
flutter pub get
```

---

### Step 5 — Connect a Device

```bash
# List available devices
flutter devices
```

You should see your emulator or physical device listed.

---

## Environment Setup

### Google Maps API Key

The Map screen requires a Google Maps API key.

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create a project → **APIs & Services** → Enable **Maps SDK for Android**
3. Create an API Key under **Credentials**
4. Open `android/app/src/main/AndroidManifest.xml`
5. Replace the placeholder:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

> The rest of the app (Explore, Auth, Reviews, Saved) works without this key. Only the Map tab will be blank.

---

### Flutterwave Payment Key

The Pro subscription screen uses Flutterwave for MTN MoMo Rwanda and card payments.

1. Create an account at [flutterwave.com](https://flutterwave.com)
2. Go to **Settings → API Keys**
3. Copy your **Public Key**
4. Open `lib/features/pro/pro_screen.dart`
5. Replace:

```dart
publicKey: 'YOUR_FLUTTERWAVE_PUBLIC_KEY',
isTestMode: true, // Change to false in production
```

**Flutterwave Test Card (for testing):**
- Card Number: `4187427415564246`
- CVV: `828`
- Expiry: `09/32`

---

### Firebase Setup (Production Only)

Firebase is required for real authentication and Firestore database. The app currently runs with mock/simulated data for development.

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for this project
flutterfire configure
```

Then update `lib/main.dart`:

```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: ZuriApp()));
}
```

---

## Running the App

### Standard Run (Development)

```bash
flutter run
```

### Run on a Specific Device

```bash
# List available devices first
flutter devices

# Run on a specific device by ID
flutter run -d emulator-5554
flutter run -d R58M123ABC
```

### Run in Release Mode (No Debug Banner, Faster)

```bash
flutter run --release
```

### Build APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Google Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Clean Build

```bash
flutter clean
flutter pub get
flutter run
```

---

## Project Structure

```
zuri/
├── android/                          # Android native project
├── assets/
│   ├── images/                       # App images, logos (add your files here)
│   └── icons/                        # Icon assets, SVGs
├── lib/
│   ├── main.dart                     # Entry point — ProviderScope, portrait lock
│   ├── app.dart                      # App state machine (splash → auth → home)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart    # Kigali coords, categories, emoji map
│   │   ├── models/
│   │   │   ├── place_model.dart      # Place, FilterOptions, WaitStatus
│   │   │   ├── mock_data.dart        # 10 Kigali mock places (Firebase-ready)
│   │   │   ├── user_model.dart       # ZuriUser with Pro subscription fields
│   │   │   └── review_model.dart     # Review model + MockReviews
│   │   ├── providers/
│   │   │   ├── app_providers.dart    # Location, places, filter, saved, search
│   │   │   ├── auth_provider.dart    # Auth state + Google / Phone / Guest
│   │   │   └── review_provider.dart  # Per-place review state (family provider)
│   │   └── theme/
│   │       ├── app_colors.dart       # ZuriColors design tokens
│   │       └── app_theme.dart        # ZuriTheme + ZuriTextStyles (Poppins)
│   │
│   ├── features/
│   │   ├── splash/                   # Animated splash screen
│   │   ├── onboarding/               # Location permission screen
│   │   ├── auth/                     # Welcome, Phone Auth, OTP screens
│   │   ├── home/                     # HomeShell — IndexedStack bottom nav
│   │   ├── explore/                  # Main feed + search + filter chips
│   │   ├── map/                      # Google Maps with color-coded pins
│   │   ├── place_detail/             # Full place info, gallery, reviews
│   │   ├── saved/                    # Bookmarked places list
│   │   ├── filter/                   # Filter bottom sheet (Pro-gated)
│   │   ├── reviews/                  # ReviewCard, ReviewsSection, AddReview
│   │   ├── pro/                      # Pro paywall + Flutterwave payment
│   │   └── profile/                  # User profile, stats, settings (4th tab)
│   │
│   └── shared/
│       └── widgets/
│           ├── zuri_bottom_nav.dart  # Bottom navigation bar (4 tabs)
│           ├── rating_badge.dart     # Star rating pill badge
│           ├── wait_time_badge.dart  # Wait time indicator (green/yellow/red)
│           ├── pro_badge.dart        # Gold PRO crown badge
│           └── pro_gate.dart         # Pro upgrade overlay wrapper widget
│
├── test/
│   └── widget_test.dart              # Basic widget smoke tests
├── pubspec.yaml                      # Dependencies & asset declarations
└── README.md                         # This file
```

---

## Dependencies

| Package                      | Version     | Purpose                          |
|------------------------------|-------------|----------------------------------|
| `flutter_riverpod`           | ^2.5.1      | State management                 |
| `go_router`                  | ^13.2.0     | Navigation                       |
| `firebase_core`              | ^3.1.0      | Firebase core                    |
| `firebase_auth`              | ^5.1.0      | User authentication              |
| `cloud_firestore`            | ^5.1.0      | NoSQL database                   |
| `google_sign_in`             | ^6.2.1      | Google OAuth sign-in             |
| `flutterwave_standard`       | ^1.0.12     | MTN MoMo + Card payments         |
| `image_picker`               | ^1.1.2      | Camera and gallery access        |
| `google_maps_flutter`        | ^2.5.3      | Interactive map                  |
| `geolocator`                 | ^12.0.0     | GPS location services            |
| `permission_handler`         | ^11.3.1     | Runtime permissions              |
| `cached_network_image`       | ^3.3.1      | Network image caching            |
| `smooth_page_indicator`      | ^1.1.0      | Image gallery page dots          |
| `shimmer`                    | ^3.0.0      | Loading skeleton animations      |
| `flutter_staggered_animations` | ^1.1.1    | Staggered list animations        |
| `flutter_svg`                | ^2.0.10+1   | SVG rendering                    |
| `url_launcher`               | ^6.3.0      | Open maps, phone calls, links    |
| `shared_preferences`         | ^2.2.3      | Local key-value storage          |
| `intl`                       | ^0.19.0     | Date & number formatting         |
| `uuid`                       | ^4.4.0      | Unique ID generation             |

---

## Features

### Free Users
- Browse all nearby places in Kigali
- View place details (photos, hours, RWF pricing)
- Search places by name or category
- Save favourite places
- View ratings and existing reviews
- Walk directions (Google Maps) + Call button

### Pro Users — 5,000 RWF/month
- Everything in Free
- Advanced filters (distance, rating, category, open now)
- Write reviews and rate places
- Upload photos to reviews
- Unlimited saved places

### App Screens

| Screen              | Description                                          |
|---------------------|------------------------------------------------------|
| Splash              | Animated logo on green gradient                      |
| Location Permission | GPS access request with benefit cards                |
| Welcome             | Full-screen auth: Google, Phone, or Guest            |
| Phone Auth          | Rwanda +250 number entry                             |
| OTP Verify          | 6-digit animated verification boxes with countdown   |
| Explore             | Search bar, filter chips, featured section, cards    |
| Map                 | Google Maps with green/yellow/red pins               |
| Place Detail        | Gallery, action buttons, hours, prices, reviews      |
| Saved               | Bookmarked places with swipe-to-remove               |
| Filter              | Bottom sheet filters (Pro-gated)                     |
| Reviews             | Rating breakdown + review cards + add review         |
| Pro Paywall         | Feature list + MTN MoMo / Card payment               |
| Profile             | Avatar, stats, Pro card, settings, sign out          |

---

## API Keys & Services

| Service         | File                                                | Key Placeholder                  | Required For         |
|-----------------|-----------------------------------------------------|----------------------------------|----------------------|
| Google Maps     | `android/app/src/main/AndroidManifest.xml`         | `YOUR_GOOGLE_MAPS_API_KEY`       | Map tab              |
| Flutterwave     | `lib/features/pro/pro_screen.dart`                  | `YOUR_FLUTTERWAVE_PUBLIC_KEY`    | Pro subscription     |
| Firebase Auth   | `lib/firebase_options.dart` (auto-generated)       | via `flutterfire configure`      | Real login           |
| Cloud Firestore | `lib/firebase_options.dart` (auto-generated)       | via `flutterfire configure`      | Real database        |

---

## Production Checklist

Before submitting to the Google Play Store:

- [ ] Add Poppins font `.ttf` files to `assets/fonts/` and declare in `pubspec.yaml`
- [ ] Add logo PNG files to `assets/images/` and `assets/icons/`
- [ ] Replace `YOUR_GOOGLE_MAPS_API_KEY` in `AndroidManifest.xml`
- [ ] Replace `YOUR_FLUTTERWAVE_PUBLIC_KEY` in `pro_screen.dart`
- [ ] Set `isTestMode: false` in `pro_screen.dart`
- [ ] Run `flutterfire configure` and add `firebase_options.dart`
- [ ] Update `lib/main.dart` to initialize Firebase
- [ ] Replace `MockData` in `mock_data.dart` with real Firestore queries
- [ ] Wire real `geolocator` permission flow (currently simulated)
- [ ] Update `applicationId` in `android/app/build.gradle`
- [ ] Generate a release signing keystore
- [ ] Test on Android API 21, 28, 30, and 33
- [ ] Run `flutter analyze` — confirm 0 errors

---

## Design System

| Token          | Value       | Usage                              |
|----------------|-------------|------------------------------------|
| Primary        | `#0FA958`   | Buttons, active states, icons      |
| Secondary      | `#FF8C42`   | Highlights, badges, orange CTAs    |
| Background     | `#F8F9FA`   | App background                     |
| Surface        | `#FFFFFF`   | Cards, bottom sheets, nav bar      |
| Text Primary   | `#1A1A2E`   | Headlines and body text            |
| Text Secondary | `#6B7280`   | Subtitles and captions             |
| Error          | `#EF4444`   | Error states and alerts            |
| Wait — Low     | `#10B981`   | Short wait time indicator          |
| Wait — Medium  | `#F59E0B`   | Medium wait time indicator         |
| Wait — High    | `#EF4444`   | Long wait time indicator           |
| Font           | Poppins     | All text across the app            |

---

## Troubleshooting

### `flutter doctor` shows errors
```bash
# Accept Android SDK licenses
flutter doctor --android-licenses

# If Flutter command not found
# Add Flutter bin/ folder to your system PATH
```

### `flutter pub get` fails
```bash
flutter pub cache clean
flutter pub get
```

### App crashes on launch — asset error
```bash
# Create the missing folders
mkdir assets\images
mkdir assets\icons
```

### Map screen is blank or crashes
- Check that your API key is set in `AndroidManifest.xml`
- Confirm **Maps SDK for Android** is enabled in Google Cloud Console
- Make sure the API key has no package name restrictions that block the app

### No devices found
```bash
flutter devices

# Physical device: enable USB Debugging in Developer Options
# Emulator: open Android Studio → Device Manager → Start AVD
```

### Gradle build fails
```bash
flutter clean
flutter pub get
flutter run
```

### Payment not processing
- Confirm `isTestMode: true` while testing
- Use the Flutterwave test card: `4187427415564246` / CVV `828` / Expiry `09/32`
- Verify the public key starts with `FLWPUBK_TEST-`

---

*Built with ❤️ for Rwanda 🇷🇼 — © 2025 ZURI*
