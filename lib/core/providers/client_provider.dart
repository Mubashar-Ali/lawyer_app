import 'package:flutter/material.dart';
import '../models/client.dart';
import '../utils/dummy_data.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get client by ID
  Client? getClientById(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Load clients
  Future<void> loadClients() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _clients = DummyData.clients;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load clients: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new client
  Future<bool> addClient(Client newClient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _clients.add(newClient);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add client: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update a client
  Future<bool> updateClient(Client updatedClient) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _clients.indexWhere((c) => c.id == updatedClient.id);
      if (index != -1) {
        _clients[index] = updatedClient;
      } else {
        throw Exception('Client not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update client: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a client
  Future<bool> deleteClient(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _clients.removeWhere((c) => c.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete client: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Search clients
  List<Client> searchClients(String query) {
    if (query.isEmpty) {
      return _clients;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _clients.where((c) => 
      c.name.toLowerCase().contains(lowercaseQuery) ||
      c.email.toLowerCase().contains(lowercaseQuery) ||
      c.phone.toLowerCase().contains(lowercaseQuery) ||
      c.address.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
