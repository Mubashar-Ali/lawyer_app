import 'package:intl/intl.dart';

class Case {
  final String id;
  final String title;
  final String caseNumber;
  final String clientId;
  final String clientName;
  final String court;
  final String status;
  final DateTime filingDate;
  final DateTime nextHearing;
  final String description;
  final String caseType;
  final List<String> tags;
  final List<String>? documentIds;
  final List<String>? relatedCaseIds;
  final Map<String, dynamic>? metadata;
  final String? attorneyName;
  final String? judge;
  final String? opposingParty;

  Case({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.clientId,
    required this.clientName,
    required this.court,
    required this.status,
    required this.filingDate,
    required this.nextHearing,
    required this.description,
    required this.caseType,
    required this.tags,
    this.documentIds,
    this.relatedCaseIds,
    this.metadata,
    this.attorneyName,
    this.judge,
    this.opposingParty,
  });

  Case copyWith({
    String? id,
    String? title,
    String? caseNumber,
    String? clientId,
    String? clientName,
    String? court,
    String? status,
    DateTime? filingDate,
    DateTime? nextHearing,
    String? description,
    String? caseType,
    List<String>? tags,
    List<String>? documentIds,
    List<String>? relatedCaseIds,
    Map<String, dynamic>? metadata,
    String? attorneyName,
    String? judge,
    String? opposingParty,
  }) {
    return Case(
      id: id ?? this.id,
      title: title ?? this.title,
      caseNumber: caseNumber ?? this.caseNumber,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      court: court ?? this.court,
      status: status ?? this.status,
      filingDate: filingDate ?? this.filingDate,
      nextHearing: nextHearing ?? this.nextHearing,
      description: description ?? this.description,
      caseType: caseType ?? this.caseType,
      tags: tags ?? this.tags,
      documentIds: documentIds ?? this.documentIds,
      relatedCaseIds: relatedCaseIds ?? this.relatedCaseIds,
      metadata: metadata ?? this.metadata,
      attorneyName: attorneyName ?? this.attorneyName,
      judge: judge ?? this.judge,
      opposingParty: opposingParty ?? this.opposingParty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'caseNumber': caseNumber,
      'clientId': clientId,
      'clientName': clientName,
      'court': court,
      'status': status,
      'filingDate': filingDate.toIso8601String(),
      'nextHearing': nextHearing.toIso8601String(),
      'description': description,
      'caseType': caseType,
      'tags': tags,
      'documentIds': documentIds,
      'relatedCaseIds': relatedCaseIds,
      'metadata': metadata,
      'attorneyName': attorneyName,
      'judge': judge,
      'opposingParty': opposingParty,
    };
  }

  factory Case.fromJson(Map<String, dynamic> json) {
    return Case(
      id: json['id'],
      title: json['title'],
      caseNumber: json['caseNumber'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      court: json['court'],
      status: json['status'],
      filingDate: DateTime.parse(json['filingDate']),
      nextHearing: DateTime.parse(json['nextHearing']),
      description: json['description'],
      caseType: json['caseType'],
      tags: List<String>.from(json['tags']),
      documentIds:
          json['documentIds'] != null
              ? List<String>.from(json['documentIds'])
              : null,
      relatedCaseIds:
          json['relatedCaseIds'] != null
              ? List<String>.from(json['relatedCaseIds'])
              : null,
      metadata: json['metadata'],
      attorneyName: json['attorneyName'],
      judge: json['judge'],
      opposingParty: json['opposingParty'],
    );
  }

  String get formattedFilingDate =>
      DateFormat('MMM d, yyyy').format(filingDate);
  String get formattedNextHearing =>
      DateFormat('MMM d, yyyy').format(nextHearing);

  bool get isActive => status.toLowerCase() == 'active';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => status.toLowerCase() == 'completed';
}
