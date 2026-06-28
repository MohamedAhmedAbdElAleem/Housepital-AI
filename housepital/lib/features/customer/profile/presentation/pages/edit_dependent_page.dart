import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:housepital/generated/l10n/app_localizations.dart';
import '../../../../../core/network/api_service.dart';
import 'package:housepital/core/widgets/custom_popup.dart';

class _DependentDesign {
  final BuildContext context;
  _DependentDesign(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get primaryGreen => const Color(0xFF00C853);
  Color get surface => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? Colors.white70 : const Color(0xFF64748B);
  Color get cardBg => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get dangerRed => const Color(0xFFEF4444);

  LinearGradient get headerGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16151A), Color(0xFF0D0C10)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C853), Color(0xFF00E676), Color(0xFF69F0AE)],
        );

  BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withAlpha(isDark ? 100 : 15),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  BoxShadow get softShadow => BoxShadow(
        color: primaryGreen.withOpacity(isDark ? 0.05 : 0.15),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );
}

class EditDependentPage extends StatefulWidget {
  final Map<String, dynamic> dependent;

  const EditDependentPage({super.key, required this.dependent});

  @override
  State<EditDependentPage> createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _birthCertificateIdController = TextEditingController();

  String? _selectedRelationship;
  String _selectedGender = 'male';
  DateTime? _selectedDate;
  final List<String> _chronicDiseases = [];
  final List<String> _allergies = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _relationships = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Grandparent',
    'Grandchild',
    'Spouse',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    _setupListeners();
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

  void _setupListeners() {
    _fullNameController.addListener(_onFieldChanged);
    _mobileController.addListener(_onFieldChanged);
    _nationalIdController.addListener(_onFieldChanged);
    _birthCertificateIdController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _initializeData() {
    final dep = widget.dependent;
    _fullNameController.text = dep['fullName'] ?? '';
    _mobileController.text = dep['mobile'] ?? '';
    _nationalIdController.text = dep['nationalId'] ?? '';
    _birthCertificateIdController.text = dep['birthCertificateId'] ?? '';
    _selectedGender = dep['gender'] ?? 'male';

    final rel = dep['relationship'] as String?;
    if (rel != null && rel.isNotEmpty) {
      final formattedRel = _capitalizeFirst(rel);
      if (!_relationships.contains(formattedRel)) {
        _relationships.add(formattedRel);
      }
      _selectedRelationship = formattedRel;
    }

    final dob = dep['dateOfBirth'];
    if (dob != null) {
      _selectedDate = DateTime.tryParse(dob);
    }

    if (dep['chronicConditions'] != null) {
      _chronicDiseases.addAll(List<String>.from(dep['chronicConditions']));
    }
    if (dep['allergies'] != null) {
      _allergies.addAll(List<String>.from(dep['allergies']));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _nationalIdController.dispose();
    _birthCertificateIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final design = _DependentDesign(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: design.primaryGreen,
              onPrimary: Colors.white,
              surface: design.cardBg,
              onSurface: design.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: design.cardBg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
      });
    }
  }

  void _addChronicDisease() {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    _showAddDialog(
      title: l10n.addChronicCondition,
      hint: l10n.addChronicDiseaseHint,
      icon: Icons.medication_outlined,
      color: Colors.orange,
      onAdd:
          (value) => setState(() {
            _chronicDiseases.add(value);
            _hasChanges = true;
          }),
    );
  }

