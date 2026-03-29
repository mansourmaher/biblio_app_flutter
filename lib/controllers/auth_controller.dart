import 'package:biblio_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import '../models/membre.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Membre? _membre;
  bool _loading = false;

  Membre? get membre => _membre;
  bool get loading => _loading;
  bool get isLoggedIn => _authService.currentUser != null;

  Future<void> loadMembre() async {
    final user = _authService.currentUser;
    if (user != null) {
      _membre = await _authService.getMembre(user.uid);
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _loading = true;
    notifyListeners();
    final error = await _authService.login(email: email, password: password);
    if (error == null) await loadMembre();
    _loading = false;
    notifyListeners();
    return error;
  }

  Future<String?> register({
    required String nom,
    required String email,
    required String password,
    String telephone = '',
  }) async {
    _loading = true;
    notifyListeners();
    final error = await _authService.register(
      nom: nom,
      email: email,
      password: password,
      telephone: telephone,
    );
    if (error == null) await loadMembre();
    _loading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    _membre = null;
    notifyListeners();
  }
}
