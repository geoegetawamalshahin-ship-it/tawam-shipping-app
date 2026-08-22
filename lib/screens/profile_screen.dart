import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'shipping_documents_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import '../locale_controller.dart';

// ==========================================================
// TAWAM AL-SHAHIN — PREMIUM CUSTOMER PROFILE
// ==========================================================

const Color _navy = Color(0xFF08233F);

const Color _blue = Color(0xFF0B5FB3);
const Color _blueLight = Color(0xFFEAF4FF);
const Color _page = Color(0xFFF4F7FB);
const Color _border = Color(0xFFE2E8F0);
const Color _text = Color(0xFF10233F);
const Color _muted = Color(0xFF7F8B99);

const Color _red = Color(0xFFD92D3A);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _company = 'Not provided';
  String _address = 'Not provided';
  String _selectedLanguage = 'English';
  String _customerId = '';

  int _shipmentsCount = 0;
  int _inTransitCount = 0;
  int _quotesCount = 0;
  bool _isLoading = true;
  String? _loadError;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  // ==========================================================
  // FIREBASE DATA
  // ==========================================================

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data();
      final shortUid = user.uid.length >= 8
          ? user.uid.substring(0, 8)
          : user.uid;

      setState(() {
        _fullName =
            data?['name']?.toString() ?? user.displayName ?? 'Tawam Customer';
        _email = data?['email']?.toString() ?? user.email ?? '';
        _phone = data?['phone']?.toString() ?? '';
        _company = data?['company']?.toString() ?? 'Not provided';
        _address = data?['address']?.toString() ?? 'Not provided';
        _selectedLanguage = data?['language']?.toString() ?? 'English';
        _notificationsEnabled = data?['notificationsEnabled'] as bool? ?? true;

        _customerId =
            data?['customerId']?.toString() ?? 'TW-${shortUid.toUpperCase()}';
        _isLoading = false;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load profile information.';
      });
    }
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final shipments = await FirebaseFirestore.instance
          .collection('shipments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final quotes = await FirebaseFirestore.instance
          .collection('quotes')
          .where('userId', isEqualTo: user.uid)
          .get();

      final inTransit = shipments.docs.where((doc) {
        final status =
            doc.data()['status']?.toString().trim().toLowerCase() ?? '';

        return status == 'in transit' ||
            status == 'in_transit' ||
            status == 'in-transit';
      }).length;

      if (!mounted) return;

      setState(() {
        _shipmentsCount = shipments.docs.length;
        _inTransitCount = inTransit;
        _quotesCount = quotes.docs.length;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not load account statistics');
    }
  }

  Future<void> _saveNotificationPreference(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _notificationsEnabled = value;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'notificationsEnabled': value,
      }, SetOptions(merge: true));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _notificationsEnabled = !value;
      });

      _showMessage('Could not save notification setting');
    }
  }

  // ==========================================================
  // COMMON UI
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _blue, size: 20),
      hintStyle: const TextStyle(color: Color(0xFFA2ABB7), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _blue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _red, width: 1.5),
      ),
    );
  }

  String _safe(String value) {
    if (value.trim().isEmpty) return 'Not provided';
    return value;
  }

  String get _initial {
    final name = _fullName.trim();
    if (name.isEmpty) return 'T';
    return name.substring(0, 1).toUpperCase();
  }

  // ==========================================================
  // EDIT PROFILE
  // ==========================================================

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: _fullName);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final companyController = TextEditingController(
      text: _company == 'Not provided' ? '' : _company,
    );
    final addressController = TextEditingController(
      text: _address == 'Not provided' ? '' : _address,
    );

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * .92,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Form(
              key: formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9DEE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _blueLight,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.manage_accounts_outlined,
                          color: _blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Customer Profile',
                              style: TextStyle(
                                color: _text,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Update your main account information',
                              style: TextStyle(color: _muted, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded, color: _text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    decoration: _fieldDecoration(
                      hint: 'Full name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    controller: emailController,
                    enabled: false,
                    decoration:
                        _fieldDecoration(
                          hint: 'Email address',
                          icon: Icons.email_outlined,
                        ).copyWith(
                          helperText: 'Email is linked to your sign-in account',
                          helperStyle: const TextStyle(
                            color: _muted,
                            fontSize: 9,
                          ),
                        ),
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                    decoration: _fieldDecoration(
                      hint: 'Phone number',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    controller: companyController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      hint: 'Company name',
                      icon: Icons.apartment_outlined,
                    ),
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    controller: addressController,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 2,
                    decoration: _fieldDecoration(
                      hint: 'Default address',
                      icon: Icons.location_on_outlined,
                    ),
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        Navigator.pop(sheetContext, {
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'company': companyController.text.trim(),
                          'address': addressController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == null || !mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final company = (result['company'] ?? '').trim();
      final address = (result['address'] ?? '').trim();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': result['name'] ?? _fullName,
        'phone': result['phone'] ?? _phone,
        'company': company.isEmpty ? 'Not provided' : company,
        'address': address.isEmpty ? 'Not provided' : address,
      }, SetOptions(merge: true));

      await user.updateDisplayName(result['name'] ?? _fullName);

      if (!mounted) return;

      setState(() {
        _fullName = result['name'] ?? _fullName;
        _phone = result['phone'] ?? _phone;
        _company = company.isEmpty ? 'Not provided' : company;
        _address = address.isEmpty ? 'Not provided' : address;
      });

      _showMessage('Profile updated successfully');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not update profile');
    }
  }

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  Future<void> _selectLanguage() async {
    const languages = ['English', 'Arabic', 'French'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DEE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 21),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Application Language',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                ...languages.map((language) {
                  final isSelected = language == _selectedLanguage;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected ? _blueLight : const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () => Navigator.pop(sheetContext, language),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB9D8F3)
                                  : _border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: _blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  language,
                                  style: const TextStyle(
                                    color: _text,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: _blue,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedLanguage = selected;
    });

    LocaleController.setLanguage(selected);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'language': selected,
      }, SetOptions(merge: true));
    }
  }

  // ==========================================================
  // PASSWORD
  // ==========================================================

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage('Could not verify your account');
      return;
    }

    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: _blueLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded, color: _blue, size: 28),
          ),
          title: const Text(
            'Change Password',
            textAlign: TextAlign.center,
            style: TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration: _fieldDecoration(
                      hint: 'Current password',
                      icon: Icons.lock_outline_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your current password';
                      }
                      return null;
                    },
                    onChanged: (value) => currentPassword = value,
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    obscureText: true,
                    decoration: _fieldDecoration(
                      hint: 'New password',
                      icon: Icons.password_rounded,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a new password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                    onChanged: (value) => newPassword = value,
                  ),
                  const SizedBox(height: 13),

                  TextFormField(
                    obscureText: true,
                    decoration: _fieldDecoration(
                      hint: 'Confirm password',
                      icon: Icons.verified_user_outlined,
                    ),
                    validator: (value) {
                      if (value != newPassword) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (value) => confirmPassword = value,
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                if (confirmPassword != newPassword) return;

                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;
      _showMessage('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Could not update password';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please sign in again and try again';
      }

      _showMessage(message);
    }
  }

  // ==========================================================
  // LEGAL & DELETE ACCOUNT
  // ==========================================================

  Future<void> _showAccountAndLegal() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCE2E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account & Legal',
                    style: TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Privacy, terms and account management',
                    style: TextStyle(color: _muted, fontSize: 10),
                  ),
                ),
                const SizedBox(height: 16),

                _sheetAction(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How we protect your information',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),

                _sheetAction(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'TAWAM application terms',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),

                _sheetAction(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Account',
                  subtitle: 'Permanently remove your customer account',
                  danger: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _requestAccountDeletion();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFF2F3) : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: danger ? const Color(0xFFF2D4D8) : _border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: danger ? _red : _blue, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: danger ? _red : _text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: danger
                    ? const Color(0xFFD99DA4)
                    : const Color(0xFFA7B2BE),
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestAccountDeletion() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showMessage('Could not verify your account');
      return;
    }

    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          icon: Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever_outlined,
              color: _red,
              size: 29,
            ),
          ),
          title: const Text(
            'Delete Account?',
            textAlign: TextAlign.center,
            style: TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your account will be permanently deleted. Enter your password to confirm.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12.5, height: 1.5),
              ),
              const SizedBox(height: 17),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _fieldDecoration(
                  hint: 'Current password',
                  icon: Icons.lock_outline_rounded,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordController.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      passwordController.dispose();
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      final deletionRef = FirebaseFirestore.instance
          .collection('account_deletion_requests')
          .doc(user.uid);

      final deletionDocument = await deletionRef.get();

      if (!deletionDocument.exists) {
        await deletionRef.set({
          'userId': user.uid,
          'email': user.email ?? '',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await deletionRef.update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      await user.delete();

      passwordController.dispose();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      passwordController.dispose();

      if (!mounted) return;

      String message = 'Could not delete account';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please sign in again and try again';
      }

      _showMessage(message);
    } catch (_) {
      passwordController.dispose();

      if (!mounted) return;
      _showMessage('Could not delete account');
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          icon: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: _blueLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: _blue, size: 27),
          ),
          title: const Text(
            'Sign Out?',
            textAlign: TextAlign.center,
            style: TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Are you sure you want to sign out of your TAWAM customer account?',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12.5, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && mounted) {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void _openDocuments() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ShippingDocumentsScreen()));
  }

  void _openSupport() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: _blue))
            : _loadError != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F6FC),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.cloud_off_rounded,
                          color: _blue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Please check your connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Future.wait([_loadProfile(), _loadStats()]);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: _blue,
                onRefresh: () async {
                  await Future.wait([_loadProfile(), _loadStats()]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 34),
                  children: [
                    _buildHeader(),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      eyebrow: 'CUSTOMER PROFILE',
                      title: 'Customer Details',
                    ),

                    const SizedBox(height: 10),

                    _buildCustomerDetails(),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      eyebrow: 'ACCOUNT CONTROL',
                      title: 'Account',
                    ),

                    const SizedBox(height: 10),

                    _buildAccountControls(),

                    const SizedBox(height: 22),

                    const _SectionTitle(
                      eyebrow: 'CUSTOMER SERVICES',
                      title: 'Assistance',
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.folder_copy_outlined,
                            title: 'Documents',
                            subtitle: 'Shipping files',
                            onTap: _openDocuments,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionCard(
                            icon: Icons.support_agent_rounded,
                            title: 'Support',
                            subtitle: 'Customer help',
                            onTap: _openSupport,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: TextButton.icon(
                        onPressed: _showAccountAndLegal,
                        icon: const Icon(Icons.shield_outlined, size: 16),
                        label: const Text(
                          'Account & Legal',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: TextButton.styleFrom(foregroundColor: _muted),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildSignOut(),

                    const SizedBox(height: 22),

                    const _Footer(),
                  ],
                ),
              ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071D36), Color(0xFF0A3D70), Color(0xFF0B5FB3)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x240B4F9C),
            blurRadius: 28,
            offset: Offset(0, 13),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .055),
                ),
              ),
            ),
            Positioned(
              bottom: -88,
              left: -60,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: const SizedBox(
                            width: 43,
                            height: 43,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text(
                              'TAWAM AL-SHAHIN TRANSPORT',
                              style: TextStyle(
                                color: Color(0xFFBCD6EC),
                                fontSize: 7,
                                letterSpacing: 1.4,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Customer Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: _editProfile,
                          borderRadius: BorderRadius.circular(14),
                          child: const SizedBox(
                            width: 43,
                            height: 43,
                            child: Icon(
                              Icons.edit_outlined,
                              color: _blue,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 21),

                  Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .45),
                            width: 4,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 17,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initial,
                          style: const TextStyle(
                            color: _blue,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fullName.isEmpty ? 'Tawam Customer' : _fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email.isEmpty ? 'Customer Account' : _email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFD5E6F5),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF0C8064,
                                ).withValues(alpha: .25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFF74DCC0,
                                  ).withValues(alpha: .35),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: Color(0xFF7CE3C6),
                                    size: 13,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'ACTIVE CUSTOMER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7.2,
                                      letterSpacing: .7,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .085),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .11),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFFD6E7F6),
                          size: 15,
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'CUSTOMER ID',
                          style: TextStyle(
                            color: Color(0xFFBED5E9),
                            fontSize: 7.2,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _customerId.isEmpty ? 'Loading...' : _customerId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.7,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 11),

                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          value: _shipmentsCount.toString(),
                          label: 'Shipments',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Metric(
                          value: _inTransitCount.toString(),
                          label: 'In Transit',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Metric(
                          value: _quotesCount.toString(),
                          label: 'Quotes',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CUSTOMER DETAILS
  // ==========================================================

  Widget _buildCustomerDetails() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A10233F),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.apartment_outlined,
            label: 'Company',
            value: _safe(_company),
          ),
          const SizedBox(height: 13),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _safe(_phone),
          ),
          const SizedBox(height: 13),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: _safe(_address),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ACCOUNT CONTROLS
  // ==========================================================

  Widget _buildAccountControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0910233F),
            blurRadius: 17,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          children: [
            _AccountTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Account and service updates',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                activeTrackColor: _blue,
                onChanged: _saveNotificationPreference,
              ),
            ),

            _divider(),

            _AccountTile(
              icon: Icons.lock_reset_rounded,
              title: 'Change Password',
              subtitle: 'Update account security',
              onTap: _changePassword,
            ),

            _divider(),

            _AccountTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: _selectedLanguage,
              onTap: _selectLanguage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOut() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _confirmLogout,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C10233F),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF0),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD92D3A),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Color(0xFF10233F),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Securely end your current session',
                      style: TextStyle(color: Color(0xFF8A96A5), fontSize: 8.8),
                    ),
                  ],
                ),
              ),

              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F7FB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9AA6B4),
                  size: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.only(left: 62),
      child: Divider(color: _border, height: 1, thickness: .8),
    );
  }
}

