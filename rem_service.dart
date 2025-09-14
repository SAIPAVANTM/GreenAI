// rem_service.dart - Updated version
import 'dart:convert';
import 'package:greenai/url.dart';
import 'package:greenai/rem_model.dart';
import 'package:greenai/notification_service.dart';
import 'package:http/http.dart' as http;

class ReminderService {
  String baseUrl = '${Url.Urls}/api';
  final NotificationService _notificationService = NotificationService();

  Future<Map<String, dynamic>> createReminder({
    required String reminderType,
    required String cropType,
    required String date,
    required String time,
    required String intervalType,
    int userId = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reminders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reminder_type': reminderType,
          'crop_type': cropType,
          'date': date,
          'time': time,
          'interval_type': intervalType,
          'user_id': userId,
        }),
      );

      final result = json.decode(response.body);

      // If reminder was created successfully, schedule notification
      if (result['success'] == true && result['reminder'] != null) {
        try {
          final reminder = ReminderModel.fromJson(result['reminder']);
          await _notificationService.scheduleReminderNotification(reminder);
        } catch (e) {
          print('Error scheduling notification: $e');
          // Don't fail the whole operation if notification scheduling fails
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getReminders({int userId = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reminders?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteReminder(int reminderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reminders/$reminderId'),
        headers: {'Content-Type': 'application/json'},
      );

      final result = json.decode(response.body);

      // If reminder was deleted successfully, cancel notification
      if (result['success'] == true) {
        try {
          await _notificationService.cancelNotification(reminderId);
        } catch (e) {
          print('Error canceling notification: $e');
          // Don't fail the whole operation if notification cancellation fails
        }
      }

      return result;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Method to reschedule all active reminders (useful after app updates)
  Future<void> rescheduleAllNotifications(List<ReminderModel> reminders) async {
    for (final reminder in reminders) {
      if (reminder.isActive) {
        try {
          await _notificationService.scheduleReminderNotification(reminder);
        } catch (e) {
          print('Error rescheduling notification for reminder ${reminder.id}: $e');
        }
      }
    }
  }

  // Test notification method
  Future<void> testNotification() async {
    await _notificationService.showImmediateNotification(
      title: '🌱 Test Notification',
      body: 'Your farming reminder notifications are working!',
      payload: 'test_notification',
    );
  }
}