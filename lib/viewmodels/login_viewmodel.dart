import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<UserModel?> login(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.signIn(email, password);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> register(String email, String password) async {
    _setLoading(true);
    try {
      return await _authService.register(email, password);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
