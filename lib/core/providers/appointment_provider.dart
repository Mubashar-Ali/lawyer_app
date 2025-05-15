import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/dummy_data.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get appointment by ID
  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get appointments for a specific client
  List<Appointment> getAppointmentsForClient(String clientId) {
    return _appointments.where((a) => a.clientId == clientId).toList();
  }
  
  // Get appointments for a specific date
  List<Appointment> getAppointmentsForDate(DateTime date) {
    return _appointments.where((a) => 
      a.startTime.year == date.year && 
      a.startTime.month == date.month && 
      a.startTime.day == date.day
    ).toList();
  }
  
  // Get upcoming appointments
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
      .where((a) => a.startTime.isAfter(now))
      .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  // Get today's appointments
  List<Appointment> get todayAppointments {
    final now = DateTime.now();
    return _appointments.where((a) => 
      a.startTime.year == now.year && 
      a.startTime.month == now.month && 
      a.startTime.day == now.day
    ).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
  
  // Load appointments
  Future<void> loadAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _appointments = DummyData.appointments;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load appointments: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new appointment
  Future<bool> addAppointment(Appointment newAppointment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _appointments.add(newAppointment);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update an appointment
  Future<bool> updateAppointment(Appointment updatedAppointment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _appointments.indexWhere((a) => a.id == updatedAppointment.id);
      if (index != -1) {
        _appointments[index] = updatedAppointment;
      } else {
        throw Exception('Appointment not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete an appointment
  Future<bool> deleteAppointment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _appointments.removeWhere((a) => a.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete appointment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
