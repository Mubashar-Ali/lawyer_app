class Client {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String imageUrl;
  final List<String> caseIds;
  final DateTime clientSince;
  final String notes;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.imageUrl,
    required this.caseIds,
    required this.clientSince,
    required this.notes,
  });
}

List<Client> dummyClients = [
  Client(
    id: '1',
    name: 'Robert Smith',
    email: 'robert.smith@example.com',
    phone: '(555) 123-4567',
    address: '123 Main St, San Francisco, CA 94105',
    imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    caseIds: ['1'],
    clientSince: DateTime(2022, 10, 15),
    notes: 'Prefers communication via email. Available after 5 PM on weekdays.',
  ),
  Client(
    id: '2',
    name: 'Sarah Williams',
    email: 'sarah.williams@example.com',
    phone: '(555) 234-5678',
    address: '456 Oak Ave, Los Angeles, CA 90001',
    imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    caseIds: ['2'],
    clientSince: DateTime(2021, 5, 20),
    notes: 'Executor of Williams Estate. Has two children who are beneficiaries.',
  ),
  Client(
    id: '3',
    name: 'Michael Davis',
    email: 'michael.davis@example.com',
    phone: '(555) 345-6789',
    address: '789 Pine St, San Diego, CA 92101',
    imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    caseIds: ['3'],
    clientSince: DateTime(2023, 1, 10),
    notes: 'Going through difficult divorce. Has 2 children, ages 8 and 10.',
  ),
  Client(
    id: '4',
    name: 'Jennifer Thompson',
    email: 'jennifer.thompson@example.com',
    phone: '(555) 456-7890',
    address: '101 Tech Blvd, San Jose, CA 95110',
    imageUrl: 'https://randomuser.me/api/portraits/women/22.jpg',
    caseIds: ['4'],
    clientSince: DateTime(2022, 12, 5),
    notes: 'Tech entrepreneur starting new venture. Needs ongoing legal support.',
  ),
  Client(
    id: '5',
    name: 'James Brown',
    email: 'james.brown@example.com',
    phone: '(555) 567-8901',
    address: '202 Cedar Rd, Sacramento, CA 95814',
    imageUrl: 'https://randomuser.me/api/portraits/men/67.jpg',
    caseIds: ['5'],
    clientSince: DateTime(2023, 2, 15),
    notes: 'Retired teacher. Property has been in family for generations.',
  ),
];
