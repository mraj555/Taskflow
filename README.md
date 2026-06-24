# TaskFlow 📝✨

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

**TaskFlow** is an advanced, production-ready Todo application engineered with Flutter. It goes beyond the basic "to-do list" by offering robust local persistence, a scalable architecture, and reactive state management. Designed as a blueprint for high-quality Flutter applications, it showcases the integration of SQFlite and Riverpod 3.0.

---

## 🚀 Key Features

*   **Complete CRUD Functionality**: Create, Read, Update, and Delete tasks instantly.
*   **Reactive State Management**: Powered by Riverpod's modern `AsyncNotifier` to ensure the UI perfectly syncs with the local SQLite database without manual `setState` calls.
*   **Priority Tiers**: Categorize tasks by Priority (Low, Medium, High). Visual indicators and custom sorting automatically bring the most important tasks to your attention.
*   **Smart Filtering & Searching**: Instantly query tasks by their title via a search bar. Toggle filters between "Pending" and "Completed" to focus on what matters.
*   **Due Dates**: Integrated Material Date Picker to assign deadlines to tasks.
*   **Dynamic Theme**: Fully leverages Flutter's **Material 3** guidelines, automatically adapting to the device's system Light or Dark mode.

---

## 🛠 Tech Stack Deep Dive

*   **Framework:** [Flutter](https://flutter.dev/) (Dart)
*   **State Management:** [Riverpod 3.0](https://riverpod.dev/) (`flutter_riverpod`). Chosen for its compile-time safety and scalable `AsyncNotifier` capabilities, removing the boiler-plate associated with older state management solutions.
*   **Local Storage:** [SQFlite](https://pub.dev/packages/sqflite). An industry-standard plugin for SQLite databases in Flutter, chosen to demonstrate writing complex raw SQL queries and schema migrations.
*   **Utilities:** 
    *   `intl`: Used to neatly format task due dates.
    *   `uuid`: Generates collision-free unique identifiers for tasks and categories.
    *   `path` & `path_provider`: Used to safely locate the optimal application document directory across Android, iOS, Windows, macOS, and Linux.

---

## 🏗 Architecture & Design Patterns

The codebase strictly adheres to a **Feature-Driven Layered Architecture**. This separation of concerns ensures the application remains highly maintainable and testable as it scales.

### 1. Presentation Layer (UI)
Located under `lib/features/`. This layer contains purely visual components. Widgets are strictly bound to Riverpod `ConsumerStatefulWidget` or `ConsumerWidget` to listen to state changes. 
*   *Example:* `HomeScreen` listens to `taskProvider` and reconstructs the ListView whenever the database changes.

### 2. State Management Layer (Notifiers)
Located under `lib/providers/`. This layer acts as the "ViewModel" or "Controller".
*   `TaskNotifier` extends `AsyncNotifier`. It fetches data from the Repository and handles `loading`, `data`, and `error` states gracefully. It intercepts UI actions (like `addTask`), forwards them to the Repository, and triggers a state refresh.

### 3. Repository Layer
Located under `lib/repositories/`. 
*   `TaskRepository` serves as an abstraction over the raw database. The rest of the app doesn't know *how* tasks are saved (it could be an API or SQLite). This Repository executes the SQL commands and maps the `Map<String, dynamic>` results into typed Dart `Task` objects.

### 4. Data Source Layer (Database)
Located under `lib/core/database/`.
*   `DatabaseHelper` is implemented as a **Singleton** to ensure only one connection to the SQLite database is open at any time. It handles database creation, schema definitions, and table setup.

---

## 🗄️ Database Schema

The app runs on a relational SQLite structure. 

### `tasks` Table
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | TEXT | PRIMARY KEY | Generated UUID |
| `title` | TEXT | NOT NULL | Task title |
| `description` | TEXT | NULL | Optional extended notes |
| `dueDate` | TEXT | NULL | ISO8601 String representation of the date |
| `priority` | INTEGER | NOT NULL | `0` (Low), `1` (Medium), `2` (High) |
| `isCompleted` | INTEGER | NOT NULL | `0` (False), `1` (True) |
| `categoryId` | TEXT | FOREIGN KEY | Links to `categories` table (Nullable) |

---

## 📂 Comprehensive Project Structure

```text
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart      # Singleton DB init, schema definition
│   └── theme/
│       └── app_theme.dart            # Material 3 centralized themes (Light & Dark)
├── features/
│   └── tasks/
│       ├── screens/
│       │   ├── add_edit_task_screen.dart  # Form validation & Task mutation
│       │   └── home_screen.dart           # Riverpod Consumers, Filtering & Searching logic
│       └── widgets/
│           └── task_tile.dart             # Extracted Card widget for modular UI
├── models/
│   ├── category.dart                 # Category entity with mapping logic
│   └── task.dart                     # Task entity, copyWith(), fromMap(), toMap()
├── providers/
│   └── task_provider.dart            # AsyncNotifier implementation for Riverpod 3.0
├── repositories/
│   └── task_repository.dart          # CRUD abstraction wrapping SQL queries
└── main.dart                         # Entry point, ProviderScope initialization
```

---

## 💻 Setup & Installation

Follow these instructions to run TaskFlow locally.

### Prerequisites
1.  Install the [Flutter SDK](https://docs.flutter.dev/get-started/install).
2.  Set up an IDE (VS Code or Android Studio) with Dart & Flutter extensions.
3.  Have a connected physical device or a running Emulator/Simulator.

### Installation Steps

1.  **Clone / Navigate to the repository:**
    ```bash
    cd taskflow
    ```

2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```
    *Tip: You can specify a device using `flutter run -d <device_id>`*

---

## 🔮 Future Enhancements Roadmap

While TaskFlow is completely functional, here are areas where it can be expanded:
*   **Local Push Notifications:** Reminders for overdue tasks using `flutter_local_notifications`.
*   **Cloud Synchronization:** Using Firebase Firestore or Supabase to sync tasks across devices.
*   **Advanced Category Management:** Adding UI to create, delete, and assign color-coded categories.
*   **Animations:** Implementing Hero animations and implicit `flutter_animate` transitions for list additions/deletions.
