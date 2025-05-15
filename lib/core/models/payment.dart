import 'package:intl/intl.dart';

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String status;
  final String clientId;
  final String clientName;
  final String? caseId;
  final String? caseTitle;
  final String description;
  final String paymentMethod;
  final String? invoiceId;
  final String? transactionId;
  final Map<String, dynamic>? metadata;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.clientId,
    required this.clientName,
    this.caseId,
    this.caseTitle,
    required this.description,
    required this.paymentMethod,
    this.invoiceId,
    this.transactionId,
    this.metadata,
  });

  Payment copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? status,
    String? clientId,
    String? clientName,
    String? caseId,
    String? caseTitle,
    String? description,
    String? paymentMethod,
    String? invoiceId,
    String? transactionId,
    Map<String, dynamic>? metadata,
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      caseId: caseId ?? this.caseId,
      caseTitle: caseTitle ?? this.caseTitle,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      invoiceId: invoiceId ?? this.invoiceId,
      transactionId: transactionId ?? this.transactionId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
      'clientId': clientId,
      'clientName': clientName,
      'caseId': caseId,
      'caseTitle': caseTitle,
      'description': description,
      'paymentMethod': paymentMethod,
      'invoiceId': invoiceId,
      'transactionId': transactionId,
      'metadata': metadata,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      caseId: json['caseId'],
      caseTitle: json['caseTitle'],
      description: json['description'],
      paymentMethod: json['paymentMethod'],
      invoiceId: json['invoiceId'],
      transactionId: json['transactionId'],
      metadata: json['metadata'],
    );
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(date);
  String get formattedAmount => NumberFormat.currency(symbol: '\$').format(amount);
  
  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRefunded => status.toLowerCase() == 'refunded';
  bool get isFailed => status.toLowerCase() == 'failed';
}
