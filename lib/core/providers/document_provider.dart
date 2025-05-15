import 'package:flutter/material.dart';
import '../models/document.dart';
import '../utils/dummy_data.dart';

class DocumentProvider extends ChangeNotifier {
  List<Document> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Get document by ID
  Document? getDocumentById(String id) {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get documents for a specific case
  List<Document> getDocumentsForCase(String caseId) {
    return _documents.where((d) => d.caseId == caseId).toList();
  }
  
  // Get documents for a specific client
  List<Document> getDocumentsForClient(String clientId) {
    return _documents.where((d) => d.clientId == clientId).toList();
  }
  
  // Get documents shared with client
  List<Document> getSharedDocuments(String clientId) {
    return _documents.where((d) => 
      d.clientId == clientId && d.isSharedWithClient
    ).toList();
  }
  
  // Get documents by type
  List<Document> getDocumentsByType(String fileType) {
    return _documents.where((d) => 
      d.fileType.toLowerCase() == fileType.toLowerCase()
    ).toList();
  }
  
  // Load documents
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Load dummy data
      _documents = DummyData.documents;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load documents: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Add a new document
  Future<bool> addDocument(Document newDocument) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add to list
      _documents.add(newDocument);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add document: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Update a document
  Future<bool> updateDocument(Document updatedDocument) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Find and update
      final index = _documents.indexWhere((d) => d.id == updatedDocument.id);
      if (index != -1) {
        _documents[index] = updatedDocument;
      } else {
        throw Exception('Document not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update document: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Toggle document sharing with client
  Future<bool> toggleDocumentSharing(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find and update
      final index = _documents.indexWhere((d) => d.id == id);
      if (index != -1) {
        final document = _documents[index];
        _documents[index] = document.copyWith(isSharedWithClient: !document.isSharedWithClient);
      } else {
        throw Exception('Document not found');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update document sharing: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Delete a document
  Future<bool> deleteDocument(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Remove from list
      _documents.removeWhere((d) => d.id == id);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete document: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  
  // Search documents
  List<Document> searchDocuments(String query) {
    if (query.isEmpty) {
      return _documents;
    }
    
    final lowercaseQuery = query.toLowerCase();
    return _documents.where((d) => 
      d.title.toLowerCase().contains(lowercaseQuery) ||
      d.fileName.toLowerCase().contains(lowercaseQuery) ||
      d.description?.toLowerCase().contains(lowercaseQuery) == true ||
      d.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
}
