import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting/features/catalogue/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonServices {
  Future<void> openWhatsApp({
    String code = "+91",
    String phone = "9701779683",
    String? referenceCode,
    required List<ProductModel> products,
    String? qunatity,
  }) async {
    String mobileNumber = (code + phone).replaceAll(RegExp(r'[^0-9]'), '');

    String message = "Hello, I am interested in this product\n";
    if (referenceCode != null) message += "\nReference : $referenceCode";

    for (ProductModel p in products) {
      message += "\nName : ${p.name}\nPrice : ${p.priceRange}";
    }

    message += "\n\nPlease share more details";

    final encodedMessage = Uri.encodeComponent(message);

    log(
      "WhatsApp number: $mobileNumber'https://wa.me/$mobileNumber?text=$encodedMessage'",
    );

    final url = Uri.parse("https://wa.me/$mobileNumber?text=$encodedMessage");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Unable to open WhatsApp',
        'Please try again or use the enquiry form.',
      );

      throw 'Could not open WhatsApp';
    }
  }
}
