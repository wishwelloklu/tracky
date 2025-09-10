import 'package:intl/intl.dart';

enum PackageStatus { pending, verified, rejected }

class PackageModel {
  final String id;
  final String mineralType;
  final double quantity;
  final DateTime mineDate;
  final String location;
  final String grade;
  final String minerId;
  final String minerName;
  final DateTime createdAt;
  final PackageStatus status;
  final String? notes;

  PackageModel({
    required this.id,
    required this.mineralType,
    required this.quantity,
    required this.mineDate,
    required this.location,
    required this.grade,
    required this.minerId,
    required this.minerName,
    required this.createdAt,
    this.status = PackageStatus.pending,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mineralType': mineralType,
      'quantity': quantity,
      'mineDate': mineDate.toIso8601String(),
      'location': location,
      'grade': grade,
      'minerId': minerId,
      'minerName': minerName,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      mineralType: json['mineralType'],
      quantity: (json['quantity'] as num).toDouble(),
      mineDate: DateTime.parse(json['mineDate']),
      location: json['location'],
      grade: json['grade'],
      minerId: json['minerId'],
      minerName: json['minerName'],
      createdAt: DateTime.parse(json['createdAt']),
      status: PackageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PackageStatus.pending,
      ),
      notes: json['notes'],
    );
  }

  PackageModel copyWith({
    String? id,
    String? mineralType,
    double? quantity,
    DateTime? mineDate,
    String? location,
    String? grade,
    String? minerId,
    String? minerName,
    DateTime? createdAt,
    PackageStatus? status,
    String? notes,
  }) {
    return PackageModel(
      id: id ?? this.id,
      mineralType: mineralType ?? this.mineralType,
      quantity: quantity ?? this.quantity,
      mineDate: mineDate ?? this.mineDate,
      location: location ?? this.location,
      grade: grade ?? this.grade,
      minerId: minerId ?? this.minerId,
      minerName: minerName ?? this.minerName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  String get formattedMineDate => DateFormat('MMM dd, yyyy').format(mineDate);
  String get formattedCreatedAt => DateFormat('MMM dd, yyyy HH:mm').format(createdAt);
  String get statusDisplayName {
    switch (status) {
      case PackageStatus.pending:
        return 'Pending';
      case PackageStatus.verified:
        return 'Verified';
      case PackageStatus.rejected:
        return 'Rejected';
    }
  }
  
  String get quantityDisplayText => '${quantity.toStringAsFixed(2)}g';
}