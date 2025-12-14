import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getSavedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences preferences;

  AuthLocalDataSourceImpl(this.preferences);

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';

  @override
  Future<void> saveUser(User user) async {
    if (user.token != null) {
      await preferences.setString(_keyToken, user.token!);
    }
    if (user.id != null) {
      await preferences.setString(_keyUserId, user.id!);
    }
    if (user.email != null) {
      await preferences.setString(_keyUserEmail, user.email!);
    }
    if (user.name != null) {
      await preferences.setString(_keyUserName, user.name!);
    }
  }

  @override
  Future<User?> getSavedUser() async {
    final token = preferences.getString(_keyToken);
    if (token == null) return null;

    return User(
      id: preferences.getString(_keyUserId),
      email: preferences.getString(_keyUserEmail),
      name: preferences.getString(_keyUserName),
      token: token,
    );
  }

  @override
  Future<void> clearUser() async {
    await preferences.remove(_keyToken);
    await preferences.remove(_keyUserId);
    await preferences.remove(_keyUserEmail);
    await preferences.remove(_keyUserName);
  }
}

