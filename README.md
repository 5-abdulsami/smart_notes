# Notes App — Tasks, Notes & Calendar

A modern, elegant, and fully-featured productivity suite built with **Flutter**, utilizing **GetX** for state management and **MVVM architecture**. Notes App provides a seamless experience for managing tasks, notes, and calendar events with a focus on clean code, responsive UI, and robust data management.

---

## ✨ Features

### 🎨 Dark & Elegant UI
* **Professional Dark Theme:** Beautiful, spacious, and clutter-free interface designed for focus.
* **Consistent Styling:** Unified design language across all modules.

### 📱 Fully Responsive
* **No Hardcoded Sizes:** All UI elements (fonts, spacing, icons) scale dynamically using global media query variables.
* **Adaptive Layouts:** Optimized for various screen sizes and aspect ratios.

### 🧭 Navigation & Core Modules
Notes App is divided into three primary hubs via a ripple-free Bottom Navigation Bar:
1.  **Tasks:** Manage to-dos with reminders, completion states, and intuitive sorting.
2.  **Notes:** Create rich notes with bold/underline formatting, dynamic font sizes, and checklists.
3.  **Calendar:** A full monthly view to manage events with PKT (Pakistan Time) support, location tagging, and reminders.

---

## 🛠 Functional Highlights

### ✅ Tasks
* Add, edit, delete, and reorder tasks.
* Set specific reminders for high-priority items.
* Mark tasks as complete with visual strikethrough.
* Interactive, swipeable cards for a fast workflow.

### 📝 Notes
* **Rich Text Tools:** In-app formatting for Bold, Underline, and Font Size.
* **Checklists:** Integrated checkbox support for list-making.
* **Auto-Focus Management:** Keyboard dismisses automatically when tapping outside inputs.
* View creation dates and enjoy fast, fluid editing.

### 📅 Calendar
* Monthly view with easy year/month selection.
* Event management including Time, Location, and Reminder triggers.
* **PKT Timezone:** Optimized for Pakistan Time with a clean, dark-themed picker.
* Swipe gestures to navigate between months.

### 💾 Data Backup & Restore
* **Custom Export:** Backup all data to a JSON file and choose your preferred save location.
* **Seamless Restore:** Select a JSON backup from your file manager to migrate or recover data.
* **Hive Storage:** Powered by Hive for ultra-fast, reliable offline access.

---

## 🏗️ Architecture & Tech Stack

Notes App follows the **MVVM (Model-View-ViewModel)** pattern combined with **GetX** for dependency injection and state management.

* **State Management:** `GetX` (Reactive programming)
* **Database:** `Hive` (NoSQL local storage)
* **Formatting:** `intl` (Date/Time localization)
* **File Handling:** `file_picker` (Custom backup/restore paths)
* **Architecture:** Clean separation of Concerns (Data, Core, Presentation)

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK
* Dart SDK
* An Android/iOS Emulator or Physical Device

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/notes_app.git](https://github.com/5-abdulsami/notes_app.git)
   cd notes_app

```

2. **Install dependencies:**
```bash
flutter pub get

```


3. **Generate Hive TypeAdapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs

```


4. **Run the app:**
```bash
flutter run

```



---

## 🗂 Project Structure

```text
lib/
├── core/
│   ├── theme/          # AppTheme colors and styles
│   └── utils/          # Responsive helper & global variables
├── data/
│   ├── models/         # Task, Note, and Event data models
│   └── services/       # Storage and Backup services
└── presentation/
    ├── controllers/    # GetX Controllers (Logic)
    ├── screens/        # UI Screens (Tasks, Notes, Calendar, Home)
    └── widgets/        # Reusable UI components

```

---

## 📝 License

This project is licensed under the MIT License.

## 👤 Author

**Abdul Sami**

* Organize your life, your way.
* Enjoy using **Notes App**!

---
