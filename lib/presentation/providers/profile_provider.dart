import 'package:flutter/material.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final GetUserProfile getUserProfile;

  ProfileProvider({required this.getUserProfile});

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getUserProfile();

    if (result is Success<UserProfile>) {
      _userProfile = result.data;
      _errorMessage = null;
    } else {
      _errorMessage = (result as Error).failure.message;
      _userProfile = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearProfile() {
    _userProfile = null;
    _errorMessage = null;
    notifyListeners();
  }
}

