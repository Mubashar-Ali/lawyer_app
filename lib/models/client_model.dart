import 'base_model.dart';
import '../utils/date_formatter.dart';

class ClientModel extends BaseModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime clientSince;
  final List<String> caseIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.clientSince,
    required this.caseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    // Parse dates from strings or timestamps
    DateTime clientSince;
    try {
      if (json['clientSince'] is String) {
        clientSince = DateFormatter.parseDisplayDate(json['clientSince']);
      } else {
        // Handle Firestore Timestamp
        clientSince = (json['clientSince'] as dynamic).toDate();
      }
    } catch (e) {
      clientSince = DateTime.now();
    }

    DateTime createdAt;
    try {
      createdAt = (json['createdAt'] as dynamic).toDate();
    } catch (e) {
      createdAt = DateTime.now();
    }

    DateTime updatedAt;
    try {
      updatedAt = (json['updatedAt'] as dynamic).toDate();
    } catch (e) {
      updatedAt = DateTime.now();
    }

    return ClientModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      clientSince: clientSince,
      caseIds: List<String>.from(json['caseIds'] ?? []),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'clientSince': DateFormatter.toDisplayDate(clientSince),
      'caseIds': caseIds,
      'updatedAt': DateTime.now(),
    };
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? clientSince,
    List<String>? caseIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      clientSince: clientSince ?? this.clientSince,
      caseIds: caseIds ?? this.caseIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, String> validate() {
    final errors = <String, String>{};
    
    if (name.isEmpty) {
      errors['name'] = 'Name is required';
    }
    
    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        errors['email'] = 'Please enter a valid email address';
      }
    }
    
    return errors;
  }

  /// Returns the client since date as a formatted string
  String get clientSinceFormatted => DateFormatter.toDisplayDate(clientSince);
  
  /// Returns the number of cases associated with this client
  int get caseCount => caseIds.length;
  
  /// Returns true if the client has cases
  bool get hasCases => caseIds.isNotEmpty;
  
  /// Returns the client's initials (first letter of first and last name)
  String get initials {
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name[0].toUpperCase();
    } else {
      return '?';
    }
  }
}
