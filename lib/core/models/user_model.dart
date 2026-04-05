class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? companyId;
  final String? employeeRole;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.companyId,
    this.employeeRole,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      companyId: json['company_id']?.toString(),
      employeeRole: json['employee_role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'company_id': companyId,
        'employee_role': employeeRole,
      };
}
