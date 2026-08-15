import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _accentRed = Color(0xFFD72638);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _mutedText = Color(0xFF8B95A3);
const Color _successGreen = Color(0xFF16765C);

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shipmentController.dispose();
    _messageController.dispose();
    super.dispose();
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

  Future<void> _openWhatsApp() async {
    final message = Uri.encodeComponent(
      'Hello TAWAM AL-SHAHIN TRANSPORT, I need assistance.',
    );

    final uri = Uri.parse('https://wa.me/971509106107?text=$message');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      _showTemporaryMessage('Could not open WhatsApp');
    }
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:+971509106107');

    if (!await launchUrl(uri)) {
      if (!mounted) return;
      _showTemporaryMessage('Could not open phone');
    }
  }

  Future<void> _emailSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'info@tawam-alshahin.ae',
      queryParameters: {'subject': 'TAWAM AL-SHAHIN TRANSPORT Support Request'},
    );

    if (!await launchUrl(uri)) {
      if (!mounted) return;
      _showTemporaryMessage('Could not open email');
    }
  }

  String? _requiredValidator(String? value, String errorMessage) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email address';
    }

    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!validEmail) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  Future<void> _submitSupportRequest() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showTemporaryMessage('Please sign in before sending a support request');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('support_requests').add({
        'userId': user.uid,
        'category': _selectedCategory,
        'shipmentNumber': _shipmentController.text.trim(),
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _shipmentController.clear();
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      _showTemporaryMessage(
        'Could not send your support request. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(25, 29, 25, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(29),
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
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F7F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _successGreen,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 21),

                const Text(
                  'Support Request Sent',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _darkNavy,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your request was submitted successfully. Our support team will review it and contact you as soon as possible.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _mutedText,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 21),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FC),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2FC),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: _primaryBlue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request category',
                              style: TextStyle(
                                color: Color(0xFF929BA8),
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCategory,
                              style: const TextStyle(
                                color: _darkNavy,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
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

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA2AAB5), fontSize: 13.5),
      prefixIcon: Icon(icon, color: _primaryBlue, size: 21),
      suffixIcon: suffixIcon,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 38),
            children: [
              _buildPremiumHeader(),

              const SizedBox(height: 22),

              const Text(
                'Contact our team',
                style: TextStyle(
                  color: _darkNavy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Choose the fastest way to reach Tawam support.',
                style: TextStyle(color: _mutedText, fontSize: 13),
              ),

              const SizedBox(height: 15),

              _ContactMethodCard(
                icon: Icons.chat_rounded,
                iconBackground: const Color(0xFFE8F7F1),
                iconColor: _successGreen,
                title: 'WhatsApp Support',
                subtitle: 'Quick assistance from our logistics team',
                actionText: 'Start chat',
                onTap: _openWhatsApp,
              ),

              const SizedBox(height: 13),

              _ContactMethodCard(
                icon: Icons.phone_in_talk_outlined,
                iconBackground: const Color(0xFFE8F2FC),
                iconColor: _primaryBlue,
                title: 'Call Support',
                subtitle: 'Speak directly with a support specialist',
                actionText: 'Call now',
                onTap: _callSupport,
              ),

              const SizedBox(height: 13),

              _ContactMethodCard(
                icon: Icons.email_outlined,
                iconBackground: const Color(0xFFFFECEE),
                iconColor: _accentRed,
                title: 'Email Support',
                subtitle: 'Send documents or detailed information',
                actionText: 'Send email',
                onTap: _emailSupport,
              ),

              const SizedBox(height: 22),

              _SectionCard(
                icon: Icons.support_agent_rounded,
                title: 'Send a Support Request',
                subtitle:
                    'Share the details below and our team will review your request.',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _darkNavy,
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
                              color: _darkNavy,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
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

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _shipmentController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _fieldDecoration(
                        hintText: 'Shipment number — optional',
                        icon: Icons.local_shipping_outlined,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          'Please enter your full name',
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: 'Full name',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

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

                    const SizedBox(height: 14),

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

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _messageController,
                      minLines: 5,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      validator: (value) {
                        final result = _requiredValidator(
                          value,
                          'Please describe your request',
                        );

                        if (result != null) return result;

                        if (value!.trim().length < 10) {
                          return 'Please add more details';
                        }

                        return null;
                      },
                      decoration: _fieldDecoration(
                        hintText:
                            'Describe the issue or assistance you need...',
                        icon: Icons.edit_note_rounded,
                      ),
                    ),

                    const SizedBox(height: 17),

                    SizedBox(
                      width: double.infinity,
                      height: 59,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitSupportRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF7CA8CF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Send Support Request',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildWorkingHoursCard(),

              const SizedBox(height: 23),

              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: _darkNavy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              const _FaqCard(
                question: 'Where can I find my tracking number?',
                answer:
                    'Your tracking number is included in the shipment confirmation sent by Tawam.',
              ),

              const SizedBox(height: 11),

              const _FaqCard(
                question: 'Why has my shipment status not changed?',
                answer:
                    'Tracking updates may appear after the shipment reaches its next logistics checkpoint.',
              ),

              const SizedBox(height: 11),

              const _FaqCard(
                question: 'How do I request a shipping quotation?',
                answer:
                    'Open Request Quote from the home page and submit the shipment details.',
              ),

              const SizedBox(height: 11),

              const _FaqCard(
                question: 'Can I update my delivery information?',
                answer:
                    'Contact the support team and include your shipment number and the new delivery details.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF092542), Color(0xFF07569E), Color(0xFF0874C9)],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3507569E),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

              const Spacer(),

              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: _primaryBlue,
                  size: 27,
                ),
              ),
            ],
          ),

          const SizedBox(height: 27),

          Container(
            width: 59,
            height: 59,
            decoration: BoxDecoration(
              color: const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0x28FFFFFF)),
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Customer Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Expert assistance for your shipments, quotations and logistics requests.',
            style: TextStyle(
              color: Color(0xFFD9E9F8),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 21),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0x20FFFFFF),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0x25FFFFFF)),
            ),
            child: const Row(
              children: [
                _PulsingStatusDot(),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Support team online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  'Fast response',
                  style: TextStyle(
                    color: Color(0xFFDCEAF8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF6FD), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFDCE9F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule_rounded, color: _primaryBlue),
              SizedBox(width: 11),
              Text(
                'Support Hours',
                style: TextStyle(
                  color: _darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const _WorkingHoursRow(
            day: 'Monday – Friday',
            time: '08:00 AM – 08:00 PM',
          ),

          const SizedBox(height: 12),

          const Divider(color: Color(0xFFDCE6EF), height: 1),

          const SizedBox(height: 12),

          const _WorkingHoursRow(day: 'Saturday', time: '09:00 AM – 05:00 PM'),

          const SizedBox(height: 12),

          const Divider(color: Color(0xFFDCE6EF), height: 1),

          const SizedBox(height: 12),

          const _WorkingHoursRow(day: 'Sunday', time: 'Emergency support'),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.public_rounded, color: _primaryBlue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Times are shown in UAE local time.',
                    style: TextStyle(
                      color: Color(0xFF718093),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;

  const _ContactMethodCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: _borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0B294D),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(Icons.arrow_forward_rounded, color: iconColor, size: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B294D),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _primaryBlue, size: 23),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: _primaryBlue,
          collapsedIconColor: const Color(0xFF8D97A4),
          title: Text(
            question,
            style: const TextStyle(
              color: _darkNavy,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: _mutedText,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingHoursRow extends StatelessWidget {
  final String day;
  final String time;

  const _WorkingHoursRow({required this.day, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            day,
            style: const TextStyle(
              color: _darkNavy,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            color: _primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PulsingStatusDot extends StatelessWidget {
  const _PulsingStatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFF53E0A5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x8053E0A5), blurRadius: 9, spreadRadius: 2),
        ],
      ),
    );
  }
}
