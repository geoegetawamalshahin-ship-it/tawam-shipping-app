import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'shipping_documents_screen.dart';
import 'support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';
import '../locale_controller.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _accentRed = Color(0xFFD72638);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _mutedText = Color(0xFF8B95A3);
const Color _successGreen = Color(0xFF16765C);

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

  bool _notificationsEnabled = true;
  bool _shipmentUpdatesEnabled = true;
  bool _biometricEnabled = false;
  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final document = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = document.data();

      setState(() {
        _fullName =
            data?['name']?.toString() ?? user.displayName ?? 'Tawam Customer';

        _email = data?['email']?.toString() ?? user.email ?? '';

        _phone = data?['phone']?.toString() ?? '';

        _company = data?['company']?.toString() ?? 'Not provided';

        _address = data?['address']?.toString() ?? 'Not provided';
        _customerId =
            data?['customerId']?.toString() ??
            'TW-${user.uid.substring(0, 8).toUpperCase()}';
        _notificationsEnabled = data?['notificationsEnabled'] as bool? ?? true;

        _shipmentUpdatesEnabled =
            data?['shipmentUpdatesEnabled'] as bool? ?? true;
        _selectedLanguage = data?['language']?.toString() ?? 'English';
      });
    } catch (e) {
      if (!mounted) return;

      _showTemporaryMessage('Could not load profile information');
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
        final data = doc.data();
        final status = data['status']?.toString().toLowerCase() ?? '';

        return status == 'in transit' || status == 'in_transit';
      }).length;

      if (!mounted) return;

      setState(() {
        _shipmentsCount = shipments.docs.length;
        _inTransitCount = inTransit;
        _quotesCount = quotes.docs.length;
      });
    } catch (e) {
      if (!mounted) return;

      _showTemporaryMessage('Could not load account statistics');
    }
  }

  Future<void> _savePreference(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {field: value},
      );
    } catch (e) {
      if (!mounted) return;

      _showTemporaryMessage('Could not save preference');
    }
  }

  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA2AAB5), fontSize: 13.5),
      prefixIcon: Icon(icon, color: _primaryBlue, size: 21),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _accentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _accentRed, width: 1.5),
      ),
    );
  }

  Future<void> _editProfile() async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: _fullName);
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    final companyController = TextEditingController(text: _company);
    final addressController = TextEditingController(text: _address);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.90,
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            20,
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
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7DCE3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: _darkNavy,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Update your personal information',
                              style: TextStyle(
                                color: _mutedText,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.close_rounded, color: _darkNavy),
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
                      hintText: 'Full name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Please enter your email address';
                      }

                      if (!email.contains('@')) {
                        return 'Please enter a valid email address';
                      }

                      return null;
                    },
                    decoration: _fieldDecoration(
                      hintText: 'Email address',
                      icon: Icons.email_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

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
                      hintText: 'Phone number',
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: companyController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      hintText: 'Company name',
                      icon: Icons.business_outlined,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: addressController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _fieldDecoration(
                      hintText: 'Address',
                      icon: Icons.location_on_outlined,
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        Navigator.pop(sheetContext, {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'company': companyController.text.trim(),
                          'address': addressController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_rounded),
                        ],
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'name': result['name'] ?? _fullName,
            'phone': result['phone'] ?? _phone,
            'company': result['company'] ?? _company,
            'address': result['address'] ?? _address,
          });

      await user.updateDisplayName(result['name'] ?? _fullName);

      if (!mounted) return;

      setState(() {
        _fullName = result['name'] ?? _fullName;
        _phone = result['phone'] ?? _phone;
        _company = result['company'] ?? _company;
        _address = result['address'] ?? _address;
      });

      _showTemporaryMessage('Profile updated successfully');
    } catch (e) {
      if (!mounted) return;

      _showTemporaryMessage('Could not update profile');
    }
  }

  Future<void> _selectLanguage() async {
    const languages = ['English', 'Arabic', 'French'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
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
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DCE3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Application Language',
                    style: TextStyle(
                      color: _darkNavy,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                ...languages.map((language) {
                  final selectedLanguage = language == _selectedLanguage;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: selectedLanguage
                          ? const Color(0xFFEAF4FD)
                          : const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(sheetContext, language);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selectedLanguage
                                  ? const Color(0xFFBBD8F0)
                                  : _borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 39,
                                height: 39,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: _primaryBlue,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 13),

                              Expanded(
                                child: Text(
                                  language,
                                  style: const TextStyle(
                                    color: _darkNavy,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                              if (selectedLanguage)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: _primaryBlue,
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
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'language': selected},
      );
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showTemporaryMessage('Could not verify your account');
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
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Change Password',
            style: TextStyle(color: _darkNavy, fontWeight: FontWeight.w800),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  decoration: _fieldDecoration(
                    hintText: 'Current password',
                    icon: Icons.lock_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your current password';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    currentPassword = value;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  obscureText: true,
                  decoration: _fieldDecoration(
                    hintText: 'New password',
                    icon: Icons.lock_reset_rounded,
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
                  onChanged: (value) {
                    newPassword = value;
                  },
                ),

                const SizedBox(height: 14),

                TextFormField(
                  obscureText: true,
                  decoration: _fieldDecoration(
                    hintText: 'Confirm new password',
                    icon: Icons.verified_user_outlined,
                  ),
                  validator: (value) {
                    if (value != newPassword) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    confirmPassword = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                if (confirmPassword != newPassword) return;

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Update Password'),
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

      _showTemporaryMessage('Password updated successfully');
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

      _showTemporaryMessage(message);
    }
  }

  Future<void> _requestAccountDeletion() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      _showTemporaryMessage('Could not verify your account');
      return;
    }

    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          icon: Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_forever_outlined,
              color: _accentRed,
              size: 30,
            ),
          ),
          title: const Text(
            'Delete Account?',
            style: TextStyle(color: _darkNavy, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your account will be permanently deleted. Enter your password to confirm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _mutedText,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _fieldDecoration(
                  hintText: 'Current password',
                  icon: Icons.lock_outline_rounded,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                if (passwordController.text.trim().isEmpty) {
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentRed,
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

      // 1. نتأكد أن صاحب الحساب هو نفسه
      await user.reauthenticateWithCredential(credential);

      final deletionRef = FirebaseFirestore.instance
          .collection('account_deletion_requests')
          .doc(user.uid);

      final deletionDocument = await deletionRef.get();

      // 2. إذا ما كان في سجل حذف، ننشئه أولاً Pending
      if (!deletionDocument.exists) {
        await deletionRef.set({
          'userId': user.uid,
          'email': user.email ?? '',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 3. نحول السجل إلى Deleted حتى يظل ظاهر عند الأدمن
      await deletionRef.update({
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // 4. نحذف Profile من Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // 5. نحذف حساب Firebase Authentication نفسه
      await user.delete();

      passwordController.dispose();

      if (!mounted) return;

      // 6. نرجع مباشرة إلى Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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

      _showTemporaryMessage(message);
    } catch (e) {
      passwordController.dispose();

      if (!mounted) return;

      _showTemporaryMessage('Could not delete account');
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          icon: Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: _accentRed,
              size: 29,
            ),
          ),
          title: const Text(
            'Sign Out?',
            style: TextStyle(color: _darkNavy, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Are you sure you want to sign out of your Tawam account?',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 13.5, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _darkNavy,
                side: const BorderSide(color: _borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 22),

            const Text(
              'Account Information',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _ProfileSectionCard(
              children: [
                _ProfileOption(
                  icon: Icons.email_outlined,
                  title: 'Email Address',
                  subtitle: _email,
                  showArrow: false,
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  subtitle: _phone,
                  showArrow: false,
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.business_outlined,
                  title: 'Company',
                  subtitle: _company,
                  showArrow: false,
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.location_on_outlined,
                  title: 'Default Address',
                  subtitle: _address,
                  onTap: () {
                    _showTemporaryMessage(
                      'Saved addresses will be connected later',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Preferences',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _ProfileSectionCard(
              children: [
                _ProfileOption(
                  icon: Icons.notifications_none_rounded,
                  title: 'Push Notifications',
                  subtitle: 'General application notifications',
                  trailing: Switch.adaptive(
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });

                      await _savePreference('notificationsEnabled', value);
                    },
                  ),
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.local_shipping_outlined,
                  title: 'Shipment Updates',
                  subtitle: 'Status and delivery notifications',
                  trailing: Switch.adaptive(
                    value: _shipmentUpdatesEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _shipmentUpdatesEnabled = value;
                      });

                      await _savePreference('shipmentUpdatesEnabled', value);
                    },
                  ),
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  onTap: _selectLanguage,
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Security & Account',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _ProfileSectionCard(
              children: [
                _ProfileOption(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Sign In',
                  subtitle: 'Use fingerprint or Face ID',
                  trailing: Switch.adaptive(
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() {
                        _biometricEnabled = value;
                      });
                    },
                  ),
                ),

                _sectionDivider(),

                _ProfileOption(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: _changePassword,
                ),

                _sectionDivider(),

                _ProfileOption(
                  icon: Icons.description_outlined,
                  title: 'Shipping Documents',
                  subtitle: 'View invoices and shipment files',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ShippingDocumentsScreen(),
                      ),
                    );
                  },
                ),
                _sectionDivider(),

                _ProfileOption(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your account and personal data',
                  onTap: _requestAccountDeletion,
                ),
              ],
            ), // _ProfileSectionCard

            const SizedBox(height: 22),

            const Text(
              'Support & Legal',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _ProfileSectionCard(
              children: [
                _ProfileOption(
                  icon: Icons.help_outline_rounded,
                  title: 'Help Center',
                  subtitle: 'Get assistance with Tawam services',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy information',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ), // _ProfileOption
                _sectionDivider(),
                _ProfileOption(
                  icon: Icons.gavel_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'Application usage terms',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsConditionsScreen(),
                      ),
                    );
                  },
                ), // _ProfileOption
              ], // children
            ), // _ProfileSectionCard
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _accentRed,
                  side: const BorderSide(color: Color(0xFFF2BEC4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Column(
                children: [
                  Text(
                    'Tawam Al-Shahin Shipping Services',
                    style: TextStyle(
                      color: Color(0xFF939DAB),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'App Version 1.0.0',
                    style: TextStyle(color: Color(0xFFB0B7C1), fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF092542), Color(0xFF07569E), Color(0xFF0874C9)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3507569E),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Material(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),

              const Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: _editProfile,
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.edit_outlined,
                      color: _primaryBlue,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x55FFFFFF), width: 5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 18,
                      offset: Offset(0, 9),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  _fullName.isNotEmpty
                      ? _fullName.substring(0, 1).toUpperCase()
                      : 'T',
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Positioned(
                right: 1,
                bottom: 3,
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: _successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          Text(
            _fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Verified Tawam Customer',
            style: TextStyle(
              color: Color(0xFFD8E8F8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x20FFFFFF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0x25FFFFFF)),
            ),
            child: Text(
              'Customer ID: $_customerId',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              Expanded(
                child: _ProfileStat(
                  value: _shipmentsCount.toString(),
                  label: 'Shipments',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  value: _inTransitCount.toString(),
                  label: 'In Transit',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileStat(
                  value: _quotesCount.toString(),
                  label: 'Quotes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 61),
      child: Divider(color: _borderColor, height: 1),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x25FFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCEAF8),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B294D),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showArrow;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _primaryBlue, size: 22),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              if (trailing != null)
                trailing!
              else if (showArrow && onTap != null)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFB1B9C3),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
