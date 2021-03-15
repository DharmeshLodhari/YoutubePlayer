import 'dart:convert';

import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage
  static final _storage = new FlutterSecureStorage();

  // Check user
  Future<bool> hasUser() async {
    String userData = await _storage.read(key: "user");
    if (userData == null) {
      return false;
    }
    return true;
  }

  // Write user
  Future<void> storeUser({SecureUser user}) async {
    String userData = jsonEncode(user.toJson());
    return await _storage.write(key: "user", value: userData);
  }

  // Read user
  Future<SecureUser> getUser() async {
    String userData = await _storage.read(key: "user");
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
