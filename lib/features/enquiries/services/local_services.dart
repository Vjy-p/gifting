import 'package:gifting/core/services/hive_services.dart';
import 'package:gifting/features/products/models/product_model.dart';

import '../models/enquiry_model.dart';

class LocalEnquiryServices {
  /// Checks whether a product has already been enquiried
  bool isProductEnquiried(ProductModel product) {
    return findEnquiryByProduct(product) != null;
  }

  /// Finds an existing enquiry containing the given product (matching by ID or name)
  EnquiryModel? findEnquiryByProduct(ProductModel product) {
    final all = getAllEnquiries();
    for (final enquiry in all) {
      for (final p in enquiry.products) {
        final idMatches = product.id.isNotEmpty && p.id == product.id;
        final nameMatches = product.name.trim().isNotEmpty &&
            p.name.trim().toLowerCase() == product.name.trim().toLowerCase();
        if (idMatches || nameMatches) {
          return enquiry;
        }
      }
    }
    return null;
  }

  /// Finds an existing enquiry by product ID
  EnquiryModel? findEnquiryByProductId(String productId) {
    if (productId.isEmpty) return null;
    final all = getAllEnquiries();
    for (final enquiry in all) {
      if (enquiry.products.any((p) => p.id == productId)) {
        return enquiry;
      }
    }
    return null;
  }

  Future<void> saveEnquiry(EnquiryModel enquiry) async {
    final reference = enquiry.referenceCode;

    if (reference == null || reference.isEmpty) {
      throw Exception('Enquiry reference code is missing.');
    }

    if (HiveService.enquiryBox.keys.contains(reference)) {
      await HiveService.enquiryBox.put(reference, enquiry);
    } else {
      await HiveService.enquiryBox.put(reference, enquiry);
    }
  }

  List<EnquiryModel> getAllEnquiries() {
    final enquiries = HiveService.enquiryBox.values.toList();

    enquiries.sort((a, b) {
      return (b.createdAt ?? DateTime(2000)).compareTo(
        a.createdAt ?? DateTime(2000),
      );
    });

    return enquiries;
  }

  Future<void> deleteEnquiry(String referenceCode) async {
    await HiveService.enquiryBox.delete(referenceCode);
  }

  Future<void> clearHistory() async {
    await HiveService.enquiryBox.clear();
  }
}
