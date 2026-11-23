import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/authentication/services/auth_services.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';
import 'package:gifting/features/enquiries/services/local_services.dart';
import 'package:gifting/features/order/controllers/order_controller.dart';
import 'package:hive/hive.dart';

class ProfileController extends GetxController {
  final AuthServices _authServices = AuthServices();
  final LocalEnquiryServices _localEnquiryServices = LocalEnquiryServices();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxInt enquiryCount = 0.obs;
  final RxInt orderCount = 0.obs;
  final RxInt cartCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Loads current user details from local cache and syncs with Firestore
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      // 1. Load cached user data from Hive immediately
      final cachedUser = LocalAuthServices.getUserDetails();
      if (cachedUser != null) {
        user.value = cachedUser;
      }

      // 2. Fetch fresh user details from backend Firestore
      final freshUser = await _authServices.getUserDetails();
      if (freshUser != null) {
        user.value = freshUser;
      }

      // 3. Load stats
      await refreshStats();
    } catch (e, stackTrace) {
      log('[ProfileController] Error loading profile: $e $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculates real-time counts for Enquiries, Orders, and Cart items
  Future<void> refreshStats() async {
    try {
      // Local enquiries count
      final enquiries = _localEnquiryServices.getAllEnquiries();
      enquiryCount.value = enquiries.length;

      // Cart count
      if (Hive.isBoxOpen(HiveService.cartBoxName)) {
        cartCount.value = HiveService.cartBox.length;
      }

      // Orders count
      if (Get.isRegistered<OrderController>()) {
        orderCount.value = Get.find<OrderController>().orders.length;
      } else {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final snap = await FirebaseFirestore.instance
              .collection('orders')
              .where('user_id', isEqualTo: currentUser.uid)
              .get();
          orderCount.value = snap.docs.length;
        }
      }
    } catch (e) {
      log('[ProfileController] Error refreshing stats: $e');
    }
  }

  /// Validates and updates user profile data on backend & local cache
  Future<bool> updateProfile({
    required String name,
    required String mobile,
    required String company,
  }) async {
    if (isSaving.value) return false;

    if (name.trim().isEmpty) {
      customToast(title: 'Required', text: 'Full name cannot be empty.');
      return false;
    }

    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      customToast(
        title: 'Invalid phone',
        text: 'Enter a valid 10-digit Indian mobile number.',
      );
      return false;
    }

    try {
      isSaving.value = true;
      final updatedUser = await _authServices.updateProfile(
        name: name.trim(),
        mobile: digits,
        company: company.trim(),
      );

      user.value = updatedUser;
      customToast(
        title: 'Profile Updated',
        text: 'Your profile changes have been saved.',
      );
      return true;
    } catch (e, stackTrace) {
      log('[ProfileController] Error updating profile: $e $stackTrace');
      customToast(
        title: 'Update failed',
        text: 'Unable to save profile changes. Please try again.',
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }
}
