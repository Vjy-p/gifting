import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gifting/features/products/models/product_model.dart';

import '../models/enquiry_model.dart';

class EnquiryServices {
  EnquiryServices({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<String> submit(EnquiryModel enquiry) async {
    try {
      final reference = (enquiry.referenceCode != null &&
              enquiry.referenceCode!.isNotEmpty)
          ? enquiry.referenceCode!
          : 'TG-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';

      final data = enquiry.toJson();
      data['reference_code'] = reference;
      data['created_at'] = (enquiry.createdAt ?? DateTime.now()).toIso8601String();

      await _firestore.collection('enquiries').doc(reference).set(data);

      return reference;
    } on FirebaseException catch (error, stackTrace) {
      log('Firebase submit enquiry error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected submit enquiry error: $error, $stackTrace');
      rethrow;
    }
  }

  /// Updates an existing enquiry document in Firestore
  Future<void> update(EnquiryModel enquiry) async {
    try {
      final reference = enquiry.referenceCode;
      if (reference == null || reference.isEmpty) {
        throw Exception('Enquiry reference code is missing for update.');
      }

      final data = enquiry.toJson();
      data['reference_code'] = reference;
      data['updated_at'] = DateTime.now().toIso8601String();
      if (enquiry.createdAt != null) {
        data['created_at'] = enquiry.createdAt!.toIso8601String();
      }

      await _firestore
          .collection('enquiries')
          .doc(reference)
          .set(data, SetOptions(merge: true));

      log('Enquiry updated on Firestore: $reference');
    } on FirebaseException catch (error, stackTrace) {
      log('Firebase update enquiry error: ${error.message}, $stackTrace');
      log('Code: ${error.code}');
      rethrow;
    } catch (error, stackTrace) {
      log('Unexpected update enquiry error: $error, $stackTrace');
      rethrow;
    }
  }

  /// Finds an existing enquiry in Firestore matching the product and user email
  Future<EnquiryModel?> findEnquiryByProductInFirestore({
    required ProductModel product,
    String? userEmail,
  }) async {
    try {
      Query query = _firestore.collection('enquiries');
      if (userEmail != null && userEmail.isNotEmpty) {
        query = query.where('email', isEqualTo: userEmail);
      }

      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;
        final rawProducts = data['products'] as List? ?? [];
        for (final item in rawProducts) {
          if (item is Map) {
            final pId = item['id']?.toString() ?? '';
            final pName = item['name']?.toString() ?? '';
            final idMatches = product.id.isNotEmpty && pId == product.id;
            final nameMatches = product.name.trim().isNotEmpty &&
                pName.trim().toLowerCase() == product.name.trim().toLowerCase();
            if (idMatches || nameMatches) {
              data['id'] = doc.id;
              data['reference_code'] = data['reference_code'] ?? doc.id;
              return EnquiryModel.fromJson(data);
            }
          }
        }
      }
      return null;
    } catch (e) {
      log('Error checking existing enquiry in Firestore: $e');
      return null;
    }
  }
}
