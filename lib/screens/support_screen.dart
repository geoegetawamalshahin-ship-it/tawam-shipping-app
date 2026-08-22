import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'my_support_requests_screen.dart';

// ==========================================================
// TAWAM BRAND
// ==========================================================

const Color _primaryBlue = Color(0xFF0B4F9C);
const Color _brightBlue = Color(0xFF1268BC);
const Color _deepBlue = Color(0xFF062B55);

const Color _pageBg = Color(0xFFF4F7FB);
const Color _softBlue = Color(0xFFEAF3FF);
const Color _border = Color(0xFFE2EAF2);

const Color _textDark = Color(0xFF101B2D);
const Color _textGrey = Color(0xFF7E8A9A);

const Color _success = Color(0xFF16765C);
const Color _danger = Color(0xFFD72638);

// ==========================================================
// SCREEN
// ==========================================================

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shipmentController = TextEditingController();
  final _messageController = TextEditingController();

  final List<String> _supportCategories = const [
    'Shipment Tracking',
    'Delivery Delay',
    'Request a Quote',
    'Customs Clearance',
    'Payment & Invoice',
    'Damaged Shipment',
    'General Inquiry',
  ];

  String _selectedCategory = 'Shipment Tracking';
  bool _isSubmitting = false;

  // ==========================================================
  // INIT / DISPOSE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final displayName = user.displayName?.trim() ?? '';
      final email = user.email?.trim() ?? '';

      if (displayName.isNotEmpty) {
        _nameController.text = displayName;
      }

      if (email.isNotEmpty) {
        _emailController.text = email;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shipmentController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ==========================================================
  // MESSAGES
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==========================================================
  // CONTACT METHODS
  // ==========================================================

  Future<void> _openWhatsApp() async {
    final message = Uri.encodeComponent(
      'Hello TAWAM AL-SHAHIN TRANSPORT, I need assistance.',
    );

    final uri = Uri.parse('https://wa.me/971509106107?text=$message');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Could not open WhatsApp.');
    }
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:+971509106107');

    if (!await launchUrl(uri)) {
      _showMessage('Could not open the phone app.');
    }
  }

  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@tawam-alshahin.ae',
      queryParameters: {'subject': 'TAWAM AL-SHAHIN TRANSPORT Support Request'},
    );

    if (!await launchUrl(uri)) {
      _showMessage('Could not open the email app.');
    }
  }

  // ==========================================================
  // VALIDATION
  // ==========================================================

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!isValid) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ==========================================================
  // SUBMIT SUPPORT REQUEST
  // ==========================================================

  Future<void> _submitSupportRequest() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in before sending a support request.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Keep the same Firestore field structure used by
      // the existing support system/admin panel.
      await FirebaseFirestore.instance.collection('support_requests').add({
        'userId': user.uid,
        'category': _selectedCategory,
        'shipmentNumber': _shipmentController.text.trim().toUpperCase(),
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _shipmentController.clear();
      _messageController.clear();

      _showSuccessDialog();
    } catch (_) {
      if (!mounted) return;

      _showMessage('Could not send your support request. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ==========================================================
  // SUCCESS DIALOG
  // ==========================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 27, 24, 23),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 38,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _success,
                    size: 39,
                  ),
                ),

                const SizedBox(height: 19),

                const Text(
                  'Request Successfully Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 9),

                const Text(
                  'Your support case has been securely submitted to the TAWAM operations team.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _textGrey, fontSize: 12, height: 1.5),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 41,
                        height: 41,
                        decoration: BoxDecoration(
                          color: _softBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: _primaryBlue,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'REQUEST CATEGORY',
                              style: TextStyle(
                                color: _textGrey,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .55,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCategory,
                              style: const TextStyle(
                                color: _textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // FIELD STYLE
  // ==========================================================

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFA2AAB5),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _danger, width: 1.5),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
                  children: [
                    _buildHero(),

                    const SizedBox(height: 18),

                    _sectionHeading(
                      title: 'Instant Assistance',
                      subtitle: 'Choose the fastest channel for your request.',
                    ),

                    const SizedBox(height: 11),

                    Row(
                      children: [
                        Expanded(
                          child: _QuickContactCard(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            subtitle: 'Start chat',
                            color: _success,
                            background: const Color(0xFFEAF8F0),
                            onTap: _openWhatsApp,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _QuickContactCard(
                            icon: Icons.phone_in_talk_outlined,
                            label: 'Call',
                            subtitle: 'Call support',
                            color: _primaryBlue,
                            background: _softBlue,
                            onTap: _callSupport,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _QuickContactCard(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            subtitle: 'Send email',
                            color: _deepBlue,
                            background: const Color(0xFFF0F3F8),
                            onTap: _emailSupport,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildServiceAssurance(),

                    const SizedBox(height: 16),

                    _buildMySupportRequestsCard(),

                    const SizedBox(height: 20),

                    _sectionHeading(
                      title: 'Open a Support Case',
                      subtitle:
                          'Send your request directly to our operations team.',
                    ),

                    const SizedBox(height: 11),

                    _buildSupportForm(),

                    const SizedBox(height: 20),

                    _buildHoursCard(),

                    const SizedBox(height: 20),

                    _sectionHeading(
                      title: 'Frequently Asked Questions',
                      subtitle: 'Quick answers to common logistics questions.',
                    ),

                    const SizedBox(height: 11),

                    const _FaqCard(
                      question: 'Where can I find my tracking number?',
                      answer:
                          'Your tracking number is included in your shipment confirmation and can also be found in My Shipments.',
                    ),

                    const SizedBox(height: 9),

                    const _FaqCard(
                      question: 'Why has my shipment status not changed?',
                      answer:
                          'Tracking updates may appear after your shipment reaches the next logistics checkpoint or after an operations update.',
                    ),

                    const SizedBox(height: 9),

                    const _FaqCard(
                      question: 'How do I request a shipping quotation?',
                      answer:
                          'Open Get a Quote from the home page and submit your shipment details.',
                    ),

                    const SizedBox(height: 9),

                    const _FaqCard(
                      question: 'Can I update my delivery information?',
                      answer:
                          'Contact support and include your tracking number together with the new delivery information.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TOP HEADER
  // ==========================================================

  Widget _buildTopHeader() {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _SquareButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Support',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .85,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _primaryBlue,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBlue, Color(0xFF0A4789), _brightBlue],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .17),
            blurRadius: 26,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -32,
            top: -30,
            child: Icon(
              Icons.headset_mic_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _LiveDot(),
                  SizedBox(width: 7),
                  Text(
                    'LOGISTICS SUPPORT CENTER',
                    style: TextStyle(
                      color: Color(0xFFD2E3F3),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                'How Can We Help?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Professional assistance for shipments, quotations, customs and delivery requests.',
                style: TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 10.9,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 18),

              Row(
                children: [
                  _HeroFeature(
                    icon: Icons.lock_outline_rounded,
                    label: 'Secure',
                  ),
                  SizedBox(width: 18),
                  _HeroFeature(
                    icon: Icons.support_agent_rounded,
                    label: 'Expert Team',
                  ),
                  SizedBox(width: 18),
                  _HeroFeature(icon: Icons.sync_rounded, label: 'Connected'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION HEADING
  // ==========================================================

  Widget _sectionHeading({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(color: _textGrey, fontSize: 9.6, height: 1.35),
        ),
      ],
    );
  }

  // ==========================================================
  // SERVICE ASSURANCE
  // ==========================================================

  Widget _buildServiceAssurance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _AssuranceItem(
              icon: Icons.verified_user_outlined,
              title: 'Secure',
              subtitle: 'Protected request',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _AssuranceItem(
              icon: Icons.support_agent_rounded,
              title: 'Specialists',
              subtitle: 'Logistics team',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _AssuranceItem(
              icon: Icons.task_alt_rounded,
              title: 'Tracked',
              subtitle: 'Case submitted',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMySupportRequestsCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MySupportRequestsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF062B55), Color(0xFF0B4F9C)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _deepBlue.withValues(alpha: .12),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Support Requests',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your cases and latest updates',
                      style: TextStyle(
                        color: Color(0xFFD6E5F4),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ==========================================================
  // SUPPORT FORM
  // ==========================================================

  Widget _buildSupportForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: _softBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: _primaryBlue,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Request',
                      style: TextStyle(
                        color: _textDark,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Provide the details below.',
                      style: TextStyle(color: _textGrey, fontSize: 9.5),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _deepBlue,
            ),
            decoration: _fieldDecoration(
              hintText: 'Support category',
              icon: Icons.category_outlined,
            ),
            items: _supportCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedCategory = value;
              });
            },
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _shipmentController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
            decoration: _fieldDecoration(
              hintText: 'Tracking / shipment number — optional',
              icon: Icons.local_shipping_outlined,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              return _requiredValidator(value, 'Please enter your full name');
            },
            decoration: _fieldDecoration(
              hintText: 'Full name',
              icon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _emailValidator,
            decoration: _fieldDecoration(
              hintText: 'Email address',
              icon: Icons.email_outlined,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              return _requiredValidator(
                value,
                'Please enter your phone number',
              );
            },
            decoration: _fieldDecoration(
              hintText: 'Phone number',
              icon: Icons.phone_outlined,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: _messageController,
            minLines: 5,
            maxLines: 8,
            textInputAction: TextInputAction.newline,
            validator: (value) {
              final required = _requiredValidator(
                value,
                'Please describe your request',
              );

              if (required != null) {
                return required;
              }

              if (value!.trim().length < 10) {
                return 'Please add more details';
              }

              return null;
            },
            decoration: _fieldDecoration(
              hintText: 'Describe the issue or assistance you need...',
              icon: Icons.edit_note_rounded,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: _primaryBlue, size: 17),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For shipment-related requests, include the tracking number to help our team review the case faster.',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 53,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitSupportRequest,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _isSubmitting ? 'SUBMITTING...' : 'SUBMIT SUPPORT REQUEST',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .45,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF7DA7CF),
                disabledForegroundColor: Colors.white,
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
  // HOURS
  // ==========================================================

  Widget _buildHoursCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF6FD), Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE9F4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, color: _primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Support Hours',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          _HoursRow(day: 'Monday – Friday', time: '08:00 AM – 08:00 PM'),

          SizedBox(height: 10),
          Divider(color: Color(0xFFDDE6EF)),
          SizedBox(height: 10),

          _HoursRow(day: 'Saturday', time: '09:00 AM – 05:00 PM'),

          SizedBox(height: 10),
          Divider(color: Color(0xFFDDE6EF)),
          SizedBox(height: 10),

          _HoursRow(day: 'Sunday', time: 'Emergency support'),

          SizedBox(height: 14),

          Row(
            children: [
              Icon(Icons.public_rounded, color: _primaryBlue, size: 17),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Times shown in UAE local time.',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 9.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// QUICK CONTACT
// ==========================================================

class _QuickContactCard extends StatelessWidget {
  const _QuickContactCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),

              const SizedBox(height: 9),

              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 7.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// ASSURANCE
// ==========================================================

class _AssuranceItem extends StatelessWidget {
  const _AssuranceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _primaryBlue, size: 20),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _textGrey, fontSize: 7.5),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 43,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: _border,
    );
  }
}

// ==========================================================
// FAQ
// ==========================================================

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: _primaryBlue,
          collapsedIconColor: const Color(0xFF8D97A4),
          title: Text(
            question,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// HOURS
// ==========================================================

class _HoursRow extends StatelessWidget {
  const _HoursRow({required this.day, required this.time});

  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            day,
            style: const TextStyle(
              color: _textDark,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: _primaryBlue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// HEADER / HERO SMALL COMPONENTS
// ==========================================================

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _deepBlue, size: 22),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF55D6A5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
