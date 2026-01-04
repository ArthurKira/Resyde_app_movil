import '../../domain/entities/user.dart';

class LoginResponse {
  final String? token;
  final User? user;
  final String? message;
  final bool success;
  final String? status;

  LoginResponse({
    this.token,
    this.user,
    this.message,
    required this.success,
    this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final userData = json['user'] as Map<String, dynamic>?;
    final status = json['status'] as String?;
    
    return LoginResponse(
      token: token,
      user: userData != null
          ? User(
              id: userData['id']?.toString(),
              email: userData['email'] as String?,
              name: userData['name'] as String?,
              token: token,
              perfil: userData['perfil'] as String?,
            )
          : null,
      message: json['message'] as String?,
      status: status,
      // Verificar si el status es "success" O si hay token y user
      success: (status == 'success' || token != null && userData != null),
    );
  }

  User toUser() {
    return User(
      id: user?.id,
      email: user?.email,
      name: user?.name,
      token: token ?? user?.token,
      perfil: user?.perfil,
    );
  }
}

