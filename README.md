# Student Engagement App

---

## 🚀 Features

- **Browse Clubs & Events**  
  View upcoming events across all clubs; explore club details & membership.

- **Role-Based Access**  
  - **Admin** & **Club President** can create/edit events & discover posts.  
  - **Students** can register for clubs/events.  
  - **Guests** may browse content; “Account icon” prompts sign-in.

- **Discover Feed**  
  Clubs share news, photos & announcements.

- **Profile & Authentication**  
  Sign up / Sign in with school email; view profile & log out.

---

## ⚙️ Simple Project Setup

1. **Clone the repo**  
   ```bash
   git clone https://github.com/your-org/flutter_application_1.git


2. **Install dependencies**  
   ```bash
   flutter pub get


### Firebase Configuration for Team Setup

Each team member needs to download their own Firebase configuration files from the Firebase Console:

1. **Download `google-services.json`** (for Android) from the Firebase Console:
   - Go to the Firebase Console.
   - Select the project.
   - Download the `google-services.json` file.
   - Place the file in `android/app/` in your local project.

2. **Download `GoogleService-Info.plist`** (for iOS) from the Firebase Console:
   - Go to the Firebase Console.
   - Select the project.
   - Download the `GoogleService-Info.plist` file.
   - Place the file in `ios/Runner/` in your local project.

Once these files are added locally, run the app to ensure proper configuration.

--- 

## 🏃‍♂️ Running the App

- **Debug (Android emulator or connected device)**
   ```bash
   flutter run


- **Release build (Android APK)**
   ```bash
   flutter build apk --release


--- 

## 🔧 Firebase Security Rules

We enforce:

- Only signed-in users with `peninsula school emails` can write.

- Guests may read clubs, events & discover posts.

- Admins & club presidents may create/update/delete their own events/discover.

Rules live in `firestore.rules`.

## 🧪 Testing

**Firebase Test Lab (Android):**

1. Generate an unsigned APK:
   ```bash
   flutter build apk --debug

2. Upload to Firebase Console → Test Lab.