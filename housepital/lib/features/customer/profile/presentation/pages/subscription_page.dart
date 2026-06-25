import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../auth/data/models/user_model.dart';

class _SubscriptionDesign {
  static const primaryGreen = Color(0xFF00C853);
  static Color surface(bool isDark) => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF8FAFC);
  static Color textPrimary(bool isDark) => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1E293B);
  static Color textSecondary(bool isDark) => isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B);
  static Color textMuted(bool isDark) => isDark ? const Color(0xFF5F5C68) : const Color(0xFF94A3B8);
  static Color cardBg(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;
  static Color divider(bool isDark) => isDark ? const Color(0xFF2A2831) : const Color(0xFFE2E8F0);
  static Color bottomSheetBg(bool isDark) => isDark ? const Color(0xFF16151A) : Colors.white;

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

  static BoxShadow cardShadow(bool isDark) => BoxShadow(
    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow softShadow(bool isDark) => BoxShadow(
    color: const Color(0xFFFFB300).withOpacity(isDark ? 0.4 : 0.25),
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

  String _currentPlan = 'basic';
  int _selectedPlanIndex = -1;
  bool _isProcessingPayment = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

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
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentPlan = prefs.getString('subscription_plan') ?? 'basic';
      });
    }
  }

  Future<void> _savePlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_plan', plan);
    if (mounted) {
      setState(() {
        _currentPlan = plan;
      });
    }
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

  void _showUpgradeDialog(Map<String, dynamic> plan) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: _SubscriptionDesign.bottomSheetBg(_isDark),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _SubscriptionDesign.divider(_isDark),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Secure Checkout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _SubscriptionDesign.textPrimary(_isDark),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: _SubscriptionDesign.textSecondary(_isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDark ? const Color(0xFF222029) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: _SubscriptionDesign.premiumGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Housepital Premium Plan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _SubscriptionDesign.textPrimary(_isDark),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All features unlocked, no booking fees',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _SubscriptionDesign.textSecondary(_isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'EGP ${plan['price']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB300),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _SubscriptionDesign.textSecondary(_isDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodOption(
                    title: 'Credit / Debit Card',
                    subtitle: 'Visa / MasterCard ending in 4242',
                    icon: Icons.credit_card_rounded,
                    isSelected: true,
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodOption(
                    title: 'Vodafone Cash',
                    subtitle: '+20 101 **** 592',
                    icon: Icons.phone_android_rounded,
                    isSelected: false,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isProcessingPayment
                          ? null
                          : () async {
                              setModalState(() {
                                _isProcessingPayment = true;
                              });
                              setState(() {
                                _isProcessingPayment = true;
                              });
                              
                              await Future.delayed(const Duration(seconds: 2));
                              
                              if (mounted) {
                                await _savePlan('premium');
                                setState(() {
                                  _isProcessingPayment = false;
                                });
                                Navigator.pop(context);
                                _showSuccessDialog();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessingPayment
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Confirm & Pay EGP 199.00',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isProcessingPayment = false;
      });
    });
  }

  void _showDowngradeDialog() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _SubscriptionDesign.cardBg(_isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(
          'Downgrade Plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _SubscriptionDesign.textPrimary(_isDark),
          ),
        ),
        content: Text(
          'Are you sure you want to switch back to the Basic plan? You will lose access to premium features immediately.',
          style: TextStyle(
            color: _SubscriptionDesign.textSecondary(_isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Premium',
              style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _savePlan('basic');
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Successfully switched to Basic plan.'),
                    backgroundColor: _SubscriptionDesign.textSecondary(_isDark),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text(
              'Yes, Downgrade',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _SubscriptionDesign.cardBg(_isDark),
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
                boxShadow: [_SubscriptionDesign.softShadow(_isDark)],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Premium Unlocked!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _SubscriptionDesign.textPrimary(_isDark),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Congratulations! You are now a Housepital Premium Member.\nEnjoy priority bookings, zero service fees, and exclusive discounts!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _SubscriptionDesign.textSecondary(_isDark),
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
                'Explore Benefits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF1E1C24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFFB300)
              : _SubscriptionDesign.divider(_isDark),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFFFB300) : _SubscriptionDesign.textSecondary(_isDark)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _SubscriptionDesign.textPrimary(_isDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _SubscriptionDesign.textSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFB300))
          else
            Icon(Icons.circle_outlined, color: _SubscriptionDesign.divider(_isDark)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SubscriptionDesign.surface(_isDark),
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
        boxShadow: [_SubscriptionDesign.softShadow(_isDark)],
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
            const Color(0xFFFFB300).withOpacity(_isDark ? 0.15 : 0.1),
            const Color(0xFFFFC107).withOpacity(_isDark ? 0.08 : 0.05),
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
                Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _SubscriptionDesign.textPrimary(_isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Save up to 20% on all bookings',
                  style: TextStyle(fontSize: 13, color: _SubscriptionDesign.textSecondary(_isDark)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: _SubscriptionDesign.textMuted(_isDark),
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
            Text(
              'Available Plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _SubscriptionDesign.textPrimary(_isDark),
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
          color: _SubscriptionDesign.cardBg(_isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected || isPremium
                ? gradient.colors.first
                : _SubscriptionDesign.divider(_isDark),
            width: isSelected || isPremium ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected || isPremium)
              BoxShadow(
                color: gradient.colors.first.withOpacity(_isDark ? 0.3 : 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              _SubscriptionDesign.cardShadow(_isDark),
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
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            plan['name'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _SubscriptionDesign.textPrimary(_isDark),
                            ),
                          ),
                          if (plan['badge'] != null)
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
                          if (isCurrent)
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
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: plan['price'] == 0 ? 'Free' : 'EGP ${plan['price']}',
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
                                  color: _SubscriptionDesign.textSecondary(_isDark),
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
            Container(height: 1, color: _SubscriptionDesign.divider(_isDark)),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: _SubscriptionDesign.textSecondary(_isDark),
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
                  onPressed: () => _showUpgradeDialog(plan),
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
            if (plan['id'] == 'basic' && _currentPlan == 'premium') ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _showDowngradeDialog,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _SubscriptionDesign.divider(_isDark)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Switch to Basic',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _SubscriptionDesign.textPrimary(_isDark),
                    ),
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
        color: _SubscriptionDesign.cardBg(_isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_SubscriptionDesign.cardShadow(_isDark)],
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
              Text(
                'Plan Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _SubscriptionDesign.textPrimary(_isDark),
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
                      color: _SubscriptionDesign.textSecondary(_isDark),
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
                border: Border(bottom: BorderSide(color: _SubscriptionDesign.divider(_isDark))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      feature['name']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: _SubscriptionDesign.textSecondary(_isDark),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        feature['free']!,
                        style: TextStyle(fontSize: 13, color: _SubscriptionDesign.textSecondary(_isDark)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        feature['premium']!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isDark ? const Color(0xFFFFC107) : const Color(0xFFFFB300),
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
