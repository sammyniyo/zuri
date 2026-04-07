# ZURI — Rwanda's Hyper-Local Discovery App (React Native)

ZURI is a **React Native (Expo)** mobile application for Rwanda that helps users discover nearby places — restaurants, cafés, rooftops, and hidden gems.

## Run the app

### Requirements
- **Node.js** (recommended: latest LTS)
- **Android Studio** + an Android emulator (or a physical Android device)

### Install

```bash
npm install
```

### Start (dev server)

```bash
npm run start
```

### Run on Android

```bash
npm run android
```

## Firebase setup (optional for now)

Create a `.env` file in the repo root:

```env
EXPO_PUBLIC_FIREBASE_API_KEY=...
EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN=...
EXPO_PUBLIC_FIREBASE_PROJECT_ID=...
EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET=...
EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
EXPO_PUBLIC_FIREBASE_APP_ID=...
```

Without Firebase configured, the app will still start using **mock data** on Explore.
