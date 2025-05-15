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
  });
}

List<Appointment> dummyAppointments = [
  Appointment(
    id: '1',
    title: 'Initial Consultation',
    startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    endTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
    clientName: 'Robert Smith',
    clientId: '1',
    location: 'Office',
    description: 'Discuss case details and legal options',
    type: 'Consultation',
    isRemote: false,
  ),
  Appointment(
    id: '2',
    title: 'Document Review',
    startTime: DateTime.now().add(const Duration(days: 2, hours: 4)),
    endTime: DateTime.now().add(const Duration(days: 2, hours: 5, minutes: 30)),
    clientName: 'Sarah Williams',
    clientId: '2',
    location: 'Virtual Meeting',
    description: 'Review estate documents and will',
    type: 'Document Review',
    isRemote: true,
  ),
  Appointment(
    id: '3',
    title: 'Court Hearing',
    startTime: DateTime.now().add(const Duration(days: 3, hours: 9)),
    endTime: DateTime.now().add(const Duration(days: 3, hours: 11)),
    clientName: 'Michael Davis',
    clientId: '3',
    location: 'Family Court, Room 305',
    description: 'Initial hearing for divorce proceedings',
    type: 'Court Appearance',
    isRemote: false,
  ),
  Appointment(
    id: '4',
    title: 'Contract Signing',
    startTime: DateTime.now().add(const Duration(days: 4, hours: 3)),
    endTime: DateTime.now().add(const Duration(days: 4, hours: 4)),
    clientName: 'Jennifer Thompson',
    clientId: '4',
    location: 'Office',
    description: 'Sign LLC formation documents',
    type: 'Document Signing',
    isRemote: false,
  ),
  Appointment(
    id: '5',
    title: 'Mediation Session',
    startTime: DateTime.now().add(const Duration(days: 5, hours: 1)),
    endTime: DateTime.now().add(const Duration(days: 5, hours: 3)),
    clientName: 'James Brown',
    clientId: '5',
    location: 'Mediation Center',
    description: 'Mediation with neighboring property owner',
    type: 'Mediation',
    isRemote: false,
  ),
];
