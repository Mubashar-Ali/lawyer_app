import 'package:flutter/material.dart';
import 'base_model.dart';
import '../utils/date_formatter.dart';

class CaseModel extends BaseModel {
  final String id;
  final String title;
  final String caseNumber;
  final String clientName;
  final String clientId;
  final String caseType;
  final String court;
  final String status;
  final DateTime filingDate;
  final DateTime? nextHearing;
  final String description;
  final List<String>? documentIds; // Store document IDs instead of embedding documents
  final DateTime createdAt;
  final DateTime updatedAt;

  CaseModel({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.clientName,
    required this.clientId,
    required this.caseType,
    required this.court,
    required this.status,
    required this.filingDate,
    this.nextHearing,
    required this.description,
    this.documentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Creates a CaseModel from a Firestore document
  factory CaseModel.fromJson(Map<String, dynamic> json) {
    // Parse dates from strings or timestamps
    DateTime filingDate;
    try {
      if (json['filingDate'] is String) {
        filingDate = DateFormatter.parseDisplayDate(json['filingDate']);
      } else if (json['filingDate'] != null) {
        // Handle Firestore Timestamp
        filingDate = (json['filingDate'] as dynamic).toDate();
      } else {
        filingDate = DateTime.now();
      }
    } catch (e) {
      filingDate = DateTime.now();
    }

    DateTime? nextHearing;
    if (json['nextHearing'] != null) {
      try {
        if (json['nextHearing'] is String) {
          nextHearing = DateFormatter.parseDisplayDate(json['nextHearing']);
        } else {
          // Handle Firestore Timestamp
          nextHearing = (json['nextHearing'] as dynamic).toDate();
        }
      } catch (e) {
        nextHearing = null;
      }
    }

    DateTime createdAt;
    try {
      createdAt = (json['createdAt'] as dynamic).toDate();
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = (json['updatedAt'] as dynamic).toDate();
    } catch (e) {
      updatedAt = DateTime.now();
    }

    // Extract document IDs
    List<String>? documentIds;
    if (json['documentIds'] != null) {
      documentIds = List<String>.from(json['documentIds']);
    }

    return CaseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      caseNumber: json['caseNumber'] ?? '',
      clientName: json['clientName'] ?? '',
      clientId: json['clientId'] ?? '',
      caseType: json['caseType'] ?? '',
      court: json['court'] ?? '',
      status: json['status'] ?? 'Active',
      filingDate: filingDate,
      nextHearing: nextHearing,
      description: json['description'] ?? '',
      documentIds: documentIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'caseNumber': caseNumber,
      'clientName': clientName,
      'clientId': clientId,
      'caseType': caseType,
      'court': court,
      'status': status,
      'filingDate': filingDate, // Store as DateTime for Firestore
      'description': description,
      'updatedAt': DateTime.now(),
    };

    if (nextHearing != null) {
      data['nextHearing'] = nextHearing; // Store as DateTime for Firestore
    }

    if (documentIds != null && documentIds!.isNotEmpty) {
      data['documentIds'] = documentIds;
    }

    return data;
  }

  /// Creates a copy of this CaseModel with the given fields replaced
  CaseModel copyWith({
    String? id,
    String? title,
    String? caseNumber,
    String? clientName,
    String? clientId,
    String? caseType,
    String? court,
    String? status,
    DateTime? filingDate,
    DateTime? nextHearing,
    String? description,
    List<String>? documentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      caseNumber: caseNumber ?? this.caseNumber,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      caseType: caseType ?? this.caseType,
      court: court ?? this.court,
      status: status ?? this.status,
      filingDate: filingDate ?? this.filingDate,
      nextHearing: nextHearing ?? this.nextHearing,
      description: description ?? this.description,
      documentIds: documentIds ?? this.documentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, String> validate() {
    final errors = <String, String>{};
    
    if (title.isEmpty) {
      errors['title'] = 'Title is required';
    }
    
    if (caseNumber.isEmpty) {
      errors['caseNumber'] = 'Case number is required';
    }
    
    if (clientName.isEmpty) {
      errors['clientName'] = 'Client name is required';
    }
    
    if (court.isEmpty) {
      errors['court'] = 'Court is required';
    }
    
    if (description.isEmpty) {
      errors['description'] = 'Description is required';
    }
    
    return errors;
  }

  /// Returns the filing date as a formatted string
  String get filingDateFormatted => DateFormatter.toDisplayDate(filingDate);
  
  /// Returns the next hearing date as a formatted string, or 'Not scheduled' if null
  String get nextHearingFormatted => 
      nextHearing != null ? DateFormatter.toDisplayDate(nextHearing!) : 'Not scheduled';
      
  /// Returns true if the case has documents
  bool get hasDocuments => documentIds != null && documentIds!.isNotEmpty;
  
  /// Returns the number of documents
  int get documentCount => documentIds?.length ?? 0;
  
  /// Returns the status color
  Color getStatusColor() {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Closed':
        return Colors.grey;
      case 'On Hold':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
