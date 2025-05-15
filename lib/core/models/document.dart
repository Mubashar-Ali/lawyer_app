import 'package:intl/intl.dart';

class Document {
  final String id;
  final String title;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final int fileSize;
  final DateTime uploadDate;
  final String? caseId;
  final String? caseTitle;
  final String? clientId;
  final String? clientName;
  final String? description;
  final List<String> tags;
  final bool isSharedWithClient;
  final Map<String, dynamic>? metadata;

  Document({
    required this.id,
    required this.title,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadDate,
    this.caseId,
    this.caseTitle,
    this.clientId,
    this.clientName,
    this.description,
    required this.tags,
    required this.isSharedWithClient,
    this.metadata,
  });

  Document copyWith({
    String? id,
    String? title,
    String? fileName,
    String? fileType,
    String? fileUrl,
    int? fileSize,
    DateTime? uploadDate,
    String? caseId,
    String? caseTitle,
    String? clientId,
    String? clientName,
    String? description,
    List<String>? tags,
    bool? isSharedWithClient,
    Map<String, dynamic>? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isSharedWithClient: isSharedWithClient ?? this.isSharedWithClient,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'caseId': caseId,
      'caseTitle': caseTitle,
      'clientId': clientId,
      'clientName': clientName,
      'description': description,
      'tags': tags,
      'isSharedWithClient': isSharedWithClient,
      'metadata': metadata,
    };
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      fileUrl: json['fileUrl'],
      fileSize: json['fileSize'],
      uploadDate: DateTime.parse(json['uploadDate']),
      caseId: json['caseId'],
      caseTitle: json['caseTitle'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      isSharedWithClient: json['isSharedWithClient'],
      metadata: json['metadata'],
    );
  }

  String get formattedUploadDate => DateFormat('MMM d, yyyy').format(uploadDate);
  
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif'].contains(fileType.toLowerCase());
  bool get isDocument => ['doc', 'docx', 'txt', 'rtf'].contains(fileType.toLowerCase());
  bool get isSpreadsheet => ['xls', 'xlsx', 'csv'].contains(fileType.toLowerCase());
  bool get isPresentation => ['ppt', 'pptx'].contains(fileType.toLowerCase());
}
