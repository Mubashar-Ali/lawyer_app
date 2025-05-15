import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../utils/dummy_data.dart';

class PaymentProvider extends ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get payment by ID
  Payment? getPaymentById(String id) {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get payments for a specific client
  List<Payment> getPaymentsForClient(String clientId) {
    return _payments.where((p) => p.clientId == clientId).toList();
  }
  
  // Get payments for a specific case
  List<Payment> getPaymentsForCase(String caseId) {
    return _payments.where((p) => p.caseId == caseId).toList();
  }
  
  // Get payments by status
  List<Payment> getPaymentsByStatus(String status) {
    return _payments.where((p) => 
      p.status.toLowerCase() == status.toLowerCase()
    ).toList();
  }
  
  // Get paid payments
  List<Payment> get paidPayments => _payments.where((p) => p.isPaid).toList();
  
  // Get pending payments
  List<Payment> get pendingPayments => _payments.where((p) => p.isPending).toList();
  
  // Get total amount paid
  double get totalPaid => paidPayments.fold(0, (sum, payment) => sum + payment.amount);
  
  // Get total amount pending
  double get totalPending => pendingPayments.fold(0, (sum, payment) => sum + payment.amount);
  
  // Load payments
  Future<void> loadPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _payments = DummyData.payments;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load payments: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new payment
  Future<bool> addPayment(Payment newPayment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _payments.add(newPayment);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add payment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update a payment
  Future<bool> updatePayment(Payment updatedPayment) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _payments.indexWhere((p) => p.id == updatedPayment.id);
      if (index != -1) {
        _payments[index] = updatedPayment;
      } else {
        throw Exception('Payment not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update payment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update payment status
  Future<bool> updatePaymentStatus(String id, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find and update
      final index = _payments.indexWhere((p) => p.id == id);
      if (index != -1) {
        final payment = _payments[index];
        _payments[index] = payment.copyWith(status: status);
      } else {
        throw Exception('Payment not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update payment status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a payment
  Future<bool> deletePayment(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _payments.removeWhere((p) => p.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete payment: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
}
