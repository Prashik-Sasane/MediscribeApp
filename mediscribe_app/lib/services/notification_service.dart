/// Simple in-app notification service
class NotificationService {
  static final List<AppNotification> _notifications = [];
  static final List<Function()> _listeners = [];

  /// Add a new notification
  static void addNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    Map<String, dynamic>? data,
  }) {
    final notification = AppNotification(
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      data: data,
    );

    _notifications.insert(0, notification); // Add to beginning
    _notifyListeners();

    // Auto-remove after 24 hours
    Future.delayed(const Duration(hours: 24), () {
      _notifications.remove(notification);
    });
  }

  /// Get all notifications
  static List<AppNotification> getNotifications() {
    return List.unmodifiable(_notifications);
  }

  /// Get unread count
  static int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  /// Mark notification as read
  static void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  /// Mark all as read
  static void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }

  /// Clear all notifications
  static void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  /// Remove specific notification
  static void removeAt(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      _notifyListeners();
    }
  }

  /// Add listener for changes
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

/// Notification type enum
enum NotificationType {
  info,
  success,
  warning,
  error,
}

/// Notification model
class AppNotification {
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // Extra data like appointmentId, doctorId, etc.

  AppNotification({
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  /// Get icon for notification type
  String getIcon() {
    switch (type) {
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.success:
        return '✅';
      case NotificationType.warning:
        return '⚠️';
      case NotificationType.error:
        return '❌';
    }
  }

  /// Get color for notification type
  String getColor() {
    switch (type) {
      case NotificationType.info:
        return '#2E7DFF';
      case NotificationType.success:
        return '#4CAF50';
      case NotificationType.warning:
        return '#FF9800';
      case NotificationType.error:
        return '#F44336';
    }
  }

  /// Format timestamp
  String getTimeAgo() {
    final difference = DateTime.now().difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
