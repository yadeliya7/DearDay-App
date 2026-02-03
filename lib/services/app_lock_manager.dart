class AppLockManager {
  /// Tracks if the Auth/Lock screen is currently being shown.
  /// Used to prevent double-triggering regular lock checks when
  /// system auth dialogs pause/resume the app.
  static bool isAuthScreenVisible = false;

  /// Tracks the last time successful authentication occurred.
  /// Used for the "Grace Period" (e.g., don't ask for generic lock again immediately).
  static DateTime? lastAuthTime;

  /// Checking if we should require auth based on time
  static bool shouldRequireAuth() {
    if (lastAuthTime == null) return true;
    final diff = DateTime.now().difference(lastAuthTime!);
    return diff.inSeconds > 60; // 60s grace period
  }

  static void recordSuccess() {
    lastAuthTime = DateTime.now();
  }
}
