# Task Manager

This is a Flutter-based task management application. It allows users to sign up, log in, and manage 
their own tasks and subtasks. The app features local persistence with Hive, real-time 
synchronization with Firebase Firestore, and state management using Provider.

## Features

- **User Authentication**
    - Sign up and log in with email/password or Google Sign-In.
    - Secure logout that clears the user's tasks from the UI.

- **Task Management**
    - Create, edit, and delete tasks.
    - Mark tasks as completed or pending.
    - Assign priorities (Low, Medium, High) and due dates.

- **Subtask Management**
    - Add, edit, delete, and toggle completion of subtasks within tasks.

- **Multi-User Support**
    - Each task is associated with a specific user (using a `userId` field).
    - Only tasks belonging to the logged-in user are displayed.

- **Local and Remote Data Sync**
    - Local storage via Hive for offline access.
    - Cloud storage and real-time synchronization via Firebase Firestore.

- **Theming and Search**
    - Dark and light themes.
    - Task search functionality.

## Setup Instructions

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Firebase account](https://firebase.google.com/) (for authentication and Firestore)
- [Hive](https://docs.hivedb.dev/) (for local data persistence)
- A code editor (e.g., VS Code or Android Studio)

### Steps

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/MboyaDan/task_manager.git
   cd task_manager
   
Approach Overview

Architecture & State Management
Separation of Concerns:

The application separates UI, business logic, and data layers. Authentication, task management, 
and theming are handled by their respective controllers.

Provider & ChangeNotifier:
    
We use Provider for state management. The AuthController, TaskController, and 
ThemeController extend ChangeNotifier to update the UI upon state changes. 
A ChangeNotifierProxyProvider is used to inject the current user's ID into 
the TaskController, ensuring that each user sees only their own tasks.

Data Persistence & Synchronization

Local Persistence with Hive:
Tasks and subtasks are stored locally using Hive for quick access and offline support.

Real-Time Sync with Firestore:
The app listens to Firestore snapshots to keep local data in sync with the cloud, ensuring
real-time updates across devices.

Authentication Flow

Firebase Authentication:
    Users can sign up and log in using email/password or Google Sign-In.
The authentication state is monitored via Firebase, and the UI is updated accordingly through
an AuthWrapper widget that directs users to either the login screen or the task list.

Logout Handling:
On logout, the navigation stack is cleared to ensure the user is 
redirected to the login screen, and the task list is cleared to prevent one user’s data 
from appearing for another.

UI & UX
Responsive UI:
The UI is designed for responsiveness. Key features include a search bar, task and 
subtask management options, and theme toggling.

Modular Widgets:
    UI components like TaskCard, SubtasksList, 
and AuthForm are separated into their own widgets for better maintainability and clarity.
