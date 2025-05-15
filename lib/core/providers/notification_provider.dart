import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../utils/dummy_data.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get unread notifications
  List<AppNotification> get unreadNotifications => _notifications.where((n) => !n.isRead).toList();
  
  // Get notification count
  int get notificationCount => unreadNotifications.length;
  
  // Load notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _notifications = DummyData.notifications;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Mark notification as read
  Future<bool> markAsRead(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find and update
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = notification.copyWith(isRead: true);
      } else {
        throw Exception('Notification not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to mark notification as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update all notifications
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to mark all notifications as read: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a notification
  Future<bool> deleteNotification(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Remove from list
      _notifications.removeWhere((n) => n.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete notification: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Clear all notifications
  Future<bool> clearAllNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Clear list
      _notifications = [];
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to clear notifications: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
