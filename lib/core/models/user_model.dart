class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? companyId;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.companyId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      companyId: json['company_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'company_id': companyId,
      };
}
