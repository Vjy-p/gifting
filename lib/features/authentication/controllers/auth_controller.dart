import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/authentication/services/auth_services.dart';

import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final authServices = AuthServices();

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w.!#$%&’*+/=?^_`{|}~-]+@[\w-]+(?:\.[\w-]+)+$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String mobile,
    required String company,
    required String password,
  }) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final response = await authServices.signUp(
        name: name.trim(),
        email: email.trim(),
        mobile: mobile.trim(),
        companyName: company.trim(),
        password: password.trim(),
      );
      isLoading.value = false;
      if (response == true) {
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (error, stackTree) {
      isLoading.value = false;
      log('Error Signup $error, $stackTree ');
      customToast(
        title: 'Signup failed',
        text: error.message ?? 'An error occurred during signup.',
      );
    } catch (e, stackTree) {
      log('Error signup $e, $stackTree');
      customToast(
        title: 'Unable to signup',
        text: 'Check your connection and try again.',
      );
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login({required String email, required String password}) async {
    if (isLoading.value) return;

    if (email.trim().isEmpty || password.trim().isEmpty) {
      customToast(title: 'Required', text: 'Enter your email and password.');
      return;
    }

    try {
      isLoading.value = true;

      final response = await authServices.login(
        email: email.trim(),
        password: password.trim(),
      );
      if (response == true) {
        Get.offAllNamed(AppRoutes.home);
      }
    } on FirebaseAuthException catch (error, stackTree) {
      log('Error login $error, $stackTree ');
      customToast(
        title: 'Login failed',
        text: error.message ?? 'An error occurred during sign in.',
      );
    } catch (_) {
      customToast(
        title: 'Unable to sign in',
        text: 'Check your connection and admin account configuration.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authServices.logout();
    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
    Get.offAllNamed(AppRoutes.landingPage);
  }
}
