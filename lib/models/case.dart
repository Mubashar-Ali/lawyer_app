class Case {
  final String id;
  final String title;
  final String clientName;
  final String caseNumber;
  final String court;
  final String status;
  final DateTime filingDate;
  final DateTime nextHearing;
  final String description;
  final String caseType;

  Case({
    required this.id,
    required this.title,
    required this.clientName,
    required this.caseNumber,
    required this.court,
    required this.status,
    required this.filingDate,
    required this.nextHearing,
    required this.description,
    required this.caseType,
  });
}

List<Case> dummyCases = [
  Case(
    id: '1',
    title: 'Smith vs. Johnson',
    clientName: 'Robert Smith',
    caseNumber: 'CV-2023-1234',
    court: 'Superior Court of California',
    status: 'Active',
    filingDate: DateTime(2023, 3, 15),
    nextHearing: DateTime(2023, 6, 10),
    description: 'Personal injury case involving a car accident on Highway 101.',
    caseType: 'Personal Injury',
  ),
  Case(
    id: '2',
    title: 'Williams Estate',
    clientName: 'Sarah Williams',
    caseNumber: 'PR-2023-5678',
    court: 'Probate Court',
    status: 'Pending',
    filingDate: DateTime(2023, 2, 20),
    nextHearing: DateTime(2023, 5, 25),
    description: 'Estate administration for the late Mr. Williams.',
    caseType: 'Probate',
  ),
  Case(
    id: '3',
    title: 'Davis Divorce',
    clientName: 'Michael Davis',
    caseNumber: 'FL-2023-9012',
    court: 'Family Court',
    status: 'Active',
    filingDate: DateTime(2023, 4, 5),
    nextHearing: DateTime(2023, 7, 15),
    description: 'Divorce proceedings including child custody and asset division.',
    caseType: 'Family Law',
  ),
  Case(
    id: '4',
    title: 'Thompson LLC Formation',
    clientName: 'Jennifer Thompson',
    caseNumber: 'BL-2023-3456',
    court: 'N/A',
    status: 'Completed',
    filingDate: DateTime(2023, 1, 10),
    nextHearing: DateTime(2023, 1, 10),
    description: 'Formation of an LLC for a new tech startup.',
    caseType: 'Business Law',
  ),
  Case(
    id: '5',
    title: 'Brown Property Dispute',
    clientName: 'James Brown',
    caseNumber: 'CV-2023-7890',
    court: 'Civil Court',
    status: 'Active',
    filingDate: DateTime(2023, 3, 30),
    nextHearing: DateTime(2023, 6, 20),
    description: 'Boundary dispute with neighboring property owner.',
    caseType: 'Real Estate',
  ),
];
