import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all events
  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    // notifyListeners();

    try {
      final snapshot = await _firestore.collection('events')
          .orderBy('dateTime', descending: false)
          .get();
      
      _events = snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new event
  Future<void> addEvent(EventModel event) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('events').add(event.toFirestore());
      await fetchEvents();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing event
  Future<void> updateEvent(EventModel event) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('events').doc(event.id).update(event.toFirestore());
      await fetchEvents();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('events').doc(eventId).delete();
      await fetchEvents();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get events for a specific day
  List<EventModel> getEventsForDay(DateTime day) {
    return _events.where((event) => 
      event.dateTime.year == day.year && 
      event.dateTime.month == day.month && 
      event.dateTime.day == day.day
    ).toList();
  }

  // Get upcoming events
  List<EventModel> getUpcomingEvents({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));
    
    return _events.where((event) => 
      event.dateTime.isAfter(now) && 
      event.dateTime.isBefore(endDate)
    ).toList();
  }

  // Get events for a specific case
  List<EventModel> getEventsForCase(String caseId) {
    return _events.where((event) => event.caseId == caseId).toList();
  }

  // Get events for a specific client
  List<EventModel> getEventsForClient(String clientId) {
    return _events.where((event) => event.clientId == clientId).toList();
  }
}
