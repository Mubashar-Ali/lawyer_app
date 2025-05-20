import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/case_model.dart';

enum CaseSortOption {
  dateNewest,
  dateOldest,
  titleAZ,
  titleZA,
  statusActive,
  statusClosed,
}

class CaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  List<CaseModel> _cases = [];
  List<CaseModel> _cachedCases = []; // For offline support
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _casesSubscription;
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;
  bool _isOffline = false;
  CaseSortOption _currentSortOption = CaseSortOption.dateNewest;

  List<CaseModel> get cases => _getSortedCases();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  CaseSortOption get currentSortOption => _currentSortOption;

  List<CaseModel> get activeCases =>
      _cases.where((caseItem) => caseItem.status == 'Active').toList();

  List<CaseModel> get recentCases {
    final sortedCases = List<CaseModel>.from(_cases);
    sortedCases.sort((a, b) => b.filingDate.compareTo(a.filingDate));
    return sortedCases;
  }

  CaseProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Connectivity? connectivity,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity() {
    // Initialize connectivity listener
    _initConnectivityListener();
    // Initialize real-time listener when provider is created
    initCasesListener();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;

      // If we're back online after being offline, refresh data
      if (wasOffline && !_isOffline) {
        initCasesListener();
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Cancel subscriptions when provider is disposed
    _casesSubscription?.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void setSortOption(CaseSortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  List<CaseModel> _getSortedCases() {
    final sortedCases = List<CaseModel>.from(_cases);

    switch (_currentSortOption) {
      case CaseSortOption.dateNewest:
        sortedCases.sort((a, b) => b.filingDate.compareTo(a.filingDate));
        break;
      case CaseSortOption.dateOldest:
        sortedCases.sort((a, b) => a.filingDate.compareTo(b.filingDate));
        break;
      case CaseSortOption.titleAZ:
        sortedCases.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case CaseSortOption.titleZA:
        sortedCases.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case CaseSortOption.statusActive:
        sortedCases.sort((a, b) {
          if (a.status == 'Active' && b.status != 'Active') return -1;
          if (a.status != 'Active' && b.status == 'Active') return 1;
          return 0;
        });
        break;
      case CaseSortOption.statusClosed:
        sortedCases.sort((a, b) {
          if (a.status == 'Closed' && b.status != 'Closed') return -1;
          if (a.status != 'Closed' && b.status == 'Closed') return 1;
          return 0;
        });
        break;
    }

    return sortedCases;
  }

  void initCasesListener() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Cancel existing subscription if any
    _casesSubscription?.cancel();

    _isLoading = true;
    notifyListeners();

    try {
      // Set up real-time listener with pagination (limit to 50 cases initially)
      _casesSubscription = _firestore
          .collection('cases')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (snapshot) {
              _cases =
                  snapshot.docs
                      .map(
                        (doc) =>
                            CaseModel.fromJson({'id': doc.id, ...doc.data()}),
                      )
                      .toList();

              // Update cache for offline support
              _cachedCases = List.from(_cases);

              _isLoading = false;
              _error = null;
              notifyListeners();
            },
            onError: (error) {
              _isLoading = false;
              _error = error.toString();

              // Use cached data if available
              if (_cachedCases.isNotEmpty) {
                _cases = List.from(_cachedCases);
              }

              notifyListeners();
            },
          );
    } catch (e) {
      _isLoading = false;
      _error = e.toString();

      // Use cached data if available
      if (_cachedCases.isNotEmpty) {
        _cases = List.from(_cachedCases);
      }

      notifyListeners();
    }
  }

  Future<void> fetchCases() async {
    // Check connectivity before fetching
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _isOffline = true;
      // Use cached data if available
      if (_cachedCases.isNotEmpty) {
        _cases = List.from(_cachedCases);
        notifyListeners();
      }
      return;
    }

    _isOffline = false;

    // This method is kept for backward compatibility
    // Real-time updates are handled by the listener
    if (_casesSubscription == null) {
      initCasesListener();
    }
  }

  // Add a method to get cases by client ID
  List<CaseModel> getCasesByClientId(String clientId) {
    return _cases.where((caseItem) => caseItem.clientId == clientId).toList();
  }

  // Update the addCase method to also update the client's caseIds array
  Future<CaseModel> addCase(CaseModel caseData) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Validate case data
      final validationErrors = caseData.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(
          'Validation failed: ${validationErrors.values.join(', ')}',
        );
      }

      final docRef = await _firestore.collection('cases').add({
        ...caseData.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Fetch the created document to get server timestamp

      final newCase = CaseModel(
        id: docRef.id,
        title: caseData.title,
        caseNumber: caseData.caseNumber,
        clientName: caseData.clientName,
        clientId: caseData.clientId,
        caseType: caseData.caseType,
        court: caseData.court,
        status: caseData.status,
        filingDate: caseData.filingDate,
        nextHearing: caseData.nextHearing,
        description: caseData.description,
        documentIds: caseData.documentIds ?? [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update the client's caseIds array
      if (caseData.clientId.isNotEmpty) {
        try {
          await _firestore.collection('clients').doc(caseData.clientId).update({
            'caseIds': FieldValue.arrayUnion([docRef.id]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error updating client caseIds: ${e.toString()}');
          // Continue anyway since the case is created
        }
      }

      // The listener will update the list automatically
      return newCase;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCase(CaseModel updatedCase) async {
    try {
      await _firestore.collection('cases').doc(updatedCase.id).update({
        'title': updatedCase.title,
        'caseNumber': updatedCase.caseNumber,
        'clientId': updatedCase.clientId,
        'clientName': updatedCase.clientName,
        'caseType': updatedCase.caseType,
        'court': updatedCase.court,
        'filingDate': updatedCase.filingDate,
        'nextHearing': updatedCase.nextHearing,
        'status': updatedCase.status,
        'description': updatedCase.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache
      final index = _cases.indexWhere((c) => c.id == updatedCase.id);
      if (index != -1) {
        _cases[index] = updatedCase;
        _cachedCases = List.from(_cases);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateNextHearing(String caseId, DateTime nextHearing) async {
    try {
      await _firestore.collection('cases').doc(caseId).update({
        'nextHearing': nextHearing,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local cache
      final index = _cases.indexWhere((c) => c.id == caseId);
      if (index != -1) {
        _cases[index] = _cases[index].copyWith(nextHearing: nextHearing);
        _cachedCases = List.from(_cases);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update the deleteCase method to also update the client's caseIds array
  Future<void> deleteCase(String caseId) async {
    try {
      // Get the case to check if it has documents and to get the clientId
      final caseToDelete = getCaseById(caseId);

      if (caseToDelete != null) {
        // If the case has a client, update the client's caseIds array
        if (caseToDelete.clientId.isNotEmpty) {
          try {
            await _firestore.collection('clients').doc(caseToDelete.clientId).update({
              'caseIds': FieldValue.arrayRemove([caseId]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            print('Error updating client caseIds: ${e.toString()}');
            // Continue anyway since we still want to delete the case
          }
        }

        // If the case has documents, we don't delete them here
        // That's handled by DocumentProvider
      }

      // Delete the case document
      await _firestore.collection('cases').doc(caseId).delete();
      // The listener will update the list automatically
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  CaseModel? getCaseById(String id) {
    try {
      return _cases.firstWhere((caseItem) => caseItem.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addDocumentToCase(String caseId, String documentId) async {
    try {
      await _firestore.collection('cases').doc(caseId).update({
        'documentIds': FieldValue.arrayUnion([documentId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeDocumentFromCase(String caseId, String documentId) async {
    try {
      await _firestore.collection('cases').doc(caseId).update({
        'documentIds': FieldValue.arrayRemove([documentId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search cases by query string
  List<CaseModel> searchCases(String query) {
    if (query.isEmpty) {
      return _cases;
    }

    final lowercaseQuery = query.toLowerCase();
    return _cases.where((caseItem) {
      return caseItem.title.toLowerCase().contains(lowercaseQuery) ||
          caseItem.caseNumber.toLowerCase().contains(lowercaseQuery) ||
          caseItem.clientName.toLowerCase().contains(lowercaseQuery) ||
          caseItem.court.toLowerCase().contains(lowercaseQuery) ||
          caseItem.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get cases by status
  List<CaseModel> getCasesByStatus(String status) {
    return _cases.where((caseItem) => caseItem.status == status).toList();
  }

  // Get cases by type
  List<CaseModel> getCasesByType(String type) {
    return _cases.where((caseItem) => caseItem.caseType == type).toList();
  }

  // Get cases with upcoming hearings
  List<CaseModel> getCasesWithUpcomingHearings() {
    final now = DateTime.now();
    return _cases.where((caseItem) {
      if (caseItem.nextHearing == null) return false;
      return caseItem.nextHearing!.isAfter(now);
    }).toList();
  }

  // Get cases with upcoming hearings in the next 7 days
  List<CaseModel> getUpcomingHearings() {
    final now = DateTime.now();
    final nextWeek = now.add(Duration(days: 7));

    return _cases.where((caseItem) {
      if (caseItem.nextHearing == null) return false;
      return caseItem.nextHearing!.isAfter(now) &&
          caseItem.nextHearing!.isBefore(nextWeek);
    }).toList();
  }

  // Get case statistics
  Map<String, dynamic> getCaseStatistics() {
    final totalCases = _cases.length;
    final activeCases = _cases.where((c) => c.status == 'Active').length;
    final pendingCases = _cases.where((c) => c.status == 'Pending').length;
    final closedCases = _cases.where((c) => c.status == 'Closed').length;

    final caseTypes = <String, int>{};
    for (var caseItem in _cases) {
      caseTypes[caseItem.caseType] = (caseTypes[caseItem.caseType] ?? 0) + 1;
    }

    return {
      'totalCases': totalCases,
      'activeCases': activeCases,
      'pendingCases': pendingCases,
      'closedCases': closedCases,
      'caseTypes': caseTypes,
    };
  }
}
