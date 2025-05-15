class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool isCompleted;
  final String? caseId;
  final String? clientId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    this.caseId,
    this.clientId,
  });
}

List<Task> dummyTasks = [
  Task(
    id: '1',
    title: 'Prepare Motion for Smith Case',
    description: 'Draft and file motion for summary judgment',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    priority: 'High',
    isCompleted: false,
    caseId: '1',
    clientId: '1',
  ),
  Task(
    id: '2',
    title: 'Review Williams Estate Documents',
    description: 'Review all estate documents and prepare summary',
    dueDate: DateTime.now().add(const Duration(days: 3)),
    priority: 'Medium',
    isCompleted: false,
    caseId: '2',
    clientId: '2',
  ),
  Task(
    id: '3',
    title: 'Prepare for Davis Hearing',
    description: 'Review case notes and prepare arguments',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    priority: 'High',
    isCompleted: false,
    caseId: '3',
    clientId: '3',
  ),
  Task(
    id: '4',
    title: 'Draft LLC Operating Agreement',
    description: 'Prepare operating agreement for Thompson LLC',
    dueDate: DateTime.now().add(const Duration(days: 4)),
    priority: 'Medium',
    isCompleted: true,
    caseId: '4',
    clientId: '4',
  ),
  Task(
    id: '5',
    title: 'Research Property Laws',
    description: 'Research relevant property laws for Brown case',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    priority: 'Medium',
    isCompleted: false,
    caseId: '5',
    clientId: '5',
  ),
  Task(
    id: '6',
    title: 'Update Billing Records',
    description: 'Update billing records for all active clients',
    dueDate: DateTime.now().add(const Duration(days: 1)),
    priority: 'Low',
    isCompleted: false,
  ),
  Task(
    id: '7',
    title: 'Schedule Client Meetings',
    description: 'Schedule follow-up meetings with clients',
    dueDate: DateTime.now().add(const Duration(days: 2)),
    priority: 'Low',
    isCompleted: true,
  ),
];
