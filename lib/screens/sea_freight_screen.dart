import 'package:flutter/material.dart';

import 'get_quote_screen.dart';
import 'shipping_documents_screen.dart';
import 'support_screen.dart';

class SeaFreightScreen extends StatelessWidget {
  const SeaFreightScreen({super.key});

  static const Color _deepBlue = Color(0xFF062B55);
  static const Color _primaryBlue = Color(0xFF0B4F9C);
  static const Color _brightBlue = Color(0xFF1268BC);

  static const Color _pageBg = Color(0xFFF4F7FB);
  static const Color _softBlue = Color(0xFFEAF3FF);
  static const Color _border = Color(0xFFE2EAF2);

  static const Color _textDark = Color(0xFF101B2D);
  static const Color _textGrey = Color(0xFF7E8A9A);

  void _openQuote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GetQuoteScreen(initialServiceType: 'Sea Freight'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(context),

                    const SizedBox(height: 22),

                    _buildTrustStrip(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.directions_boat_filled_outlined,
                      title: 'Ocean Freight Solutions',
                      subtitle:
                          'Reliable global shipping built around your cargo.',
                    ),

                    const SizedBox(height: 14),

                    _buildOverview(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.inventory_2_outlined,
                      title: 'Our Sea Freight Services',
                      subtitle:
                          'Flexible options for different shipment requirements.',
                    ),

                    const SizedBox(height: 14),

                    _buildServices(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.verified_outlined,
                      title: 'Why Ship With TAWAM AL-SHAHIN',
                      subtitle:
                          'Professional logistics support from origin to destination.',
                    ),

                    const SizedBox(height: 14),

                    _buildBenefits(context),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.route_outlined,
                      title: 'How It Works',
                      subtitle:
                          'A clear process for secure international movement.',
                    ),

                    const SizedBox(height: 16),

                    _buildProcess(),

                    const SizedBox(height: 28),

                    _buildCoverage(),

                    const SizedBox(height: 28),

