import 'dart:developer';

import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  AuthServices({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<bool?> signUp({
    required String name,
    required String email,
    required String mobile,
    required String? companyName,
    required String password,
  }) async {
    try {
      Map<String, dynamic> data = {
        'name': name.trim(),
        'mobile': mobile.trim(),
        'company': companyName,
      };
      log('data $data $email');
      final AuthResponse resp = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: data,
      );
      log('signup resp: ${resp.user}');
      if (resp.user != null) {
        await LocalAuthServices.setUserLoggedIn(value: true);
        await getUserDetails();
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (error, stackTrace) {
      log('Error Supabase signup: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (e, stackTree) {
      log('Error during signup: $e, $stackTree');
      rethrow;
    }
  }

  Future<bool?> login({required String email, required String password}) async {
    try {
      final AuthResponse resp = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      log('login resp: ${resp.user}');
      if (resp.user != null) {
        await LocalAuthServices.setUserLoggedIn(value: true);
        await getUserDetails();
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (error, stackTrace) {
      log('Error Supabase login: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (e, stackTree) {
      log('Error during login: $e, $stackTree');
      rethrow;
    }
  }

  Future<UserModel?> getUserDetails() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) return null;

      final userResp = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      log('get user $userResp');
      if (userResp != null) {
        UserModel? u = UserModel.fromJson(userResp);
        await LocalAuthServices.saveUserDetails(u);
        return u;
      } else {
        return null;
      }
    } catch (e, stackTree) {
      log('Error get user details: $e, $stackTree');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      await LocalAuthServices.setUserLoggedIn(value: false);
    } catch (e, stackTree) {
      log('Error during sign out: $e, $stackTree');
      rethrow;
    }
  }
}
