enum UserRole { miner, official }

enum MinerStatus { active, suspended, pending }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? location;
  final DateTime createdAt;
  final MinerStatus? minerStatus; // Only for miners

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.location,
    required this.createdAt,
    this.minerStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'minerStatus': minerStatus?.name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.miner,
      ),
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
      minerStatus: json['minerStatus'] != null
          ? MinerStatus.values.firstWhere(
              (e) => e.name == json['minerStatus'],
              orElse: () => MinerStatus.pending,
            )
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? location,
    DateTime? createdAt,
    MinerStatus? minerStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      minerStatus: minerStatus ?? this.minerStatus,
    );
  }

  bool get isMiner => role == UserRole.miner;
  bool get isOfficial => role == UserRole.official;
  
  String get roleDisplayName {
    switch (role) {
      case UserRole.miner:
        return 'Small-Scale Miner';
      case UserRole.official:
        return 'GOLDBOD Official';
    }
  }
  
  String get statusDisplayName {
    if (minerStatus == null) return 'N/A';
    switch (minerStatus!) {
      case MinerStatus.active:
        return 'Active';
      case MinerStatus.suspended:
        return 'Suspended';
      case MinerStatus.pending:
        return 'Pending Approval';
    }
  }
}