## App Logo
Click on a logo to download the latest version of the app apk file:

<a href="https://github.com/ArpitAswal/TaskTracker/releases/download/v3.0.0/TaskTracker.apk"> ![ic_launcher](https://github.com/user-attachments/assets/7ae48f6f-cef0-4588-b2d5-89243e7cf083)</a>

# Project Title: Task Tracker

TaskTracker is a mobile application developed using the Flutter framework, designed to help users efficiently manage and track their daily tasks. With a user-friendly interface and a range of features, it simplifies task organization while providing timely notifications to keep users on track.

TaskTracker is more than just a task management tool—it is a productivity partner that helps users organize their lives, stay informed about their progress, and receive timely reminders to ensure they never miss a task.

## 📌 Features

🏠 **Splash Screen:** Animated splash screen for an engaging user experience.

🔐 **Authentication System**
- Email/Password Authentication
- User Role Management (Admin/User)
- Profile Management
- Account Deletion

📋 **Task Management:**  Tasks are organized into two categories using TabBar and TabBarView. Users can navigate between tabs via swiping or tab selection.

- ***Pending Tasks:*** Displays tasks that are not yet completed and still active based on their end date.

- ***Completed Tasks:*** Shows all tasks marked as finished.

- ***Create, Read, Update, Delete (CRUD) Tasks:*** Users can manage tasks completely through an intuitive UI

- ***Task Progress Visualization:*** Users can monitor their task completion percentage directly from the Profile Screen.

✏️ **Adding/Updating Tasks :** While creating or editing a task, users are required to fill in the following:

- What are you planning? — Enter a concise title or name for the task.

- Write a task description — Add any details necessary to describe the task.

- Start Date — The date when the task should begin.

- End Date — The deadline or due date for the task.

- Specific Hour Reminder (Optional) — Enable a checkbox and select a specific hour if the user wants a notification for this task at a particular time.

🛠️ **How to Perform Task CRUD Operations :**

✅ ***Add Task:*** Tap the Floating Action Button (FAB) on the main screen to open the task creation form.

✏️ ***Edit Task:*** Slide the task card from left to right to open the edit screen and modify task details.

🗑️ ***Delete Task:*** Slide the task card from right to left to delete the task permanently.

✔️ ***Mark as Done:*** Slide the task card from right to left and tap the "Mark as Done" button to complete the task.

🎨 **UI/UX**
- Dark/Light Theme Support
- Animated Splash Screen
- Intuitive Task Cards
- Responsive Design
- Custom Drawer Navigation

📂 **Data Persistence**
- Offline Support using Hive
- Real-time Firebase Integration
- Background Task Processing

🔔 **Notification System**

- **Task Addition Notification:** A local notification is triggered immediately when a new task is added, confirming the action.

- **Pending Task Notification:** Periodic notifications (default: every 1 hour) remind users about only those pending tasks whose end date matches the current day. The user can customize the reminder frequency from the Profile Screen.

- **Specific Hour Task Notification:** While adding or updating a task, users can enable an hour-specific notification by selecting a checkbox and setting a time. This reminder is sent in addition to periodic reminders.

- **FCM Support:** Admin users can broadcast push notifications to all or selected users through the Admin Panel by specifying a title and description.

## App UI

- The app start with Animated splash screen for an engaging user experience and follows the Authentication System **Email/Password Authentication** and **Register Authentication** by selecting account type either **User** or **Admin**. If Admin then the user have to write the Admin Key. For a forgot password function the screen is also available by tapping on text.

https://github.com/user-attachments/assets/9d7bc697-a99c-4e79-8749-fa3820c2b36a

- After the **register** your account the user will come across first at **Onboarding Screen** and then the **Main Screen**. In the main screen, the app will ask the some **permissions** from the users for the first time to provide some app functionality, the user can see their **Pending and Complete Tasks**, and how to edit, create, delete and do the tasks, also there is **Profile Screen** here the user has to update the info by adding their name at least for one time, and can see their **Task performance percentage**.

https://github.com/user-attachments/assets/a80d8d21-95c9-4369-bf36-c84ffed4966b

- From the **Setting Screen**, the user can change the app's features, such as **Theme Change**, **Initialize and Decompose permissions**, **Delete All Tasks** at once, and **Delete Account**. More features will be available in the future. By the way, if the user is an Admin, then the user can send all notifications from the **Admin Panel Screen**. For now, it is a simple notification. The user can add the title and description of the notification.

https://github.com/user-attachments/assets/ead9388c-5a0c-44fe-93cc-122d4a3f3185

## 📥 Installation

#### To run this project locally:

- Clone the repository: git clone https://github.com/ArpitAswal/TaskTracker.git
- Navigate to the project directory: cd TaskTracker
- Install dependencies: flutter pub get
- Run the app: flutter run

## Tech Stack
**Frontend:** Flutter

**State Management:** Provider Pattern

**Database**

- Local: Hive
- Cloud: Firebase Firestore

**Authentication:** Firebase Auth

**Notifications**

- Firebase Cloud Messaging
- Flutter Local Notifications

**Background Processing:** Workmanager

**API Integration:** Node.js Backend (for FCM)

## Usage/Examples

- **Daily Task Management :** Track and manage personal, study, or work-related tasks.
- **Study Planning :** Organize study plans for better time management.
- **Event Tracking:** Plan and monitor future events or goals.

## ⚠️ Notes
- To run this project make sure you first add your firebase_options.dart and goofle-services.json file in their respective places.

- The app requires notification and battery optimization permissions for optimal functionality.

- Users must disable battery saver for the app to ensure reliable notifications.

- Admin users have additional privileges like sending broadcast notifications.

- Firebase configuration must be set up with proper credentials.

- Backend server needs to be configured for FCM token management.

- Scheduled notifications may occasionally be delayed due to OS background processing.

- Ensure all necessary dependencies are added to pubspec.yaml and required permissions are granted in AndroidManifest.xml.

## New Update
- From v3.0.0 only single periodic task is schedule for default frequency 4 hours. User can also change the frequency duration of Task Remainder Notification from the Profile Screen.

## 🔥 Challenges
#### Background Task Management

- Managing Firebase service initialization in the background.

- Implementing reliable background notifications using WorkManager.

- Extensive research and testing to ensure stable background execution.

#### State Management

- Coordinating multiple Provider instances efficiently.

- Handling complex state updates across different screens.

- Managing authentication state across sessions.

#### Data Synchronization

- Ensuring consistency between local storage and Firebase.

- Handling offline-to-online transitions smoothly.

- Implementing real-time updates without performance issues.

## 🛠️ Future Enhancements

#### Task History by Calendar Month
- Allow users to view a history of their tasks categorized by calendar months and years.
- Provide statistics on the number of tasks completed in each month.

#### Task Alarm
- Enable users to set a specific time for each task, provide notifications or alarms when the set time ends, notifying users that the allocated time for the task has been completed.

#### Enhance Notification UI
- For now, Admin can only write title and description of notification but in future there will be more features will be available to improve the notification UI and for better user experience.

## 👏 Contributing
Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

#### Fork the Repository:

- Go to the original repository on GitHub or GitLab.
- Click the "Fork" button. This creates a copy of the repository under your own account.

#### Create a New Branch:

- Clone your forked repository to your local machine: git clone <your_fork_url>
- Create a new branch for your feature: git checkout -b feature-branch
- Replace feature-branch with a descriptive name for your changes (e.g., fix-bug, add-feature).

#### Make Changes and Commit:
- Make the necessary changes to the code in your local feature-branch.
- Stage the changes: git add (or git add . to stage all changes)
- Commit the changes with a clear message: git commit -m "Add new feature"
- Use a descriptive and concise message that explains the changes.

#### Push Changes to Your Fork:
- Push your feature-branch to your remote repository: git push origin feature-branch

#### Create a Pull Request:
- Go back to the original repository on GitHub or GitLab.
- Click the "New Pull Request" button.
- Select your feature-branch as the source and the original repository's main or develop branch as the target.
- Provide a clear description of your changes and why they are needed.
- Submit the pull request.

## Feedback

- If you have any feedback, please reach out to me at arpitaswal995@gmail.com
- If you face an issue, then open an issue in a GitHub repository.

## 🎯 Design Philosophy
🚀 TaskTracker is designed to enhance productivity and simplify task management. Get started today and take control of your tasks like never before! 🚀

**TaskTracker is built on these core principles:**

#### 👨🏻‍💼 User-Centric Design

- Intuitive and seamless user experience.
- Flexible task management options.
- Personalized themes and notifications.

#### 🔒 Reliability & Security

- Offline-first architecture for accessibility.
- Secure authentication with role-based access control.
- Persistent data storage with strong error handling.

#### ⚡ Performance

- Efficient local storage for better app performance.
- Optimized background processes to save battery life.
- Smooth animations and transitions for better UI experience.

