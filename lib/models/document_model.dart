import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'base_model.dart';

class DocumentModel extends BaseModel {
  final String id;
  final String name;
  final String type;
  final String size;
  final String url;
  final DateTime uploadDate;
  final String? caseId;
  final String? clientId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocal;
  final String category; // client | case | general

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.url,
    required this.uploadDate,
    this.caseId,
    this.clientId,
    required this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isLocal = false,
    this.category = 'general',
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    DateTime uploadDate;
    try {
      if (json['uploadDate'] is Timestamp) {
        uploadDate = (json['uploadDate'] as Timestamp).toDate();
      } else if (json['uploadDate'] is DateTime) {
        uploadDate = json['uploadDate'];
      } else if (json['uploadDate'] is String) {
        uploadDate = DateTime.parse(json['uploadDate']);
      } else {
        uploadDate = DateTime.now();
      }
    } catch (e) {
      uploadDate = DateTime.now();
    }

    DateTime createdAt;
    try {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is DateTime) {
        createdAt = json['createdAt'];
      } else if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      if (json['updatedAt'] is Timestamp) {
        updatedAt = (json['updatedAt'] as Timestamp).toDate();
      } else if (json['updatedAt'] is DateTime) {
        updatedAt = json['updatedAt'];
      } else if (json['updatedAt'] is String) {
        updatedAt = DateTime.parse(json['updatedAt']);
      } else {
        updatedAt = DateTime.now();
      }
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return DocumentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      url: json['url'] ?? '',
      uploadDate: uploadDate,
      caseId: json['caseId'],
      clientId: json['clientId'],
      userId: json['userId'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      isLocal: json['isLocal'] ?? false,
      category: json['category'] ?? 'general',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'type': type,
      'size': size,
      'url': url,
      'uploadDate': uploadDate.toIso8601String(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isLocal': isLocal,
      'category': category,
    };

    if (caseId != null) {
      data['caseId'] = caseId;
    }

    if (clientId != null) {
      data['clientId'] = clientId;
    }

    return data;
  }

  DocumentModel copyWith({
    String? id,
    String? name,
    String? type,
    String? size,
    String? url,
    DateTime? uploadDate,
    String? caseId,
    String? clientId,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLocal,
    String? category,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      url: url ?? this.url,
      uploadDate: uploadDate ?? this.uploadDate,
      caseId: caseId ?? this.caseId,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLocal: isLocal ?? this.isLocal,
      category: category ?? this.category,
    );
  }

  @override
  Map<String, String> validate() {
    final errors = <String, String>{};

    if (name.isEmpty) {
      errors['name'] = 'Name is required';
    }

    if (url.isEmpty) {
      errors['url'] = 'URL is required';
    }

    return errors;
  }

  /// Returns the upload date as a formatted string
  String get formattedDate {
    final formatter = DateFormat('MMM d, yyyy');
    return formatter.format(uploadDate);
  }

  /// Returns the upload date as a formatted time
  String get formattedTime {
    final formatter = DateFormat('h:mm a');
    return formatter.format(uploadDate);
  }

  /// Returns the upload date as a formatted date and time
  String get formattedDateTime {
    final formatter = DateFormat('MMM d, yyyy h:mm a');
    return formatter.format(uploadDate);
  }

  /// Returns the upload date as a relative time (e.g., "2 days ago")
  String get uploadDateRelative {
    final now = DateTime.now();
    final difference = now.difference(uploadDate);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  /// Returns true if the document is a PDF
  bool get isPdf => type.toLowerCase() == 'pdf';

  /// Returns true if the document is an image
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif'].contains(type.toLowerCase());

  /// Returns true if the document is a document (Word, etc.)
  bool get isDocument => ['doc', 'docx', 'txt'].contains(type.toLowerCase());

  /// Returns true if the document is a spreadsheet
  bool get isSpreadsheet => ['xls', 'xlsx', 'csv'].contains(type.toLowerCase());

  /// Returns true if the document is a presentation
  bool get isPresentation => ['ppt', 'pptx'].contains(type.toLowerCase());

  /// Returns the file extension
  String get extension => type.toLowerCase();

  /// Returns an icon data based on the document type
  IconData getIconData() {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Returns a color based on the document type
  Color getTypeColor() {
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      case 'zip':
      case 'rar':
        return Colors.brown;
      case 'txt':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  /// Returns a color based on the category
  Color getCategoryColor() {
    switch (category) {
      case 'case':
        return Colors.blue;
      case 'client':
        return Colors.green;
      case 'general':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  /// Returns an icon based on the category
  IconData getCategoryIcon() {
    switch (category) {
      case 'case':
        return Icons.gavel;
      case 'client':
        return Icons.people;
      case 'general':
        return Icons.folder;
      default:
        return Icons.folder;
    }
  }
}
