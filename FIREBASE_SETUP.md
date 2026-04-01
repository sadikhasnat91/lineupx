# Firebase Setup Guide for LineupX

## Overview

LineupX uses **Cloud Firestore** to store the players database. If Firebase is not configured, the app falls back gracefully to the bundled 38-player sample data — so the app runs fully offline out of the box.

---

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Name it `lineupx` (or any name you prefer)
4. Disable Google Analytics (optional) → **Create project**

---

## 2. Add Your Apps

### Android

1. In the Firebase console, click **Add app → Android**
2. Enter package name: `com.example.lineupx`  
   *(Change this to match your actual `applicationId` in `android/app/build.gradle`)*
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

### iOS

1. Click **Add app → iOS**
2. Enter bundle ID matching your Xcode project (e.g. `com.example.lineupx`)
3. Download `GoogleService-Info.plist`
4. Open Xcode → drag the file into `Runner/` (check "Copy items if needed")

### Web (optional)

1. Click **Add app → Web**
2. Register the app, copy the config snippet
3. Paste into `web/index.html` before `</body>`:

```html
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.0.0/firebase-app.js";
  const firebaseConfig = { /* paste your config here */ };
  initializeApp(firebaseConfig);
</script>
```

---

## 3. Enable Cloud Firestore

1. In the Firebase console → **Firestore Database → Create database**
2. Choose **Start in test mode** (for development)
3. Select a region close to you → **Enable**

> ⚠️ **Production**: Switch to proper security rules before going live (see Section 6).

---

## 4. Android Gradle Setup

Ensure these are present (the project template already includes them):

**`android/build.gradle`** (project-level):
```groovy
dependencies {
    classpath 'com.google.gms:google-services:4.4.2'
}
```

**`android/app/build.gradle`** (app-level), at the bottom:
```groovy
apply plugin: 'com.google.gms.google-services'
```

---

## 5. Firestore Collection Schema

### Collection: `players`

Each document represents one player. Use the player's UUID as the document ID.

| Field | Type | Example |
|-------|------|---------|
| `id` | String | `"p001"` |
| `name` | String | `"Lionel Messi"` |
| `club` | String | `"Inter Miami"` |
| `country` | String | `"Argentina"` |
| `imageUrl` | String | `"https://..."` (or `""`) |
| `number` | Number | `10` |
| `positions` | Array\<String\> | `["CAM", "ST"]` |
| `rating` | Number | `91` |
| `age` | Number | `36` |
| `preferredFoot` | String | `"Left"` |

### Valid Position Values

```
GK, RB, LB, CB, RWB, LWB,
CDM, CM, CAM, RM, LM,
RW, LW, CF, ST
```

### Example Document

```json
{
  "id": "p001",
  "name": "Lionel Messi",
  "club": "Inter Miami",
  "country": "Argentina",
  "imageUrl": "",
  "number": 10,
  "positions": ["CAM", "RW", "ST"],
  "rating": 91,
  "age": 36,
  "preferredFoot": "Left"
}
```

---

## 6. Security Rules (Production)

Navigate to **Firestore → Rules** and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Players are read-only for all users
    match /players/{playerId} {
      allow read: if true;
      allow write: if false;  // Only writable via Admin SDK / console
    }

    // Deny everything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 7. Seeding Players Data

### Option A — Firebase Console (Manual)

1. In Firestore console, open the `players` collection (create it if needed)
2. Click **Add document**
3. Use an auto-generated ID or the player's `id` field
4. Add each field manually using the schema above

### Option B — Import via Script (Recommended)

Use the provided `firestore_seed_data.json` file at the project root.

**Prerequisites:** Node.js + Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase use --add   # select your project
```

Run the seed script:

```bash
node scripts/seed_firestore.js
```

*(Create `scripts/seed_firestore.js` — see example below)*

```js
const admin = require('firebase-admin');
const data = require('../firestore_seed_data.json');

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});

const db = admin.firestore();

async function seed() {
  const batch = db.batch();
  for (const player of data.players) {
    const ref = db.collection('players').doc(player.id);
    batch.set(ref, player);
  }
  await batch.commit();
  console.log(`Seeded ${data.players.length} players.`);
}

seed().catch(console.error);
```

---

## 8. Firestore Indexes

The app queries players using `array-contains-any` on the `positions` field. No composite indexes are required for this — Firestore handles it automatically.

If you add custom sorting (e.g., by `rating` + `positions`), create a composite index:

| Collection | Fields | Order |
|---|---|---|
| `players` | `positions` (Array) + `rating` (Desc) | Ascending / Descending |

---

## 9. Verify the Integration

1. Run the app: `flutter run`
2. Navigate to **Lineup Builder → tap a player slot**
3. The player selection sheet should show players fetched from Firestore
4. Check console for: `[FirebaseService] Fetched X players for positions [...]`

If Firebase is not configured, you'll see:
```
[FirebaseService] Firebase not available, using sample data
```
This is expected and the app will still work with the 38 bundled players.

---

## 10. Troubleshooting

| Problem | Solution |
|---|---|
| `google-services.json not found` | Ensure file is at `android/app/google-services.json` |
| `PlatformException: Firebase App not found` | Check `google-services.json` package name matches `applicationId` |
| `PERMISSION_DENIED` | Update Firestore security rules to allow reads |
| Players not loading from Firestore | Check collection name is exactly `players` (lowercase) |
| `MissingPluginException` | Run `flutter clean && flutter pub get && flutter run` |
