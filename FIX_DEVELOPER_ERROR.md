# 🚨 CRITICAL FIX: Add SHA-1 Fingerprint to Firebase

The error `DEVELOPER_ERROR` in your logs confirms that your app is blocked because your **Debug Certificate (SHA-1)** is missing from the Firebase Console.

This is why everything else failed. Firebase doesn't trust your app yet.

## 🛠️ Step 1: Get Your SHA-1 Fingerprint

Since the terminal tool is having trouble, you need to do this:

1.  Open **Android Studio**.
2.  Open your project (`d:\FlutterProject\stray_resuce_bih`).
3.  Look at the **Right Sidebar** for a tab called **Gradle**. Click it.
4.  Open: `stray_resuce_bih` -> `android` -> `Tasks` -> `android` -> `signingReport`.
    *   (Double-click `signingReport`)
5.  Look at the **Run/Bottom Console**.
6.  Find the section for `Variant: debug`.
7.  Copy the code next to `SHA1:`.
    *   It looks like: `5E:8F:16:06:2E:A3:CD:2C:4A:9D:5D:8C:F9:...`

## 🛠️ Step 2: Add to Firebase

1.  Go to [Firebase Console](https://console.firebase.google.com).
2.  Open your project.
3.  Click the ⚙️ **Gear Icon** (Project Settings).
4.  Scroll down to **"Your Apps"** and select the **Android App**.
5.  Click **"Add fingerprint"**.
6.  **Paste** the SHA-1 you copied.
7.  Click **Save**.

## 🛠️ Step 3: Re-download Config (Important)

1.  In the same Firebase screen, click **"google-services.json"** to download the updated file.
2.  **Replace** the old file in your project:
    *   `d:\FlutterProject\stray_resuce_bih\android\app\google-services.json`

## 🚀 Step 4: Restart & Test

1.  **Stop** the running app completely.
2.  Run `flutter clean`.
3.  Run `flutter run`.

### ✅ Expected Result
The `DEVELOPER_ERROR` will disappear.
Your "Try Manual Fetch" button will show **Green Cards**.
My Reports will show your data.

---

**This is the final key to unlocking the database connection!** 🔑