  void _addAllergy() {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context)!;
    _showAddDialog(
      title: l10n.addAllergy,
      hint: l10n.addAllergyHint,
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      onAdd:
          (value) => setState(() {
            _allergies.add(value);
            _hasChanges = true;
          }),
    );
  }

  void _showAddDialog({
    required String title,
    required String hint,
    required IconData icon,
    required Color color,
    required Function(String) onAdd,
  }) {
    final controller = TextEditingController();
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: design.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
              ],
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: design.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: design.textSecondary.withOpacity(0.6)),
                filled: true,
                fillColor: design.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: design.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    onAdd(controller.text.trim());
                    Navigator.pop(context);
                    HapticFeedback.mediumImpact();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(l10n.add),
              ),
            ],
          ),
    );
  }

  Future<void> _updateDependent() async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedRelationship == null) {
      CustomPopup.warning(context, l10n.selectRelationshipWarn);
      return;
    }

    if (_selectedDate == null) {
      CustomPopup.warning(context, l10n.selectDobWarn);
      return;
    }

    if (_nationalIdController.text.trim().isEmpty &&
        _birthCertificateIdController.text.trim().isEmpty) {
      CustomPopup.warning(
        context,
        l10n.provideIdWarn,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/updateDependent',
        body: {
          'id': widget.dependent['_id'],
          'fullName': _fullNameController.text.trim(),
          'relationship': _selectedRelationship!.toLowerCase(),
          'dateOfBirth': _selectedDate!.toIso8601String().substring(0, 10),
          'gender': _selectedGender,
          'mobile': _mobileController.text.trim(),
          'chronicConditions': _chronicDiseases,
          'allergies': _allergies,
          'nationalId': _nationalIdController.text.trim(),
          'birthCertificateId': _birthCertificateIdController.text.trim(),
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['success'] == true) {
          HapticFeedback.heavyImpact();
          _showSuccessDialog();
        } else {
          CustomPopup.error(
            context,
            response['message'] ?? l10n.errUpdateAddress,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomPopup.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteDependent() async {
    HapticFeedback.heavyImpact();
    final designD = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: designD.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: designD.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: designD.dangerRed,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.deleteMember,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: designD.textPrimary,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteMemberConfirm(_fullNameController.text),
                  style: TextStyle(
                    fontSize: 15,
                    color: designD.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: designD.dangerRed.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: designD.dangerRed.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: designD.dangerRed.withOpacity(0.7),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.actionUndone,
                          style: TextStyle(
                            fontSize: 13,
                            color: designD.dangerRed,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: designD.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: designD.dangerRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(l10n.delete),
                  ],
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.delete(
        '/api/user/deleteDependent?id=${widget.dependent['_id']}',
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['success'] == true) {
          HapticFeedback.heavyImpact();
          CustomPopup.success(context, l10n.deleteMemberSuccess);
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true);
        } else {
          CustomPopup.error(
            context,
            response['message'] ?? 'Failed to delete member',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomPopup.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _showSuccessDialog() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: design.cardBg,
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
                    gradient: design.headerGradient,
                    shape: BoxShape.circle,
                    boxShadow: [design.softShadow],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.changesSaved,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.familyMemberUpdated,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: design.textSecondary),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: design.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.done,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDiscardDialog() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    HapticFeedback.lightImpact();
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: design.cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.discardChangesTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.discardChangesDesc,
              style: TextStyle(
                fontSize: 15,
                color: design.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.keepEditing,
                  style: TextStyle(color: design.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: design.dangerRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(l10n.discard),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = _DependentDesign(context);
    return Scaffold(
      backgroundColor: design.surface,
      body: Form(
        key: _formKey,
        child: Column(
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
                        _buildBasicInfoCard(),
                        const SizedBox(height: 20),
                        _buildIdentificationCard(),
                        const SizedBox(height: 20),
                        _buildMedicalInfoCard(),
                        const SizedBox(height: 20),
                        _buildDangerZone(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: design.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [design.softShadow],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _showDiscardDialog,
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
                  Expanded(
                    child: Text(
                      l10n.editFamilyMember,
                      style: const TextStyle(
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient:
                            _selectedGender == 'male'
                                ? const LinearGradient(
                                  colors: [
                                    Color(0xFF42A5F5),
                                    Color(0xFF1976D2),
                                  ],
                                )
                                : const LinearGradient(
                                  colors: [
                                    Color(0xFFF48FB1),
                                    Color(0xFFE91E63),
                                  ],
                                ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        _selectedGender == 'male' ? Icons.face : Icons.face_3,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fullNameController.text.isNotEmpty
                                ? _fullNameController.text
                                : l10n.addFamilyMember,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
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
                                  _selectedRelationship != null
                                      ? _getLocalRelationship(context, _selectedRelationship!)
                                      : l10n.relationship,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (_hasChanges) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.modified,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
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

  Widget _buildBasicInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.basicInformation,
      icon: Icons.person_outline_rounded,
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: l10n.fullName,
          icon: Icons.badge_outlined,
          validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
        ),
        const SizedBox(height: 16),
        _buildDropdown(),
        const SizedBox(height: 16),
        _buildGenderSelector(),
        const SizedBox(height: 16),
        _buildDatePicker(),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _mobileController,
          label: l10n.mobileNumberOptional,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildIdentificationCard() {
    final l10n = AppLocalizations.of(context)!;
    final design = _DependentDesign(context);
    return _buildCard(
      title: l10n.identification,
      icon: Icons.credit_card_outlined,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.provideOneId,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.amber[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalIdController,
          label: l10n.nationalId,
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 14,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _birthCertificateIdController,
          label: l10n.birthCertificateId,
          icon: Icons.description_outlined,
          keyboardType: TextInputType.number,
          maxLength: 20,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.medicalInformation,
      icon: Icons.medical_information_outlined,
      children: [
        _buildChipSection(
          title: l10n.chronicConditions,
          items: _chronicDiseases,
          onAdd: _addChronicDisease,
          onRemove:
              (i) => setState(() {
                _chronicDiseases.removeAt(i);
                _hasChanges = true;
              }),
          color: Colors.orange,
          icon: Icons.medication_outlined,
        ),
        const SizedBox(height: 20),
        _buildChipSection(
          title: l10n.allergies,
          items: _allergies,
          onAdd: _addAllergy,
          onRemove:
              (i) => setState(() {
                _allergies.removeAt(i);
                _hasChanges = true;
              }),
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: design.dangerRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: design.dangerRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: design.dangerRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: design.dangerRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                l10n.dangerZone,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: design.dangerRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deleteFamilyMemberDesc,
            style: TextStyle(fontSize: 13, color: design.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteDependent,
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              label: Text(l10n.deleteFamilyMember),
              style: OutlinedButton.styleFrom(
                foregroundColor: design.dangerRed,
                side: BorderSide(color: design.dangerRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final design = _DependentDesign(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: design.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [design.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: design.headerGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: design.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    final design = _DependentDesign(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: TextStyle(fontSize: 16, color: design.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: design.textSecondary),
        prefixIcon: Icon(icon, color: design.primaryGreen),
        filled: true,
        fillColor: design.surface,
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: design.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: _selectedRelationship,
      decoration: InputDecoration(
        labelText: l10n.relationship,
        labelStyle: TextStyle(color: design.textSecondary),
        prefixIcon: const Icon(
          Icons.family_restroom,
        ),
        prefixIconColor: design.primaryGreen,
        filled: true,
        fillColor: design.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: design.primaryGreen,
            width: 2,
          ),
        ),
      ),
      dropdownColor: design.cardBg,
      borderRadius: BorderRadius.circular(14),
      items:
          _relationships
              .map((rel) => DropdownMenuItem(
                    value: rel,
                    child: Text(_getLocalRelationship(context, rel)),
                  ))
              .toList(),
      onChanged: (val) {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedRelationship = val;
          _hasChanges = true;
        });
      },
    );
  }

  Widget _buildGenderSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gender,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                l10n.male,
                'male',
                Icons.male,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildGenderOption(
                l10n.female,
                'female',
                Icons.female,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final design = _DependentDesign(context);
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedGender = value;
          _hasChanges = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  )
                  : null,
          color: isSelected ? null : design.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : design.inputBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : design.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : design.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: design.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                _selectedDate != null
                    ? design.primaryGreen
                    : design.inputBorder,
            width: _selectedDate != null ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: design.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.cake_outlined,
                color: design.primaryGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dateOfBirth,
                    style: TextStyle(fontSize: 12, color: design.textSecondary.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDate == null
                        ? l10n.selectDate
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedDate == null
                              ? design.textSecondary
                              : design.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: design.primaryGreen.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Color color,
    required IconData icon,
  }) {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: design.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_outline, size: 18, color: color),
              label: Text(l10n.add, style: TextStyle(color: color)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        items.isEmpty
            ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: color.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.noItemsAdded(title.toLowerCase()),
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
            : Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  items.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        HapticFeedback.lightImpact();
                        onRemove(entry.key);
                      },
                      backgroundColor: color.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIconColor: color,
                      side: BorderSide(color: color.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
            ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    final design = _DependentDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: design.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(design.isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || !_hasChanges ? null : _updateDependent,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasChanges
                      ? design.primaryGreen
                      : Colors.grey[400],
              foregroundColor: Colors.white,
              disabledBackgroundColor: design.isDark ? Colors.grey[800] : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasChanges
                              ? Icons.save_rounded
                              : Icons.check_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _hasChanges ? l10n.saveChanges : l10n.noChanges,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  String _getLocalRelationship(BuildContext context, String rel) {
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
      default:
        return l10n.relationshipOther;
    }
  }
}
