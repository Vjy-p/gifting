import 'dart:developer';

import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:hive/hive.dart';

class LocalAuthServices {
  static Future<void> setUserLoggedIn({required bool value}) async {
    try {
      if (Hive.isBoxOpen(HiveService.loginBoxName)) {
        await HiveService.loginBox.put('login', value);
        log('set login $value');
      }
    } catch (e) {
      log('Error setting login status: $e');
    }
  }

  static Future<bool> getUserLoggedIn() async {
    try {
      if (!Hive.isBoxOpen(HiveService.loginBoxName)) {
        return false;
      }
      final resp = HiveService.loginBox.get('login') ?? false;
      log('get login $resp');
      return resp;
    } catch (e) {
      log('Error getting login status: $e');
      return false;
    }
  }

  static Future<void> saveUserDetails(UserModel user) async {
    try {
      if (Hive.isBoxOpen(HiveService.userBoxName)) {
        await HiveService.userBox.put(HiveService.userBoxName, user);
      }
    } catch (e) {
      log('Error saving user details: $e');
    }
  }

  static UserModel? getUserDetails() {
    try {
      if (!Hive.isBoxOpen(HiveService.userBoxName)) {
        return null;
      }
      final user = HiveService.userBox.get(HiveService.userBoxName);
      log('user $user');
      return user;
    } catch (e) {
      log('Error getting user details: $e');
      return null;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      if (Hive.isBoxOpen(HiveService.userBoxName)) {
        await HiveService.userBox.delete(id);
      }
    } catch (e) {
      log('Error deleting user: $e');
    }
  }
}
