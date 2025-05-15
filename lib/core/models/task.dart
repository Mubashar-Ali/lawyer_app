import 'package:intl/intl.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final String? caseId;
  final String? caseTitle;
  final String? clientId;
  final String? clientName;
  final DateTime? completedAt;
  final String? assignedTo;
  final Map<String, dynamic>? metadata;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    this.caseId,
    this.caseTitle,
    this.clientId,
    this.clientName,
    this.completedAt,
    this.assignedTo,
    this.metadata,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    String? caseId,
    String? caseTitle,
    String? clientId,
    String? clientName,
    DateTime? completedAt,
    String? assignedTo,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      completedAt: completedAt ?? this.completedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'caseId': caseId,
      'caseTitle': caseTitle,
      'clientId': clientId,
      'clientName': clientName,
      'completedAt': completedAt?.toIso8601String(),
      'assignedTo': assignedTo,
      'metadata': metadata,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'],
      isCompleted: json['isCompleted'],
      caseId: json['caseId'],
      caseTitle: json['caseTitle'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      assignedTo: json['assignedTo'],
      metadata: json['metadata'],
    );
  }

  String get formattedDueDate => DateFormat('MMM d, yyyy').format(dueDate);
  String get formattedCompletedAt => completedAt != null ? DateFormat('MMM d, yyyy').format(completedAt!) : '';
  
  bool get isHighPriority => priority.toLowerCase() == 'high';
  bool get isMediumPriority => priority.toLowerCase() == 'medium';
  bool get isLowPriority => priority.toLowerCase() == 'low';
  
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());
  bool get isDueToday {
    final now = DateTime.now();
    return !isCompleted && 
      dueDate.year == now.year && 
      dueDate.month == now.month && 
      dueDate.day == now.day;
  }
  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return !isCompleted && 
      dueDate.year == tomorrow.year && 
      dueDate.month == tomorrow.month && 
      dueDate.day == tomorrow.day;
  }
}
