import 'package:flutter/material.dart';

import 'get_quote_screen.dart';
import 'shipping_documents_screen.dart';
import 'support_screen.dart';

class InternationalMovingScreen extends StatelessWidget {
  const InternationalMovingScreen({super.key});

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
        builder: (_) =>
            const GetQuoteScreen(initialServiceType: 'International Moving'),
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
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),

                    const SizedBox(height: 22),

                    _buildServiceStrip(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.home_work_outlined,
                      title: 'Premium Moving Solutions',
                      subtitle:
                          'Professionally coordinated international relocation from door to door.',
                    ),

                    const SizedBox(height: 14),

                    _buildOverview(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.inventory_2_outlined,
                      title: 'Our Moving Services',
                      subtitle:
                          'Flexible relocation solutions for household and personal belongings.',
                    ),

                    const SizedBox(height: 14),

                    _buildServices(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.verified_outlined,
                      title: 'Why Move With TAWAM AL-SHAHIN',
                      subtitle:
                          'Professional relocation support from collection to final delivery.',
                    ),

                    const SizedBox(height: 14),

                    _buildBenefits(context),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      icon: Icons.route_outlined,
                      title: 'How It Works',
                      subtitle:
                          'A structured international moving process from your old home to your new one.',
                    ),

                    const SizedBox(height: 16),

                    _buildProcess(),

                    const SizedBox(height: 28),

                    _buildRelocationCard(),

                    const SizedBox(height: 28),

                    _buildQuoteCard(context),
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
  // HEADER
  // ==========================================================

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
                  'International Moving',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
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
              Icons.home_work_outlined,
              color: _primaryBlue,
              size: 25,
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
          Image.asset('assets/images/moving.png', fit: BoxFit.cover),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x18000000),
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
              text: 'GLOBAL RELOCATION SERVICE',
            ),
          ),

          Positioned(
            right: 18,
            top: 18,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                color: _primaryBlue,
                size: 21,
              ),
            ),
          ),

          const Positioned(
            left: 20,
            right: 20,
            bottom: 21,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Move Beyond Borders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Professional international relocation solutions designed for a smooth and secure move to your new destination.',
                  style: TextStyle(
                    color: Color(0xFFE8F2FF),
                    fontSize: 12,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 17),

                Row(
                  children: [
                    _HeroFeature(
                      icon: Icons.inventory_2_outlined,
                      text: 'Packed',
                    ),
                    SizedBox(width: 17),
                    _HeroFeature(icon: Icons.security_rounded, text: 'Secure'),
                    SizedBox(width: 17),
                    _HeroFeature(
                      icon: Icons.home_rounded,
                      text: 'Door-to-Door',
                    ),
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
        color: const Color(0xEFFFFFFF),
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
              letterSpacing: .45,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SERVICE STRIP
  // ==========================================================

  Widget _buildServiceStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _MiniStat(value: 'PACK', label: 'Packing Support'),
          ),
          _MiniDivider(),
          Expanded(
            child: _MiniStat(value: 'MOVE', label: 'Global Relocation'),
          ),
          _MiniDivider(),
          Expanded(
            child: _MiniStat(value: 'D2D', label: 'Door-to-Door'),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TITLES
  // ==========================================================

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

  // ==========================================================
  // OVERVIEW
  // ==========================================================

  Widget _buildOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Built for international relocation',
            style: TextStyle(
              color: _textDark,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 9),

          Text(
            'TAWAM AL-SHAHIN TRANSPORT provides professionally coordinated relocation solutions for household goods, personal belongings, furniture and international moving requirements.',
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
                  title: 'Careful Handling',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoPoint(
                  icon: Icons.home_work_outlined,
                  title: 'Managed Move',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SERVICES
  // ==========================================================

  Widget _buildServices() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ServiceBox(
                icon: Icons.inventory_2_outlined,
                title: 'Packing Service',
                subtitle: 'Professional packing support',
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: _ServiceBox(
                icon: Icons.chair_outlined,
                title: 'Household Goods',
                subtitle: 'Furniture & personal items',
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ServiceBox(
                icon: Icons.public_rounded,
                title: 'Global Moving',
                subtitle: 'International relocation',
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: _ServiceBox(
                icon: Icons.home_work_outlined,
                title: 'Door-to-Door',
                subtitle: 'Complete moving coordination',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // BENEFITS
  // ==========================================================

  Widget _buildBenefits(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _whiteCardDecoration(),
      child: Column(
        children: [
          const _BenefitRow(
            icon: Icons.inventory_2_outlined,
            title: 'Professional Packing',
            subtitle:
                'Organized handling and packing support for personal belongings.',
          ),

          const _CardDivider(),

          const _BenefitRow(
            icon: Icons.security_rounded,
            title: 'Relocation-Focused Handling',
            subtitle:
                'Professional coordination designed around international moving.',
          ),

          const _CardDivider(),

          _BenefitRow(
            icon: Icons.description_outlined,
            title: 'Documentation Support',
            subtitle:
                'Structured moving documentation and customer assistance.',
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
            title: 'Dedicated Moving Support',
            subtitle: 'Clear communication throughout your relocation journey.',
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

  // ==========================================================
  // PROCESS
  // ==========================================================

  Widget _buildProcess() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: _whiteCardDecoration(),
      child: const Column(
        children: [
          _ProcessStep(
            number: '01',
            title: 'Request Your Quote',
            subtitle:
                'Send your moving details, origin, destination and requirements.',
            isLast: false,
          ),

          _ProcessStep(
            number: '02',
            title: 'Moving Plan',
            subtitle:
                'Our team coordinates your relocation requirements and transport plan.',
            isLast: false,
          ),

          _ProcessStep(
            number: '03',
            title: 'Packing & Collection',
            subtitle:
                'Your belongings are prepared and collected for transportation.',
            isLast: false,
          ),

          _ProcessStep(
            number: '04',
            title: 'New Home Delivery',
            subtitle:
                'Final destination coordination and delivery to your new location.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREMIUM CARD
  // ==========================================================

  Widget _buildRelocationCard() {
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
            top: -22,
            child: Icon(
              Icons.home_work_rounded,
              color: Colors.white.withValues(alpha: .08),
              size: 125,
            ),
          ),

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.public_rounded, color: Colors.white, size: 28),

              SizedBox(height: 16),

              Text(
                'Your Move. Worldwide.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'International relocation designed around professional coordination, personal care and dependable door-to-door support.',
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

  // ==========================================================
  // QUOTE CTA
  // ==========================================================

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
            'Planning Your Move?',
            style: TextStyle(
              color: _textDark,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Send us your relocation details and our team will prepare a tailored international moving quotation.',
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
                'REQUEST MOVING QUOTE',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: .2,
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

// ==========================================================
// HELPERS
// ==========================================================

class _HeroFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF6CE6C0), size: 15),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
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
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: InternationalMovingScreen._primaryBlue,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: InternationalMovingScreen._textGrey,
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
    return Container(
      width: 1,
      height: 31,
      color: InternationalMovingScreen._border,
    );
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
        color: InternationalMovingScreen._pageBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: InternationalMovingScreen._primaryBlue, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: InternationalMovingScreen._textDark,
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
        border: Border.all(color: InternationalMovingScreen._border),
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
              color: InternationalMovingScreen._softBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: InternationalMovingScreen._primaryBlue,
              size: 21,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            style: const TextStyle(
              color: InternationalMovingScreen._textDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              color: InternationalMovingScreen._textGrey,
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
                  color: InternationalMovingScreen._softBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: InternationalMovingScreen._primaryBlue,
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
                        color: InternationalMovingScreen._textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: InternationalMovingScreen._textGrey,
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
                    color: InternationalMovingScreen._primaryBlue,
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
      child: Divider(color: InternationalMovingScreen._border, height: 1),
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
                  color: InternationalMovingScreen._primaryBlue,
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
                    color: InternationalMovingScreen._border,
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
                      color: InternationalMovingScreen._textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: InternationalMovingScreen._textGrey,
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
