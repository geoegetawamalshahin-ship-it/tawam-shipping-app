import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'package:get/get.dart';
import '../l10n/app_localizations.dart';
import '../presentation/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      final result = await Get.find<AuthController>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!result.isSuccess) {
        throw FirebaseAuthException(code: result.errorCode!);
      }

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = l10n.emailOrPasswordIncorrect;

      if (e.code == 'invalid-email') {
        message = l10n.pleaseEnterValidEmail;
      } else if (e.code == 'user-disabled') {
        message = l10n.accountDisabled;
      } else if (e.code == 'too-many-requests') {
        message = l10n.tooManyAttempts;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _forgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  void _createAccount() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
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
                      controller: _emailController,
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
                      decoration: InputDecoration(
                        hintText: 'you@business.com',
                        hintStyle: const TextStyle(color: Color(0xFFA5ABB5)),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFF87909D),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4E9),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4E9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFF07569E),
                            width: 1.7,
                          ),
                        ),
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

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.done,
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
                      decoration: InputDecoration(
                        hintText: l10n.password,
                        hintStyle: const TextStyle(color: Color(0xFFA5ABB5)),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFF87909D),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF07569E),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4E9),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E4E9),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFF07569E),
                            width: 1.7,
                          ),
                        ),
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

                    SizedBox(
                      width: double.infinity,
                      height: 59,
                      child: ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF07569E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.signIn,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_forward_rounded, size: 23),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
