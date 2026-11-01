import 'dart:developer';

import 'package:gifting/core/widgets/custom_toast.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonServices {
  Future<void> openWhatsApp({
    String code = '+91',
    String phone = '9701779683',
    String? referenceCode,
    required List<ProductModel> products,
    String? qunatity,
  }) async {
    try {
      final mobileNumber = (code + phone).replaceAll(RegExp(r'[^0-9]'), '');

      var message = 'Hello, I am interested in this product\n';
      if (referenceCode != null && referenceCode.isNotEmpty) {
        message += '\nReference : $referenceCode';
      }

      for (final p in products) {
        message += '\nName : ${p.name}\nPrice : ${p.priceRange}';
      }

      if (qunatity != null && qunatity.isNotEmpty) {
        message += '\nQuantity : $qunatity';
      }

      message += '\n\nPlease share more details';

      final encodedMessage = Uri.encodeComponent(message);

      // Direct WhatsApp scheme (opens app directly if installed)
      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$mobileNumber&text=$encodedMessage',
      );
      // Web fallback link (wa.me)
      final webUri = Uri.parse(
        'https://wa.me/$mobileNumber?text=$encodedMessage',
      );

      bool launched = false;

      // 1. Try launching native WhatsApp app
      if (await canLaunchUrl(nativeUri)) {
        launched = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );
      }

      // 2. If native app didn't launch, try web link
      if (!launched) {
        if (await canLaunchUrl(webUri)) {
          launched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          // In case canLaunchUrl returned false due to package visibility restrictions
          try {
            launched = await launchUrl(
              webUri,
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {
            launched = false;
          }
        }
      }

      if (!launched) {
        customToast(
          title: 'Unable to open WhatsApp',
          text: 'Please install WhatsApp or use the enquiry form.',
        );
      }
    } catch (e, stackTree) {
      customToast(
        title: 'Unable to open WhatsApp',
        text: 'Please try again or use the enquiry form.',
      );
      log('Error whatsapp $e ,$stackTree');
    }
  }
}
