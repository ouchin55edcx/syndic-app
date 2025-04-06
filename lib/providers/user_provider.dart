import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  String? _userType;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  String? get userType => _userType;
  bool get isAuthenticated => _isAuthenticated;

  bool get isSyndic => _userType == 'syndic';
  bool get isProprietaire => _userType == 'proprietaire';

  void setUser(User user, String token, String userType) {
    debugPrint('Setting user with token: $token');
    debugPrint('User type: $userType');

    _user = user;
    _token = token;
    _userType = userType;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _token = null;
    _userType = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
