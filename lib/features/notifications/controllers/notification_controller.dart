import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  static const _prefsKey = 'app_notifications';

  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored != null) {
      final List<dynamic> decoded = jsonDecode(stored);
      final loaded = decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      loaded.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifications.assignAll(loaded);
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> addNotification({
    required NotificationType type,
    required String title,
    required String body,
    String? relatedAppointmentId,
  }) async {
    final notification = AppNotification(
      id: const Uuid().v4(),
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      relatedAppointmentId: relatedAppointmentId,
    );

    notifications.insert(0, notification);
    await _saveToPrefs();
  }

  Future<void> markAsRead(String id) async {
    final updated = notifications.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
    notifications.assignAll(updated);
    await _saveToPrefs();
  }

  Future<void> markAllAsRead() async {
    final updated = notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifications.assignAll(updated);
    await _saveToPrefs();
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);
    await _saveToPrefs();
  }
}