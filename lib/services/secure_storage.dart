import 'dart:convert';

import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage
  static final _storage = new FlutterSecureStorage();

  // Check user
  Future<bool> hasUser() async {
    String? userData = await _storage.read(key: "user");
    if (userData == null) {
      return false;
    }
    return true;
  }

  // Write user
  Future<void> storeUser({required SecureUser user}) async {
    String userData = jsonEncode(user.toJson());
    return await _storage.write(key: "user", value: userData);
  }

  // Write user
  Future<void> updateUserPassword({String? password}) async {
    String? userData = await _storage.read(key: "user");
    if (userData == null) {
      return;
    }
    SecureUser user = SecureUser.fromJson(jsonDecode(userData));
    user.password = password;

    String newUserData = jsonEncode(user.toJson());
    // debugPrint("")
    return await _storage.write(key: "user", value: newUserData);
  }

  // Read user
  Future<SecureUser> getUser() async {
    String? userData = await _storage.read(key: "user");
    if (userData == null) {
      return SecureUser();
    }
    return SecureUser.fromJson(jsonDecode(userData));
  }

  // Delete user
  Future<void> clear() async {
    return await _storage.deleteAll();
  }
}
