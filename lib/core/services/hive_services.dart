import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String enquiryBoxName = 'enquiries';
  static const String settingsBoxName = 'settings';
  static const String userBoxName = 'user';
  static const String loginBoxName = 'login';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(EnquiryModelAdapter());
    Hive.registerAdapter(UserModelAdapter());

    await Hive.openBox<EnquiryModel>(enquiryBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<UserModel>(userBoxName);
    await Hive.openBox<bool>(loginBoxName);
  }

  static Box<EnquiryModel> get enquiryBox {
    return Hive.box<EnquiryModel>(enquiryBoxName);
  }

  static Box get settingsBox {
    return Hive.box(settingsBoxName);
  }

  static Box<UserModel?> get userBox {
    return Hive.box<UserModel>(userBoxName);
  }

  static Box<bool?> get loginBox {
    return Hive.box<bool>(loginBoxName);
  }
}
