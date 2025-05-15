import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/dummy_data.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get task by ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get tasks for a specific case
  List<Task> getTasksForCase(String caseId) {
    return _tasks.where((t) => t.caseId == caseId).toList();
  }
  
  // Get tasks for a specific client
  List<Task> getTasksForClient(String clientId) {
    return _tasks.where((t) => t.clientId == clientId).toList();
  }
  
  // Get pending tasks
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  
  // Get completed tasks
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList()
    ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  
  // Get overdue tasks
  List<Task> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((t) => 
      !t.isCompleted && t.dueDate.isBefore(now)
    ).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  // Get tasks due today
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _tasks.where((t) => 
      !t.isCompleted && 
      t.dueDate.year == now.year && 
      t.dueDate.month == now.month && 
      t.dueDate.day == now.day
    ).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  // Get tasks by priority
  List<Task> getTasksByPriority(String priority) {
    return _tasks.where((t) => 
      !t.isCompleted && t.priority.toLowerCase() == priority.toLowerCase()
    ).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  // Load tasks
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _tasks = DummyData.tasks;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load tasks: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new task
  Future<bool> addTask(Task newTask) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _tasks.add(newTask);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update a task
  Future<bool> updateTask(Task updatedTask) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      } else {
        throw Exception('Task not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Toggle task completion status
  Future<bool> toggleTaskStatus(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find and update
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        final task = _tasks[index];
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      } else {
        throw Exception('Task not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update task status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a task
  Future<bool> deleteTask(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _tasks.removeWhere((t) => t.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete task: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
