import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:housepital/generated/l10n/app_localizations.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'add_dependent_page.dart';
import 'edit_dependent_page.dart';

// Design System
class _FamilyDesign {
  final BuildContext context;
  _FamilyDesign(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get primaryGreen => const Color(0xFF00C853);
  Color get surface => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? Colors.white70 : const Color(0xFF64748B);
  Color get cardBg => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get scaffoldBg => isDark ? Colors.black : const Color(0xFFF8FAFC);
  Color get arrowBg => isDark ? Colors.white.withAlpha(20) : const Color(0xFFF1F5F9);

  LinearGradient get headerGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16151A), Color(0xFF0D0C10)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C853), Color(0xFF00B248), Color(0xFF009624)],
        );

  List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(isDark ? 100 : 15),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];
}

class FamilyPage extends StatefulWidget {
  const FamilyPage({super.key});

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> with TickerProviderStateMixin {
  List<dynamic> _dependents = [];
  bool _isLoading = true;

  late AnimationController _animController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchDependents();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDependents() async {
    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();

      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(
            'Unable to load family members. Please log in again.',
          );
        }
        return;
      }

      final apiService = ApiService();
      final response = await apiService.post(
        '/api/user/getAllDependents',
        body: {'id': userId},
      );

      if (mounted) {
        setState(() {
          _dependents = response is List ? response : [];
          _isLoading = false;
        });
        _animController.forward();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _fabController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    String localizedMsg = message;
    if (message == 'Unable to load family members. Please log in again.') {
      if (mounted) {
        localizedMsg = AppLocalizations.of(context)!.errLoadFamily;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(localizedMsg)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToAddDependent() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDependentPage()),
    );
    if (result == true) {
      _fetchDependents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: design.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: _fetchDependents,
        color: design.primaryGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader()),

            // Content
            _isLoading
                ? SliverFillRemaining(child: _buildLoadingState())
                : _dependents.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder:
                            (context, child) => Opacity(
                              opacity: _fadeAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, _slideAnimation.value),
                                child: _buildFamilyMemberCard(
                                  _dependents[index],
                                  index,
                                ),
                              ),
                            ),
                      );
                    }, childCount: _dependents.length),
                  ),
                ),
          ],
        ),
      ),

      // Floating Add Button
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: design.headerGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: design.primaryGreen.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _goToAddDependent,
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: Text(
              l10n.addMember,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: design.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: design.primaryGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
          child: Column(
            children: [
              // App Bar
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.info_outline_rounded, size: 22),
                      color: Colors.white,
                      onPressed: () => _showInfoDialog(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Icon
              Container(
                 padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                l10n.familyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading
                          ? l10n.loadingFamily
                          : _dependents.length == 1
                              ? l10n.memberSingle
                              : l10n.membersPlural(_dependents.length),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: design.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: design.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: design.primaryGreen,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.aboutFamilyTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: design.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.aboutFamilyDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: design.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: design.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.gotIt),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLoadingState() {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: design.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: design.primaryGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.loadingFamily,
            style: TextStyle(color: design.textSecondary, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    design.primaryGreen.withOpacity(0.15),
                    design.primaryGreen.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.family_restroom_rounded,
                size: 80,
                color: design.primaryGreen,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              l10n.noFamilyMembers,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: design.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              l10n.noFamilyMembersDesc,
              style: TextStyle(
                fontSize: 15,
                color: design.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Add Button
            Container(
              decoration: BoxDecoration(
                gradient: design.headerGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: design.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _goToAddDependent,
                icon: const Icon(Icons.person_add_rounded),
                label: Text(l10n.addFamilyMember),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyMemberCard(dynamic dep, int index) {
    final design = _FamilyDesign(context);
    final l10n = AppLocalizations.of(context)!;
    final String fullName = dep['fullName'] ?? 'Unknown';
    final String relationship = dep['relationship'] ?? '';
    final String gender = dep['gender'] ?? 'other';
    final String dateOfBirth = dep['dateOfBirth'] ?? '';
    final String mobile = dep['mobile'] ?? '';

    // Calculate age
    int age = 0;
    if (dateOfBirth.isNotEmpty) {
      try {
        final dob = DateTime.parse(dateOfBirth);
        age = DateTime.now().year - dob.year;
      } catch (e) {
        age = 0;
      }
    }

    // Gender styling
    IconData genderIcon;
    List<Color> genderGradient;
    switch (gender.toLowerCase()) {
      case 'male':
        genderIcon = Icons.male_rounded;
        genderGradient = [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
        break;
      case 'female':
        genderIcon = Icons.female_rounded;
        genderGradient = [const Color(0xFFEC4899), const Color(0xFFDB2777)];
        break;
      default:
        genderIcon = Icons.person_rounded;
        genderGradient = [const Color(0xFF6B7280), const Color(0xFF4B5563)];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: design.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: design.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditDependentPage(dependent: dep),
              ),
            );
            if (result == true) {
              _fetchDependents();
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Avatar with gradient
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: genderGradient,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: genderGradient[0].withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(genderIcon, color: Colors.white, size: 34),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: design.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Tags Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          // Relationship Tag
                          if (relationship.isNotEmpty)
                            _buildTag(_getLocalRelation(context, relationship), design.primaryGreen),
                          // Age Tag
                          if (age > 0) _buildTag('$age ${l10n.years}', Colors.blue),
                        ],
                      ),

                      // Phone
                      if (mobile.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color: design.textSecondary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mobile,
                              style: TextStyle(
                                fontSize: 13,
                                color: design.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow with container
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: design.arrowBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: design.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalRelation(BuildContext context, String rel) {
    final l10n = AppLocalizations.of(context)!;
    switch (rel.toLowerCase()) {
      case 'father':
        return l10n.relationshipFather;
      case 'mother':
        return l10n.relationshipMother;
      case 'son':
        return l10n.relationshipSon;
      case 'daughter':
        return l10n.relationshipDaughter;
      case 'brother':
        return l10n.relationshipBrother;
      case 'sister':
        return l10n.relationshipSister;
      case 'grandparent':
        return l10n.relationshipGrandparent;
      case 'grandchild':
        return l10n.relationshipGrandchild;
      case 'spouse':
        return l10n.relationshipSpouse;
      case 'other':
        return l10n.relationshipOther;
      default:
        return rel.isEmpty
            ? ''
            : '${rel[0].toUpperCase()}${rel.substring(1).toLowerCase()}';
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
