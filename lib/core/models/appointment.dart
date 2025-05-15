import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String clientName;
  final String clientId;
  final String location;
  final String description;
  final String type;
  final bool isRemote;
  final String? caseId;
  final String? caseTitle;
  final Map<String, dynamic>? metadata;

  Appointment({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.clientName,
    required this.clientId,
    required this.location,
    required this.description,
    required this.type,
    required this.isRemote,
    this.caseId,
    this.caseTitle,
    this.metadata,
  });

  Appointment copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? clientName,
    String? clientId,
    String? location,
    String? description,
    String? type,
    bool? isRemote,
    String? caseId,
    String? caseTitle,
    Map<String, dynamic>? metadata,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      location: location ?? this.location,
      description: description ?? this.description,
      type: type ?? this.type,
      isRemote: isRemote ?? this.isRemote,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'clientName': clientName,
      'clientId': clientId,
      'location': location,
      'description': description,
      'type': type,
      'isRemote': isRemote,
      'caseId': caseId,
      'caseTitle': caseTitle,
      'metadata': metadata,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      clientName: json['clientName'],
      clientId: json['clientId'],
      location: json['location'],
      description: json['description'],
      type: json['type'],
      isRemote: json['isRemote'],
      caseId: json['caseId'],
      caseTitle: json['caseTitle'],
      metadata: json['metadata'],
    );
  }

  String get formattedStartTime => DateFormat('MMM d, yyyy h:mm a').format(startTime);
  String get formattedEndTime => DateFormat('h:mm a').format(endTime);
  String get formattedDate => DateFormat('MMM d, yyyy').format(startTime);
  String get formattedTimeRange => '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}';
  
  Duration get duration => endTime.difference(startTime);
  String get durationText {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes - (hours * 60);
      return '$hours hr${hours > 1 ? 's' : ''}${remainingMinutes > 0 ? ' $remainingMinutes min' : ''}';
    }
  }
  
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isOngoing {
    final now = DateTime.now();
    return startTime.isBefore(now) && endTime.isAfter(now);
  }
}
