import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/app_routes.dart';
import '../controllers/auth_form_controllers.dart';
import '../l10n/app_localizations.dart';
import '../widgets/auth_field_decoration.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_submit_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LoginFormController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.find<LoginFormController>();
  }

  Future<void> _signIn() async {
    if (_c.isSubmitting.value) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final code = await _c.signIn();
    if (!mounted || code == 'submitting') return;
    if (code == null) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    String message = l10n.emailOrPasswordIncorrect;
    if (code == 'invalid-email') {
      message = l10n.pleaseEnterValidEmail;
    } else if (code == 'user-disabled') {
      message = l10n.accountDisabled;
    } else if (code == 'too-many-requests') {
      message = l10n.tooManyAttempts;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _forgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void _createAccount() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 125,
                        child: Transform.scale(
                          scale: 1.45,
                          child: Image.asset(
                            'assets/images/tawam_logo.png',
                            width: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3FC),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        l10n.signIn,
                        style: const TextStyle(
                          color: Color(0xFF07569E),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      l10n.welcomeBack,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      l10n.signInSubtitle,
                      style: const TextStyle(
                        color: Color(0xFF7B8493),
                        fontSize: 15.5,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      l10n.emailAddress,
                      style: const TextStyle(
                        color: Color(0xFF202938),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 9),

                    TextFormField(
                      controller: _c.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return l10n.pleaseEnterEmail;
                        }

                        if (!email.contains('@')) {
                          return l10n.pleaseEnterValidEmail;
                        }

                        return null;
                      },
                      decoration: authInputDecoration(
                        hintText: 'you@business.com',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      l10n.password,
                      style: const TextStyle(
                        color: Color(0xFF202938),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Obx(
                      () => AuthPasswordField(
                        controller: _c.passwordController,
                        hintText: l10n.password,
                        obscureText: _c.hidePassword.value,
                        onToggleVisibility: () {
                          _c.hidePassword.value = !_c.hidePassword.value;
                        },
                        onFieldSubmitted: (_) => _signIn(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }

                          if (value.length < 6) {
                            return l10n.passwordTooShort;
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 9),

                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          l10n.forgotPassword,
                          style: const TextStyle(
                            color: Color(0xFF07569E),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    AuthSubmitButton(
                      label: l10n.signIn,
                      submitting: _c.isSubmitting,
                      onPressed: _signIn,
                    ),

                    const SizedBox(height: 24),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n.dontHaveAccount,
                          style: const TextStyle(
                            color: Color(0xFF7B8493),
                            fontSize: 14.5,
                          ),
                        ),
                        TextButton(
                          onPressed: _createAccount,
                          child: Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              color: Color(0xFFD72638),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        l10n.tawamAlShahinTransport,
                        style: const TextStyle(
                          color: Color(0xFFA0A7B2),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
