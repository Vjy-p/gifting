import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gifting/core/services/notification_service.dart';
import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/authentication/services/local_auth_services.dart';

class AuthServices {
  AuthServices({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<bool?> signUp({
    required String name,
    required String email,
    required String mobile,
    required String? companyName,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      log('signup user: ${user?.uid}');
      if (user != null) {
        await user.updateDisplayName(name.trim());

        final profile = UserModel(
          id: user.uid,
          name: name.trim(),
          email: email.trim(),
          mobile: mobile.trim(),
          company: companyName?.trim() ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection('profiles')
            .doc(user.uid)
            .set(profile.toJson());

        await NotificationService.saveTokenForUser(user.uid);

        await LocalAuthServices.setUserLoggedIn(value: true);
        await LocalAuthServices.saveUserDetails(profile);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      log('Error Firebase signup: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (e, stackTree) {
      log('Error during signup: $e, $stackTree');
      rethrow;
    }
  }

  Future<bool?> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      log('login user: ${user?.uid}');
      if (user != null) {
        await Future.wait([
          LocalAuthServices.setUserLoggedIn(value: true),
          getUserDetails(),
          NotificationService.saveTokenForUser(user.uid),
        ]);
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (error, stackTrace) {
      log('Error Firebase login: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (e, stackTree) {
      log('Error during login: $e, $stackTree');
      rethrow;
    }
  }

  Future<UserModel?> getUserDetails() async {
    try {
      final user = _auth.currentUser;

      if (user == null) return null;

      final doc = await _firestore.collection('profiles').doc(user.uid).get();
      log('get user doc exists: ${doc.exists}');
      if (doc.exists && doc.data() != null) {
        final data = Map<String, dynamic>.from(doc.data()!);
        data['id'] = user.uid;
        UserModel profile = UserModel.fromJson(data);
        await LocalAuthServices.saveUserDetails(profile);
        return profile;
      } else {
        final profile = UserModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          mobile: user.phoneNumber ?? '',
          company: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await LocalAuthServices.saveUserDetails(profile);
        return profile;
      }
    } catch (e, stackTree) {
      log('Error get user details: $e, $stackTree');
      rethrow;
    }
  }

  Future<UserModel> updateProfile({
    required String name,
    required String mobile,
    required String company,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User is not signed in');
      }

      final now = DateTime.now();

      // Update Firebase Auth display name
      if (user.displayName != name.trim()) {
        await user.updateDisplayName(name.trim());
      }

      // Update Firestore profiles collection
      final updateData = <String, dynamic>{
        'name': name.trim(),
        'mobile': mobile.trim(),
        'company': company.trim(),
        'updated_at': now.toIso8601String(),
      };

      await _firestore
          .collection('profiles')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      // Get existing details or create updated user model
      final existing = await LocalAuthServices.getUserDetails();
      final updatedUser = UserModel(
        id: user.uid,
        name: name.trim(),
        email: user.email ?? existing?.email ?? '',
        mobile: mobile.trim(),
        company: company.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      // Save to local Hive cache
      await LocalAuthServices.saveUserDetails(updatedUser);
      log('User profile updated successfully: ${updatedUser.name}');
      return updatedUser;
    } catch (e, stackTrace) {
      log('Error updating profile: $e, $stackTrace');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await NotificationService.removeTokenOnLogout(user.uid);
      }
      await _auth.signOut();
      await LocalAuthServices.setUserLoggedIn(value: false);
    } catch (e, stackTree) {
      log('Error during sign out: $e, $stackTree');
      rethrow;
    }
  }
}
