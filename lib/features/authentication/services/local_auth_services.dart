import 'dart:developer';

import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/authentication/models/user_model.dart';

class LocalAuthServices {
  static Future<void> setUserLoggedIn({required bool value}) async {
    await HiveService.loginBox.put('login', value);

    log('set login $value');
  }

  static Future<bool> getUserLoggedIn() async {
    final resp = HiveService.loginBox.get('login') ?? false;
    log('get login $resp');
    return resp;
  }

  static Future<void> saveUserDetails(UserModel user) async {
    await HiveService.userBox.put(HiveService.userBoxName, user);
  }

  static UserModel? getUserDetails() {
    final user = HiveService.userBox.get(HiveService.userBoxName);
    log('user $user');
    return user;
  }

  Future<void> deleteUser(String id) async {
    await HiveService.userBox.delete(id);
  }
}
