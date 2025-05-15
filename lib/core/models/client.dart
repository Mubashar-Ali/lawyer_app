import 'package:intl/intl.dart';

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
  final Map<String, dynamic>? metadata;

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
    this.metadata,
  });

  Client copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? imageUrl,
    List<String>? caseIds,
    DateTime? clientSince,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      caseIds: caseIds ?? this.caseIds,
      clientSince: clientSince ?? this.clientSince,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'caseIds': caseIds,
      'clientSince': clientSince.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      imageUrl: json['imageUrl'],
      caseIds: List<String>.from(json['caseIds']),
      clientSince: DateTime.parse(json['clientSince']),
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  String get formattedClientSince => DateFormat('MMM d, yyyy').format(clientSince);
  int get caseCount => caseIds.length;
}
