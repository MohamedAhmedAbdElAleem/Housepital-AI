import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../auth/data/models/user_model.dart';

class _SubscriptionDesign {
  static const primaryGreen = Color(0xFF00C853);
  static const surface = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const cardBg = Colors.white;

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFFC107), Color(0xFFFFD54F)],
  );

  static const premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB300), Color(0xFFFFC107)],
  );

  static const freeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00E676)],
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow get softShadow => BoxShadow(
    color: const Color(0xFFFFB300).withOpacity(0.25),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

class SubscriptionPage extends StatefulWidget {
  final UserModel? user;

  const SubscriptionPage({super.key, this.user});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _currentPlan = 'free';
  int _selectedPlanIndex = -1;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'premium',
      'name': 'Premium',
      'price': 199,
      'period': 'month',
      'badge': 'MOST POPULAR',
      'icon': Icons.diamond_rounded,
      'gradient': _SubscriptionDesign.premiumGradient,
      'features': [
        {'icon': Icons.flash_on_rounded, 'text': 'Priority booking'},
        {'icon': Icons.money_off_rounded, 'text': 'No booking fees'},
        {'icon': Icons.support_agent_rounded, 'text': '24/7 Priority support'},
        {
          'icon': Icons.family_restroom_rounded,
          'text': 'Up to 5 family members',
        },
        {'icon': Icons.local_offer_rounded, 'text': 'Up to 20% discounts'},
        {'icon': Icons.history_rounded, 'text': 'Extended medical history'},
      ],
    },
    {
      'id': 'basic',
      'name': 'Basic',
      'price': 0,
      'period': 'forever',
      'badge': null,
      'icon': Icons.star_outline_rounded,
      'gradient': _SubscriptionDesign.freeGradient,
      'features': [
        {'icon': Icons.calendar_today_rounded, 'text': 'Standard booking'},
        {'icon': Icons.support_rounded, 'text': 'Email support'},
        {
          'icon': Icons.people_outline_rounded,
          'text': 'Up to 2 family members',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showUpgradeDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _SubscriptionDesign.premiumGradient,
                    shape: BoxShape.circle,
                    boxShadow: [_SubscriptionDesign.softShadow],
                  ),
                  child: const Icon(
                    Icons.diamond_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _SubscriptionDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This feature will be available soon.\nStay tuned for updates!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SubscriptionDesign.surface,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBenefitsHighlight(),
                      const SizedBox(height: 24),
                      _buildPlansSection(),
                      const SizedBox(height: 24),
                      _buildComparisonTable(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: _SubscriptionDesign.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [_SubscriptionDesign.softShadow],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'My Subscription',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),
              _buildCurrentPlanCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final isPremium = _currentPlan == 'premium';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isPremium ? Icons.diamond_rounded : Icons.star_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPremium ? 'Premium Plan' : 'Free Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPremium ? 'ACTIVE' : 'CURRENT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isPremium
                      ? 'Valid until Dec 2026'
                      : 'Basic features included',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsHighlight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB300).withOpacity(0.1),
            const Color(0xFFFFC107).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: _SubscriptionDesign.premiumGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _SubscriptionDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save up to 20% on all bookings',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey[400],
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: _SubscriptionDesign.premiumGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'Available Plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _SubscriptionDesign.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._plans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 150)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildPlanCard(plan, index),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final isPremium = plan['id'] == 'premium';
    final isCurrent = plan['id'] == _currentPlan;
    final isSelected = _selectedPlanIndex == index;
    final gradient = plan['gradient'] as LinearGradient;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlanIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _SubscriptionDesign.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected || isPremium
                    ? gradient.colors.first
                    : const Color(0xFFE2E8F0),
            width: isSelected || isPremium ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected || isPremium)
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              _SubscriptionDesign.cardShadow,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    plan['icon'] as IconData,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan['name'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _SubscriptionDesign.textPrimary,
                            ),
                          ),
                          if (plan['badge'] != null) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                plan['badge'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          if (isCurrent) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _SubscriptionDesign.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'CURRENT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  plan['price'] == 0
                                      ? 'Free'
                                      : 'EGP ${plan['price']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: gradient.colors.first,
                              ),
                            ),
                            if (plan['price'] != 0)
                              TextSpan(
                                text: '/${plan['period']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
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
            const SizedBox(height: 20),
            Container(height: 1, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            ...(plan['features'] as List).map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: gradient.colors.first.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: gradient.colors.first,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature['text'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _SubscriptionDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (isPremium && !isCurrent) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _showUpgradeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradient.colors.first,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    final features = [
      {'name': 'Booking Priority', 'free': 'Standard', 'premium': 'Priority'},
      {'name': 'Booking Fees', 'free': 'Standard', 'premium': 'No Fees'},
      {'name': 'Support', 'free': 'Email', 'premium': '24/7 Priority'},
      {'name': 'Family Members', 'free': '2', 'premium': '5'},
      {'name': 'Discounts', 'free': '-', 'premium': 'Up to 20%'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _SubscriptionDesign.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_SubscriptionDesign.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: _SubscriptionDesign.freeGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Plan Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _SubscriptionDesign.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(flex: 2, child: SizedBox()),
              Expanded(
                child: Center(
                  child: Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: _SubscriptionDesign.premiumGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      feature['name']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: _SubscriptionDesign.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        feature['free']!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        feature['premium']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
