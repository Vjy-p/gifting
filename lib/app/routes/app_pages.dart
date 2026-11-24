import 'dart:developer';

import 'package:get/get.dart';
import 'package:gifting/features/authentication/controllers/auth_controller.dart';
import 'package:gifting/features/authentication/views/login_screen.dart';
import 'package:gifting/features/authentication/views/signup_screen.dart';
import 'package:gifting/features/cart/controllers/cart_controller.dart';
import 'package:gifting/features/cart/views/cart_screen.dart';
import 'package:gifting/features/catalogue/views/catalogue_screen.dart';
import 'package:gifting/features/enquiries/controllers/enquiry_controller.dart';
import 'package:gifting/features/enquiries/views/create_enquiry_screen.dart';
import 'package:gifting/features/enquiries/views/enquiry_screen.dart';
import 'package:gifting/features/home/views/home_screen.dart';
import 'package:gifting/features/notifications/controllers/notification_controller.dart';
import 'package:gifting/features/notifications/views/notifications_screen.dart';
import 'package:gifting/features/order/controllers/order_controller.dart';
import 'package:gifting/features/order/views/order_details_screen.dart';
import 'package:gifting/features/order/views/order_screen.dart';
import 'package:gifting/features/payment/controllers/payment_controller.dart';
import 'package:gifting/features/payment/views/screens/payments_history_screen.dart';
import 'package:gifting/features/products/controllers/product_details_controller.dart';
import 'package:gifting/features/products/views/product_details_screen.dart';
import 'package:gifting/features/profile/controllers/profile_controller.dart';
import 'package:gifting/features/profile/views/edit_profile_screen.dart';
import 'package:gifting/features/profile/views/profile_dashboard_screen.dart';
import 'package:gifting/features/splash/views/splash_screen.dart';
import 'package:gifting/features/support/controller/support_controller.dart';
import 'package:gifting/features/support/views/support_screen.dart';

import '../../features/catalogue/controllers/catalogue_controller.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.landingPage,

      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<CatalogueController>(() => CatalogueController());
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: AppRoutes.enquiry,
      page: () => const EnquiryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<CatalogueController>(() => CatalogueController());
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: AppRoutes.order,
      page: () => const OrderScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OrderController>()) {
          Get.lazyPut<OrderController>(() => OrderController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.orderDetails,
      page: () => const OrderDetailsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<OrderController>()) {
          Get.lazyPut<OrderController>(() => OrderController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.productDetails,
      page: () => ProductDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductDetailsController>(
          () => ProductDetailsController(product: Get.arguments),
        );
      }),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CartController>()) {
          Get.lazyPut<CartController>(() => CartController(), fenix: true);
        }
        if (!Get.isRegistered<PaymentController>()) {
          Get.lazyPut<PaymentController>(
            () => PaymentController(),
            fenix: true,
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.createEnquiry,
      page: () => const CreateEnquiryScreen(),
      arguments: Get.arguments,
      binding: BindingsBuilder(() {
        final args = Get.arguments == null
            ? null
            : Get.arguments as Map<String, dynamic>;
        log('args $args');
        Get.lazyPut<EnquiryController>(() => EnquiryController());
        log('args $args');
        Get.lazyPut<EnquiryController>(() => EnquiryController());
      }),
    ),
    GetPage(
      name: AppRoutes.catalogue,
      page: () => const CatalogueScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<CatalogueController>()) {
          Get.lazyPut<CatalogueController>(() => CatalogueController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SupportController>()) {
          Get.lazyPut<SupportController>(() => SupportController());
        }
      }),
    ),
    // GetPage(
    //   name: AppRoutes.payment,
    //   page: () => const PaymentsScreen(),
    //   binding: BindingsBuilder(() {
    //     if (!Get.isRegistered<PaymentController>()) {
    //       Get.lazyPut<PaymentController>(() => PaymentController());
    //     }
    //   }),
    // ),
    GetPage(
      name: AppRoutes.paymentHistory,
      page: () => const PaymentsHistoryScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<PaymentController>()) {
          Get.lazyPut<PaymentController>(() => PaymentController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<NotificationController>()) {
          Get.lazyPut<NotificationController>(() => NotificationController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileDashboardScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.lazyPut<ProfileController>(() => ProfileController());
        }
      }),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.lazyPut<ProfileController>(() => ProfileController());
        }
      }),
    ),
  ];
}
