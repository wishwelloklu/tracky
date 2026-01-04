enum UserRole { user, admin }

enum MinerStatus { active, suspended, pending }

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final String? location;
  final DateTime createdAt;
  final MinerStatus? minerStatus; // Only for miners

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
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
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phone,
      'role': role.name,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'minerStatus': minerStatus?.name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phoneNumber'],
      role: UserRole.values.firstWhere(
        (e) => e.name.toUpperCase() == json['role'].toString().toUpperCase(),
        orElse: () => UserRole.user,
      ),
      location: json['location'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(), // Fallback if missing
      minerStatus: json['minerStatus'] != null
          ? MinerStatus.values.firstWhere(
              (e) => e.name == json['minerStatus'],
              orElse: () => MinerStatus.pending,
            )
          : null,
    );
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    UserRole? role,
    String? location,
    DateTime? createdAt,
    MinerStatus? minerStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      minerStatus: minerStatus ?? this.minerStatus,
    );
  }

  bool get isMiner => role == UserRole.user;
  bool get isOfficial => role == UserRole.admin;

  String get roleDisplayName {
    switch (role) {
      case UserRole.user:
        return 'Small-Scale Miner';
      case UserRole.admin:
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
