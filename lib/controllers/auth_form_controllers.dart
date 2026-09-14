import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'locale_controller.dart';

class LoginFormController extends GetxController {
  LoginFormController(this._authController);

  final AuthController _authController;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final hidePassword = true.obs;
  final isSubmitting = false.obs;

  Future<String?> signIn() async {
    if (isSubmitting.value) return 'submitting';
    isSubmitting.value = true;
    try {
      await _authController.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      await LocaleController.restoreFromFirestore();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'unknown';
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class RegisterFormController extends GetxController {
  RegisterFormController(this._authController);

  final AuthController _authController;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final isSubmitting = false.obs;

  Future<String?> createAccount() async {
    if (isSubmitting.value) return 'submitting';
    isSubmitting.value = true;
    try {
      await _authController.createAccount(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'unknown';
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authController);

  final AuthController _authController;

  final emailController = TextEditingController();
  final isSending = false.obs;

  Future<String?> sendResetLink() async {
    if (isSending.value) return 'submitting';
    isSending.value = true;
    try {
      await _authController.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'unknown';
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
