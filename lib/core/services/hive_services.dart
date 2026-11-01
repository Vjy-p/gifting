import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String enquiryBoxName = 'enquiries';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(EnquiryModelAdapter());

    await Hive.openBox<EnquiryModel>(enquiryBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<EnquiryModel> get enquiryBox {
    return Hive.box<EnquiryModel>(enquiryBoxName);
  }

  static Box get settingsBox {
    return Hive.box(settingsBoxName);
  }
}
