import 'package:flutter/material.dart';
import '../models/case.dart';
import '../utils/dummy_data.dart';

class CaseProvider extends ChangeNotifier {
  List<Case> _cases = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Case> get cases => _cases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get cases for a specific client
  List<Case> getCasesForClient(String clientId) {
    return _cases.where((c) => c.clientId == clientId).toList();
  }
  
  // Get case by ID
  Case? getCaseById(String id) {
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Filter cases by status
  List<Case> getCasesByStatus(String status) {
    return _cases.where((c) => c.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Get active cases
  List<Case> get activeCases => _cases.where((c) => c.status.toLowerCase() == 'active').toList();
  
  // Get pending cases
  List<Case> get pendingCases => _cases.where((c) => c.status.toLowerCase() == 'pending').toList();
  
  // Get completed cases
  List<Case> get completedCases => _cases.where((c) => c.status.toLowerCase() == 'completed').toList();
  
  // Load cases
  Future<void> loadCases() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _cases = DummyData.cases;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load cases: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new case
  Future<bool> addCase(Case newCase) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _cases.add(newCase);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add case: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update a case
  Future<bool> updateCase(Case updatedCase) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _cases.indexWhere((c) => c.id == updatedCase.id);
      if (index != -1) {
        _cases[index] = updatedCase;
      } else {
        throw Exception('Case not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update case: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a case
  Future<bool> deleteCase(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _cases.removeWhere((c) => c.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete case: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Search cases
  List<Case> searchCases(String query) {
    if (query.isEmpty) {
      return _cases;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _cases.where((c) => 
      c.title.toLowerCase().contains(lowercaseQuery) ||
      c.clientName.toLowerCase().contains(lowercaseQuery) ||
      c.caseNumber.toLowerCase().contains(lowercaseQuery) ||
      c.court.toLowerCase().contains(lowercaseQuery) ||
      c.caseType.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
