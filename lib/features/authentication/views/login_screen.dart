import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/custom_text_field.dart';
import 'package:gifting/features/authentication/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();

  bool obscurePassword = true;

  final controller = Get.find<AuthController>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.eco_outlined, size: 24, color: AppColors.primary),
                Expanded(
                  child: Text(
                    'Tribe Green',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            Text(
              'Login to explore corporate gifting.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
            .slideY(
              begin: -0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        actions: [
          Obx(
            () => IconButton(
              tooltip: ThemeController.to.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () => ThemeController.to.toggleTheme(),
              icon: Icon(
                ThemeController.to.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                // padding: const EdgeInsets.all(0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      spacing: 80,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        fieldsWidget(),
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() ==
                                        true) {
                                      controller.login(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      );
                                    }
                                  },
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget fieldsWidget() {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Email',
          icon: const Icon(Icons.email),
          controller: emailController,
          currentFocus: emailFocus,
          nextFocus: passwordFocus,
          isEmail: true,
        ),
        CustomTextField(
          label: 'Password',
          icon: const Icon(Icons.password),
          controller: passwordController,
          currentFocus: passwordFocus,
          isPassword: obscurePassword,
          suffixIcon: IconButton(
            onPressed: () {
              obscurePassword = !obscurePassword;
              setState(() {});
            },
            icon: obscurePassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Align(
            alignment: AlignmentGeometry.centerRight,
            child: TextButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.signup);
              },
              child: const Text('Dont have an account? Signup'),
            ),
          ),
        ),
      ],
    );
  }
}
