import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShipmentRequestPage extends StatefulWidget {
  const ShipmentRequestPage({super.key});

  @override
  State<ShipmentRequestPage> createState() => _ShipmentRequestPageState();
}

class _ShipmentRequestPageState extends State<ShipmentRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final pickupController = TextEditingController();
  final deliveryController = TextEditingController();
  final cargoController = TextEditingController();
  final notesController = TextEditingController();

  DateTime? expectedDelivery;
  bool isSubmitting = false;

  @override
  void dispose() {
    pickupController.dispose();
    deliveryController.dispose();
    cargoController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (selectedDate != null) {
      setState(() {
        expectedDelivery = selectedDate;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in again.')));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final userData = await _getCurrentUserData();

      final customerName =
          (userData?['name'] ??
                  userData?['fullName'] ??
                  currentUser.displayName ??
                  'Customer')
              .toString();

      final customerEmail = (userData?['email'] ?? currentUser.email ?? '')
          .toString();

      final requestRef = FirebaseFirestore.instance
          .collection('shipment_requests')
          .doc();

      await requestRef.set({
        'userId': currentUser.uid,
        'customerName': customerName,
        'customerEmail': customerEmail,

        'pickupLocation': pickupController.text.trim(),
        'deliveryLocation': deliveryController.text.trim(),
        'cargo': cargoController.text.trim(),

        'expectedDelivery': expectedDelivery != null
            ? Timestamp.fromDate(expectedDelivery!)
            : null,

        'notes': notesController.text.trim(),

        'status': 'pending_review',
        'requestId': requestRef.id,

        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shipment request submitted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit shipment request: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF07569E)),
      filled: true,
      fillColor: const Color(0xFFF6F9FD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE3EBF5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE3EBF5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF07569E), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF10233F),
        title: const Text(
          'Request Shipment',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF102E55), Color(0xFF0864B7)],
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 27,
                        backgroundColor: Color(0x26FFFFFF),
                        child: Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Shipment Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Send your shipment details for review by our logistics team.',
                              style: TextStyle(
                                color: Color(0xFFD8E8F8),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE7EDF5)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: pickupController,
                        decoration: _inputDecoration(
                          label: 'Pickup Location',
                          hint: 'Example: Dubai, UAE',
                          icon: Icons.radio_button_checked_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter pickup location';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: deliveryController,
                        decoration: _inputDecoration(
                          label: 'Delivery Location',
                          hint: 'Example: Amman, Jordan',
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter delivery location';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: cargoController,
                        decoration: _inputDecoration(
                          label: 'Cargo',
                          hint: 'Describe the shipment',
                          icon: Icons.inventory_2_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter cargo details';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(18),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            label: 'Expected Delivery',
                            icon: Icons.calendar_month_outlined,
                          ),
                          child: Text(
                            expectedDelivery == null
                                ? 'Select preferred date'
                                : '${expectedDelivery!.day}/${expectedDelivery!.month}/${expectedDelivery!.year}',
                            style: TextStyle(
                              color: expectedDelivery == null
                                  ? const Color(0xFF8B95A3)
                                  : const Color(0xFF10233F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          label: 'Additional Notes',
                          hint: 'Special handling, dimensions, vehicle type...',
                          icon: Icons.notes_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FD),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF07569E),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your request will be reviewed by Tawam logistics. A shipment and tracking number will only be created after approval.',
                          style: TextStyle(
                            color: Color(0xFF53657A),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075FAE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit Shipment Request',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
