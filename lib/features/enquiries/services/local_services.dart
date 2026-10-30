import 'package:gifting/core/services/hive_services.dart';

import '../models/enquiry_model.dart';

class LocalEnquiryServices {
  Future<void> saveEnquiry(EnquiryModel enquiry) async {
    final reference = enquiry.referenceCode;

    if (reference == null || reference.isEmpty) {
      throw Exception('Enquiry reference code is missing.');
    }

    await HiveService.enquiryBox.put(reference, enquiry);
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
