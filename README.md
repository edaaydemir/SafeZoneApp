# 🛡️ SafeZone

> **"Because your safety matters."**  
> SafeZone is an intelligent and beautifully designed mobile app that empowers users to collaboratively map out safe and unsafe locations in real time — creating a shared sense of security for everyone.

---

## 🌍 What is SafeZone?
SafeZone is a Flutter-based mobile application that leverages Firebase to help users:

- 📍 Mark locations as **Safe** or **Unsafe** on a live map.
- 🧑 Create a personalized profile with emoji avatars.
- 👀 Browse marked places from a clear and organized list.
- 📱 Navigate through an intuitive and modern interface.

It’s perfect for communities, travelers, students, and anyone looking to stay informed and contribute to public safety.

> "Turn everyday places into shared signals of safety."

---

## 📸 Screenshots
<!-- Add final screenshots when available -->
```
[ ] 🗺️ Interactive Map View
[ ] ➕ Marker Creation Popups
[ ] 📋 Safe/Unsafe List View
[ ] 👤 Profile Customization
```

---

## ✨ Core Features
- 🔍 **Live Geolocation:** See your current location on the map
- 🧭 **Map Marking:** Long-press to mark safe or unsafe areas
- 🗂️ **Organized List:** View all your zones grouped and sorted
- 🧑‍🎨 **Profile Editing:** Set your display name and emoji avatar
- 🌗 **Theme Switching:** Light and dark mode toggle
- 🔐 **Secure Login:** Sign in with Google or email
- 🔄 **Firebase Sync:** Real-time read/write operations
- ✏️ **Edit & Delete:** Update or remove markers anytime

---

## 🛠️ Technologies Used
- **Flutter (Dart)** — UI framework
- **Firebase Auth** — User authentication
- **Firebase Firestore** — Cloud database
- **flutter_map** — Interactive map rendering
- **latlong2 / geolocator** — Location services

---

## 📦 How to Run
```bash
git clone https://github.com/edaaydemir/SafeZoneApp.git
cd SafeZoneApp
flutter pub get
flutter run
```

---

## 📁 Folder Structure
```
/lib
├── models/           # Marker data structure
├── services/         # Firebase services (CRUD)
├── screens/          # Main UI screens
├── widgets/          # Reusable UI components
```

---

## 👩‍💻 Developer
**Eda Aydemir**  
🎓 Computer Engineering Student @ Eskişehir Technical University  
💬 Firebase | Flutter | UX-first thinking  
📧 edaaydemir200081@gmail.com
🔗 GitHub / LinkedIn: (https://github.com/edaaydemir) / www.linkedin.com/in/edaaydemir12

---

## 🗓️ Next Steps
- [ ] Finalize screenshot assets and insert them
- [ ] Add multilingual support (EN/TR)
- [ ] Enable public marker viewing with filters
- [ ] Publish on Play Store (optional)
