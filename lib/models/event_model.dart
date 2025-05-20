import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String? caseId;
  final String? clientId;
  final String? clientName;
  final String? caseTitle;
  final String eventType; // 'hearing', 'meeting', 'deadline', 'other'

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    this.caseId,
    this.clientId,
    this.clientName,
    this.caseTitle,
    required this.eventType,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      caseId: data['caseId'],
      clientId: data['clientId'],
      clientName: data['clientName'],
      caseTitle: data['caseTitle'],
      eventType: data['eventType'] ?? 'other',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'caseId': caseId,
      'clientId': clientId,
      'clientName': clientName,
      'caseTitle': caseTitle,
      'eventType': eventType,
    };
  }

  IconData getEventIcon() {
    switch (eventType) {
      case 'hearing':
        return Icons.gavel;
      case 'meeting':
        return Icons.people;
      case 'deadline':
        return Icons.timer;
      default:
        return Icons.event;
    }
  }

  Color getEventColor() {
    switch (eventType) {
      case 'hearing':
        return Color(0xFF1A237E); // Deep Indigo
      case 'meeting':
        return Color(0xFF0D47A1); // Deep Blue
      case 'deadline':
        return Color(0xFFB71C1C); // Deep Red
      default:
        return Color(0xFF4A148C); // Deep Purple
    }
  }
}
