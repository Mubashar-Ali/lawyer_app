import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/client_model.dart';

enum ClientSortOption {
  nameAZ,
  nameZA,
  dateNewest,
  dateOldest,
  mostCases,
}

class ClientProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  List<ClientModel> _clients = [];
  List<ClientModel> _cachedClients = []; // For offline support
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _clientsSubscription;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;
  ClientSortOption _currentSortOption = ClientSortOption.nameAZ;

  List<ClientModel> get clients => _getSortedClients();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  ClientSortOption get currentSortOption => _currentSortOption;

  ClientProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Connectivity? connectivity,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance,
    _connectivity = connectivity ?? Connectivity() {
    // Initialize connectivity listener
    _initConnectivityListener();
    // Initialize real-time listener when provider is created
    initClientsListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;

      // If we're back online after being offline, refresh data
      if (wasOffline && !_isOffline) {
        initClientsListener();
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Cancel subscriptions when provider is disposed
    _clientsSubscription?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void setSortOption(ClientSortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  List<ClientModel> _getSortedClients() {
    final sortedClients = List<ClientModel>.from(_clients);

    switch (_currentSortOption) {
      case ClientSortOption.nameAZ:
        sortedClients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ClientSortOption.nameZA:
        sortedClients.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case ClientSortOption.dateNewest:
        sortedClients.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ClientSortOption.dateOldest:
        sortedClients.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ClientSortOption.mostCases:
        sortedClients.sort((a, b) => b.caseCount.compareTo(a.caseCount));
        break;
    }

    return sortedClients;
  }

  void initClientsListener() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Cancel existing subscription if any
    _clientsSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    try {
      // Set up real-time listener with pagination (limit to 50 clients initially)
      _clientsSubscription = _firestore
          .collection('clients')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (snapshot) {
              _clients = snapshot.docs
                  .map((doc) => ClientModel.fromJson({'id': doc.id, ...doc.data()}))
                  .toList();

              // Update cache for offline support
              _cachedClients = List.from(_clients);

              _isLoading = false;
              _error = null;
              notifyListeners();
            },
            onError: (error) {
              _isLoading = false;
              _error = error.toString();

              // Use cached data if available
              if (_cachedClients.isNotEmpty) {
                _clients = List.from(_cachedClients);
              }

              notifyListeners();
            },
          );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();

      // Use cached data if available
      if (_cachedClients.isNotEmpty) {
        _clients = List.from(_cachedClients);
      }

      notifyListeners();
    }
  }

  Future<void> fetchClients() async {
    // Check connectivity before fetching
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isOffline = true;
      // Use cached data if available
      if (_cachedClients.isNotEmpty) {
        _clients = List.from(_cachedClients);
        notifyListeners();
      }
      return;
    }

    _isOffline = false;

    // This method is kept for backward compatibility
    // Real-time updates are handled by the listener
    if (_clientsSubscription == null) {
      initClientsListener();
    }
  }

  Future<ClientModel> addClient(ClientModel client) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Validate client data
      final validationErrors = client.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception('Validation failed: ${validationErrors.values.join(', ')}');
      }

      final docRef = await _firestore.collection('clients').add({
        ...client.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the created document to get server timestamp

      final newClient = ClientModel(
        id: docRef.id,
        name: client.name,
        email: client.email,
        phone: client.phone,
        address: client.address,
        clientSince: client.clientSince,
        caseIds: client.caseIds,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // The listener will update the list automatically
      return newClient;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateClient(ClientModel updatedClient) async {
    try {
      await _firestore.collection('clients').doc(updatedClient.id).update({
        'name': updatedClient.name,
        'email': updatedClient.email,
        'phone': updatedClient.phone,
        'address': updatedClient.address,
        'clientSince': updatedClient.clientSince,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache
      final index = _clients.indexWhere((c) => c.id == updatedClient.id);
      if (index != -1) {
        _clients[index] = updatedClient;
        _cachedClients = List.from(_clients);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      // Get the client to check if it has cases
      final clientToDelete = getClientById(clientId);

      if (clientToDelete != null && clientToDelete.caseIds.isNotEmpty) {
        // We don't delete the actual cases here - that's handled by CaseProvider
        // Just remove the client reference
      }

      // Delete the client document
      await _firestore.collection('clients').doc(clientId).delete();
      // The listener will update the list automatically
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  ClientModel? getClientById(String id) {
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCaseToClient(String clientId, String caseId) async {
    try {
      await _firestore.collection('clients').doc(clientId).update({
        'caseIds': FieldValue.arrayUnion([caseId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeCaseFromClient(String clientId, String caseId) async {
    try {
      await _firestore.collection('clients').doc(clientId).update({
        'caseIds': FieldValue.arrayRemove([caseId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search clients by query string
  List<ClientModel> searchClients(String query) {
    if (query.isEmpty) {
      return _clients;
    }

    final lowercaseQuery = query.toLowerCase();
    return _clients.where((client) {
      return client.name.toLowerCase().contains(lowercaseQuery) ||
          client.email.toLowerCase().contains(lowercaseQuery) ||
          client.phone.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get client statistics
  Map<String, dynamic> getClientStatistics() {
    final totalClients = _clients.length;
    final clientsWithCases = _clients.where((c) => c.caseIds.isNotEmpty).length;
    final clientsWithoutCases = totalClients - clientsWithCases;

    return {
      'totalClients': totalClients,
      'clientsWithCases': clientsWithCases,
      'clientsWithoutCases': clientsWithoutCases,
    };
  }
}
