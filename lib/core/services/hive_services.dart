import 'package:gifting/features/authentication/models/user_model.dart';
import 'package:gifting/features/enquiries/models/enquiry_model.dart';
import 'package:gifting/features/products/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String enquiryBoxName = 'enquiries';
  static const String settingsBoxName = 'settings';
  static const String userBoxName = 'user';
  static const String loginBoxName = 'login';
  static const String cartBoxName = 'cart';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(EnquiryModelAdapter());
    Hive.registerAdapter(UserModelAdapter());

    await _openBox(settingsBoxName);
    await _openBox<UserModel>(userBoxName);
    await _openBox<bool>(loginBoxName);
    await _openBox<EnquiryModel>(enquiryBoxName);
    await _openBox<ProductModel>(cartBoxName);
  }

  static Future<Box<T>> _openBox<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<T>(boxName);
    }
  }

  static Box<EnquiryModel> get enquiryBox {
    return Hive.box<EnquiryModel>(enquiryBoxName);
  }

  static Box<ProductModel> get cartBox {
    return Hive.box<ProductModel>(cartBoxName);
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