// ==========================================================
// SECTION TITLE
// ==========================================================

class _SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _SectionTitle({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: _blue,
              fontSize: 7,
              letterSpacing: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -.15,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// HEADER METRIC
// ==========================================================

class _Metric extends StatelessWidget {
  final String value;
  final String label;

  const _Metric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .11)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD2E2F0),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// CUSTOMER INFO ROW
// ==========================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: _blueLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _blue, size: 19),
        ),
        const SizedBox(width: 11),
        SizedBox(
          width: 69,
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _text,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// ACCOUNT TILE
// ==========================================================

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 13, 13),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _blue, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(color: _muted, fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFA7B2BE),
                  size: 12,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// SERVICE ACTION CARD
// ==========================================================

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 98,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0910233F),
                blurRadius: 15,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: _blueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _blue, size: 19),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 8.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// FOOTER
// ==========================================================

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Text(
            'TAWAM AL-SHAHIN TRANSPORT',
            style: TextStyle(
              color: Color(0xFF7E8A99),
              fontSize: 8.7,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'GLOBAL LOGISTICS CUSTOMER PORTAL',
            style: TextStyle(
              color: Color(0xFFA7B0BB),
              fontSize: 7.2,
              letterSpacing: 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Secure • Reliable • Connected',
            style: TextStyle(color: Color(0xFFB2BAC4), fontSize: 8.2),
          ),
        ],
      ),
    );
  }
}
