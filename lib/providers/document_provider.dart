import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../models/document_model.dart';

enum DocumentSortOption {
  dateNewest,
  dateOldest,
  nameAZ,
  nameZA,
  sizeSmallest,
  sizeLargest,
  type,
}

class DocumentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  List<DocumentModel> _documents = [];
  // For offline support
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DocumentSortOption _currentSortOption = DocumentSortOption.dateNewest;

  List<DocumentModel> get documents => _getSortedDocuments();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  DocumentSortOption get currentSortOption => _currentSortOption;

  DocumentProvider({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Connectivity? connectivity,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _connectivity = connectivity ?? Connectivity() {
    // Initialize connectivity listener
    _initConnectivityListener();
    // Load local documents
    _loadLocalDocuments();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      _isOffline =
          !results.contains(ConnectivityResult.wifi) &&
          !results.contains(ConnectivityResult.mobile) &&
          !results.contains(ConnectivityResult.ethernet);

      notifyListeners();
    });
  }

  @override
  void dispose() {
    // Cancel subscriptions when provider is disposed
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void setSortOption(DocumentSortOption option) {
    _currentSortOption = option;
    notifyListeners();
  }

  List<DocumentModel> _getSortedDocuments() {
    final sortedDocuments = List<DocumentModel>.from(_documents);

    switch (_currentSortOption) {
      case DocumentSortOption.dateNewest:
        sortedDocuments.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        break;
      case DocumentSortOption.dateOldest:
        sortedDocuments.sort((a, b) => a.uploadDate.compareTo(b.uploadDate));
        break;
      case DocumentSortOption.nameAZ:
        sortedDocuments.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case DocumentSortOption.nameZA:
        sortedDocuments.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case DocumentSortOption.sizeSmallest:
        sortedDocuments.sort((a, b) {
          final sizeA = _parseSize(a.size);
          final sizeB = _parseSize(b.size);
          return sizeA.compareTo(sizeB);
        });
        break;
      case DocumentSortOption.sizeLargest:
        sortedDocuments.sort((a, b) {
          final sizeA = _parseSize(a.size);
          final sizeB = _parseSize(b.size);
          return sizeB.compareTo(sizeA);
        });
        break;
      case DocumentSortOption.type:
        sortedDocuments.sort(
          (a, b) => a.type.toLowerCase().compareTo(b.type.toLowerCase()),
        );
        break;
    }

    return sortedDocuments;
  }

  // Helper to parse size string to double for sorting
  double _parseSize(String size) {
    try {
      final parts = size.split(' ');
      if (parts.length != 2) return 0;

      final value = double.tryParse(parts[0]) ?? 0;
      final unit = parts[1].toUpperCase();

      if (unit == 'KB') return value;
      if (unit == 'MB') return value * 1024;
      if (unit == 'GB') return value * 1024 * 1024;

      return value;
    } catch (e) {
      return 0;
    }
  }

  // Load documents from local storage
  Future<void> _loadLocalDocuments() async {
    try {
      _isLoading = true;
      // notifyListeners();

      final directory = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${directory.path}/documents');

      // Create the directory if it doesn't exist
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      // Load the document metadata file if it exists
      final metadataFile = File('${directory.path}/document_metadata.json');
      if (await metadataFile.exists()) {
        final metadataString = await metadataFile.readAsString();
        final List<dynamic> metadataList = json.decode(metadataString);

        _documents =
            metadataList.map((metadata) {
              return DocumentModel.fromJson(metadata);
            }).toList();

        // Update cache for offline support
      }

      _isLoading = false;
      // notifyListeners();
    } catch (e) {
      print('Error loading local documents: $e');
      _isLoading = false;
      _error = e.toString();
      // notifyListeners();
    }
  }

  // Save document metadata to local storage
  Future<void> _saveLocalDocumentMetadata() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/document_metadata.json');

      // Convert to JSON
      final metadataList = _documents.map((doc) => doc.toJson()).toList();
      final metadataString = json.encode(metadataList);

      // Save to file
      await metadataFile.writeAsString(metadataString);
    } catch (e) {
      print('Error saving local document metadata: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<DocumentModel>> fetchDocuments() async {
    // Just reload local documents
    await _loadLocalDocuments();
    return _documents;
  }

  List<DocumentModel> getDocumentsByCase(String caseId) {
    return _documents.where((doc) => doc.caseId == caseId).toList();
  }

  List<DocumentModel> getDocumentsByClient(String clientId) {
    return _documents.where((doc) => doc.clientId == clientId).toList();
  }

  List<DocumentModel> getDocumentsByType(String type) {
    return _documents
        .where((doc) => doc.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  DocumentModel? getDocumentById(String id) {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Upload document to local storage
  Future<DocumentModel> uploadDocument(
    File file, {
    String? caseId,
    String? clientId,
    String? category,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate a unique ID for the document
      final documentId = Uuid().v4();

      // Get file information
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(file.path).replaceAll('.', '');

      // Calculate file size
      final bytes = file.lengthSync();
      String fileSize;
      if (bytes < 1024 * 1024) {
        fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        fileSize = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }

      // Determine category if not provided
      final String documentCategory =
          category ?? (caseId != null ? 'case' : 'general');

      // Create a document model
      final document = DocumentModel(
        id: documentId,
        name: fileName,
        type: fileExtension,
        size: fileSize,
        url: file.path, // Local file path
        uploadDate: DateTime.now(),
        caseId: caseId,
        clientId: clientId,
        userId: user.uid,
        isLocal: true,
        category: documentCategory,
      );

      // Save the document to Firestore
      await _firestore
          .collection('documents')
          .doc(documentId)
          .set(document.toJson());

      // Add the document to the local list
      _documents.add(document);
      notifyListeners();

      return document;
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Failed to upload document: ${e.toString()}');
    }
  }

  Future<void> deleteDocument(String documentId, String url) async {
    try {
      // Get the document to check if it's associated with a case
      final document = getDocumentById(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Delete local file
      if (url.startsWith('file://')) {
        final filePath = url.replaceFirst('file://', '');
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove from documents list
      _documents.removeWhere((doc) => doc.id == documentId);

      // Save updated metadata
      await _saveLocalDocumentMetadata();

      // If this document was associated with a case, update the case's documentIds array in Firestore
      if (document.caseId != null) {
        try {
          await _firestore.collection('cases').doc(document.caseId).update({
            'documentIds': FieldValue.arrayRemove([documentId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error updating case document IDs: $e');
          // Continue anyway since the document is deleted locally
        }
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Search documents by query string
  List<DocumentModel> searchDocuments(String query) {
    if (query.isEmpty) {
      return _documents;
    }

    final lowercaseQuery = query.toLowerCase();
    return _documents.where((doc) {
      return doc.name.toLowerCase().contains(lowercaseQuery) ||
          doc.type.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Get document statistics
  Map<String, dynamic> getDocumentStatistics() {
    final totalDocuments = _documents.length;

    final documentTypes = <String, int>{};
    for (var doc in _documents) {
      documentTypes[doc.type] = (documentTypes[doc.type] ?? 0) + 1;
    }

    final caseDocuments = _documents.where((doc) => doc.caseId != null).length;
    final clientDocuments =
        _documents.where((doc) => doc.clientId != null).length;

    return {
      'totalDocuments': totalDocuments,
      'documentTypes': documentTypes,
      'caseDocuments': caseDocuments,
      'clientDocuments': clientDocuments,
    };
  }

  // Open a document
  Future<String> openDocument(DocumentModel document) async {
    try {
      if (document.url.startsWith('file://')) {
        // Local document, just return the file path
        return document.url.replaceFirst('file://', '');
      } else {
        // Remote document, download it first
        return await downloadDocument(document);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Download a document to a temporary file and return the file path
  Future<String> downloadDocument(DocumentModel document) async {
    try {
      // If it's a local document, just return the path
      if (document.url.startsWith('file://')) {
        return document.url.replaceFirst('file://', '');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${document.name}');

      // Download the file
      final response = await http.get(Uri.parse(document.url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Failed to download document: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