                    _buildQuoteCard(context),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x10062B55),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: const Color(0xFFF6F9FD),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(15),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _deepBlue,
                  size: 26,
                ),
              ),
            ),
          ),

          const SizedBox(width: 13),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sea Freight',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 9,
                    letterSpacing: .45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_boat_filled_outlined,
              color: _primaryBlue,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22062B55),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/sea_freight.png', fit: BoxFit.cover),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x25000000),
                  Color(0x65062B55),
                  Color(0xF0062B55),
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),

          Positioned(
            top: 18,
            left: 18,
            child: _heroBadge(
              icon: Icons.public_rounded,
              text: 'GLOBAL OCEAN NETWORK',
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 21,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Global Sea Freight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Secure, flexible and professionally managed ocean freight solutions for international cargo.',
                  style: TextStyle(
                    color: Color(0xFFE8F2FF),
                    fontSize: 12,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 17),

                Row(
                  children: [
                    _smallHeroFeature(Icons.verified_user_outlined, 'Secure'),
                    const SizedBox(width: 16),
                    _smallHeroFeature(Icons.language_rounded, 'Global'),
                    const SizedBox(width: 16),
                    _smallHeroFeature(Icons.support_agent_rounded, 'Supported'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xDFFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primaryBlue, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _deepBlue,
              fontSize: 8,
              letterSpacing: .5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallHeroFeature(IconData icon, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF6CE6C0), size: 15),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _MiniStat(value: 'FCL', label: 'Full Container'),
          ),
          _MiniDivider(),
          Expanded(
            child: _MiniStat(value: 'LCL', label: 'Shared Cargo'),
          ),
          _MiniDivider(),
          Expanded(
            child: _MiniStat(value: 'D2D', label: 'Door-to-Door'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _primaryBlue, size: 22),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 10.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built for international cargo',
            style: TextStyle(
              color: _textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'TAWAM AL-SHAHIN TRANSPORT provides professionally coordinated sea freight solutions for commercial cargo, vehicles, machinery, consolidated shipments and containerized goods.',
            style: TextStyle(
              color: _textGrey,
              fontSize: 11,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Divider(color: _border),
          SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoPoint(
                  icon: Icons.inventory_2_outlined,
                  title: 'Flexible Cargo',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoPoint(
                  icon: Icons.route_rounded,
                  title: 'Managed Routes',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServices() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ServiceBox(
                icon: Icons.inventory_2_outlined,
                title: 'FCL Shipping',
                subtitle: 'Full container load',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ServiceBox(
                icon: Icons.widgets_outlined,
                title: 'LCL Shipping',
                subtitle: 'Shared container cargo',
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ServiceBox(
                icon: Icons.directions_car_filled_outlined,
                title: 'Vehicle Shipping',
                subtitle: 'International vehicles',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ServiceBox(
                icon: Icons.precision_manufacturing_outlined,
                title: 'Project Cargo',
                subtitle: 'Heavy & special cargo',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBenefits(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          const _BenefitRow(
            icon: Icons.public_rounded,
            title: 'International Coverage',
            subtitle:
                'Coordinated movement across major ports and trade routes.',
          ),

          const _CardDivider(),

          const _BenefitRow(
            icon: Icons.security_rounded,
            title: 'Cargo-Focused Handling',
            subtitle:
                'Professional coordination throughout the shipping process.',
          ),

          const _CardDivider(),

          _BenefitRow(
            icon: Icons.description_outlined,
            title: 'Documentation Support',
            subtitle:
                'Structured shipment documentation and customer assistance.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShippingDocumentsScreen(),
                ),
              );
            },
          ),

          const _CardDivider(),

          _BenefitRow(
            icon: Icons.support_agent_rounded,
            title: 'Dedicated Support',
            subtitle: 'Clear communication from booking through delivery.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProcess() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: _whiteCardDecoration(),
      child: const Column(
        children: [
          _ProcessStep(
            number: '01',
            title: 'Request a Quote',
            subtitle:
                'Send your cargo details, route and shipment requirements.',
            isLast: false,
          ),
          _ProcessStep(
            number: '02',
            title: 'Plan & Confirm',
            subtitle:
                'Our team reviews the shipment and coordinates the transport plan.',
            isLast: false,
          ),
          _ProcessStep(
            number: '03',
            title: 'Cargo Movement',
            subtitle:
                'Your shipment is coordinated through the selected ocean route.',
            isLast: false,
          ),
          _ProcessStep(
            number: '04',
            title: 'Delivery',
            subtitle: 'Final destination coordination and shipment completion.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBlue, _primaryBlue, _brightBlue],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26062B55),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -18,
            child: Icon(
              Icons.public_rounded,
              color: Colors.white.withValues(alpha: .08),
              size: 120,
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.language_rounded, color: Colors.white, size: 28),

              SizedBox(height: 16),

              Text(
                'Global Reach. Local Support.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Sea freight solutions designed for international trade, regional logistics and worldwide cargo movement.',
                style: TextStyle(
                  color: Color(0xFFDDEBFA),
                  fontSize: 11,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10062B55),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.request_quote_outlined,
              color: _primaryBlue,
              size: 27,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Ready to Ship?',
            style: TextStyle(
              color: _textDark,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Send us your shipment details and our team will prepare a tailored logistics quotation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGrey, fontSize: 10.5, height: 1.5),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _openQuote(context),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text(
                'REQUEST A QUOTE',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: .25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _whiteCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D062B55),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;

  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: SeaFreightScreen._primaryBlue,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: SeaFreightScreen._textGrey,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 31, color: SeaFreightScreen._border);
  }
}

class _InfoPoint extends StatelessWidget {
  final IconData icon;
  final String title;

  const _InfoPoint({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: SeaFreightScreen._pageBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: SeaFreightScreen._primaryBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: SeaFreightScreen._textDark,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ServiceBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 135),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SeaFreightScreen._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C062B55),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SeaFreightScreen._softBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: SeaFreightScreen._primaryBlue, size: 21),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(
              color: SeaFreightScreen._textDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: SeaFreightScreen._textGrey,
              fontSize: 9,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SeaFreightScreen._softBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: SeaFreightScreen._primaryBlue,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SeaFreightScreen._textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: SeaFreightScreen._textGrey,
                        fontSize: 9.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: SeaFreightScreen._primaryBlue,
                    size: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Divider(color: SeaFreightScreen._border, height: 1),
    );
  }
}

class _ProcessStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool isLast;

  const _ProcessStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: SeaFreightScreen._primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: SeaFreightScreen._border,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: SeaFreightScreen._textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: SeaFreightScreen._textGrey,
                      fontSize: 9.5,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
