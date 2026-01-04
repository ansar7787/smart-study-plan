class AppConstants {
  // App Info
  static const String appName = 'Smart Study Planner';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String userBoxName = 'users';
  static const String subjectsBoxName = 'subjects';
  static const String tasksBoxName = 'tasks';
  static const String resourcesBoxName = 'resources';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String subjectsCollection = 'subjects';
  static const String tasksCollection = 'tasks';
  static const String resourcesCollection = 'resources';

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // Validation Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
}
