import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/auth_field_decoration.dart';
import '../widgets/auth_password_field.dart';
import '../widgets/auth_submit_button.dart';
import '../controllers/auth_form_controllers.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final RegisterFormController _c;

  @override
  void initState() {
    super.initState();
    _c = Get.find<RegisterFormController>();
  }

  Future<void> _createAccount() async {
    if (_c.isSubmitting.value) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final code = await _c.createAccount();
    if (!mounted || code == 'submitting') return;

    if (code == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.accountCreated)));

      Navigator.of(context).pop();
      return;
    }

    String message = l10n.couldNotCreateAccount;

    if (code == 'weak-password') {
      message = l10n.passwordTooShort;
    } else if (code == 'invalid-email') {
      message = l10n.pleaseEnterValidEmail;
    } else if (code == 'email-already-in-use') {
      message = l10n.alreadyHaveAccount;
    } else if (code == 'unknown') {
      message = l10n.somethingWentWrong;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return authInputDecoration(
      hintText: hintText,
      icon: icon,
      suffixIcon: suffixIcon,
      contentPaddingVertical: 19,
      errorBorderEnabled: true,
      focusedErrorBorderEnabled: true,
    );
  }

  Widget _fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF202938),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 25),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF172033),
                      ),
                    ),

                    Center(
                      child: SizedBox(
                        height: 115,
                        child: Transform.scale(
                          scale: 1.35,
                          child: Image.asset(
                            'assets/images/tawam_logo.png',
                            width: 250,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

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
                        l10n.createAccount,
                        style: const TextStyle(
                          color: Color(0xFF07569E),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      l10n.registerTitle,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 31,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      l10n.registerSubtitle,
                      style: const TextStyle(
                        color: Color(0xFF7B8493),
                        fontSize: 15.5,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _fieldTitle(l10n.fullName),

                    TextFormField(
                      controller: _c.nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hintText: l10n.fullName,
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.pleaseEnterFullName;
                        }

                        if (value.trim().length < 3) {
                          return l10n.pleaseEnterValidName;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 21),

                    _fieldTitle(l10n.phoneNumber),

                    TextFormField(
                      controller: _c.phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hintText: '+971 50 123 4567',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.isEmpty) {
                          return l10n.pleaseEnterPhone;
                        }

                        if (phone.length < 8) {
                          return l10n.pleaseEnterValidPhone;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 21),

                    _fieldTitle(l10n.emailAddress),

                    TextFormField(
                      controller: _c.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hintText: 'you@business.com',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return l10n.pleaseEnterEmail;
                        }

                        if (!email.contains('@') || !email.contains('.')) {
                          return l10n.pleaseEnterValidEmail;
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 21),

                    _fieldTitle(l10n.password),

                    Obx(
                      () => AuthPasswordField(
                        controller: _c.passwordController,
                        hintText: l10n.pleaseCreatePassword,
                        obscureText: _c.hidePassword.value,
                        onToggleVisibility: () {
                          _c.hidePassword.value = !_c.hidePassword.value;
                        },
                        textInputAction: TextInputAction.next,
                        contentPaddingVertical: 19,
                        errorBorderEnabled: true,
                        focusedErrorBorderEnabled: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseCreatePassword;
                          }

                          if (value.length < 6) {
                            return l10n.passwordTooShort;
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 21),

                    _fieldTitle(l10n.confirmPassword),

                    Obx(
                      () => AuthPasswordField(
                        controller: _c.confirmPasswordController,
                        hintText: l10n.confirmPassword,
                        obscureText: _c.hideConfirmPassword.value,
                        onToggleVisibility: () {
                          _c.hideConfirmPassword.value =
                              !_c.hideConfirmPassword.value;
                        },
                        onFieldSubmitted: (_) => _createAccount(),
                        icon: Icons.lock_reset_rounded,
                        contentPaddingVertical: 19,
                        errorBorderEnabled: true,
                        focusedErrorBorderEnabled: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseConfirmPassword;
                          }

                          if (value != _c.passwordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    AuthSubmitButton(
                      label: l10n.createAccount,
                      submitting: _c.isSubmitting,
                      onPressed: _createAccount,
                    ),

                    const SizedBox(height: 22),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.alreadyHaveAccount,
                          style: const TextStyle(
                            color: Color(0xFFD72638),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
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
