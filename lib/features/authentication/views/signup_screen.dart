import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gifting/app/routes/app_routes.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/core/theme/theme_controller.dart';
import 'package:gifting/core/widgets/custom_text_field.dart';
import 'package:gifting/features/authentication/controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signUpKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  final mobileController = TextEditingController();
  FocusNode mobileFocus = FocusNode();
  final emailController = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final companyController = TextEditingController();
  FocusNode companyFocus = FocusNode();
  final passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  final confirmPasswordController = TextEditingController();
  FocusNode confirmPasswordFocus = FocusNode();

  bool obscurePassword = true;

  final controller = Get.find<AuthController>();

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    companyController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    mobileFocus.dispose();
    companyFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title:
            Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.eco_outlined,
                          size: 24,
                          color: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            'Tribe Green',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Signup to explore corporate gifting.',
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: signUpKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child:
                    Card(
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
                                            if (signUpKey.currentState
                                                    ?.validate() ==
                                                true) {
                                              controller.signUp(
                                                name: nameController.text,
                                                email: emailController.text,
                                                mobile: mobileController.text,
                                                company: companyController.text,
                                                password:
                                                    passwordController.text,
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
                                        : const Text('Sign up'),
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
          label: 'Full Name',
          icon: const Icon(Icons.person),
          controller: nameController,
          currentFocus: nameFocus,
          nextFocus: emailFocus,
          // onChanged: (p0) {
          //   setState(() {});
          // },
        ),
        CustomTextField(
          label: 'Email',
          icon: const Icon(Icons.email),
          controller: emailController,
          currentFocus: emailFocus,
          nextFocus: mobileFocus,
          isEmail: true,
        ),
        CustomTextField(
          label: 'Mobile Number',
          icon: const Icon(Icons.call),
          controller: mobileController,
          currentFocus: mobileFocus,
          nextFocus: companyFocus,
          isMobileNumber: true,
        ),
        CustomTextField(
          label: 'Company Name',
          icon: const Icon(Icons.factory),
          controller: companyController,
          currentFocus: companyFocus,
          nextFocus: passwordFocus,
        ),
        CustomTextField(
          label: 'Password',
          icon: const Icon(Icons.password),
          controller: passwordController,
          currentFocus: passwordFocus,
          nextFocus: confirmPasswordFocus,
          isObscureText: obscurePassword,
          isPassword: true,
          suffixIcon: IconButton(
            onPressed: () {
              obscurePassword = !obscurePassword;
              setState(() {});
            },
            icon: obscurePassword
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
          ),
          onChanged: (p0) {
            setState(() {});
          },
        ),
        CustomTextField(
          label: 'Confirm Password',
          icon: const Icon(Icons.password),
          controller: confirmPasswordController,
          currentFocus: confirmPasswordFocus,
          isObscureText: obscurePassword,
          isConfirmPassword: true,
          passwordText: passwordController.text.trim(),
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
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text('Already have an account? Login'),
            ),
          ),
        ),
      ],
    );
  }
}
