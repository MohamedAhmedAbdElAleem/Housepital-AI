import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/network/api_service.dart';
import 'package:housepital/core/widgets/custom_popup.dart';
import '../../../../../core/utils/token_manager.dart';

class _DependentDesign {
  final BuildContext context;
  _DependentDesign(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get primaryGreen => const Color(0xFF00C853);
  Color get surface => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? Colors.white70 : const Color(0xFF64748B);
  Color get cardBg => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get inputBorder => isDark ? Colors.white.withAlpha(20) : const Color(0xFFE2E8F0);
  Color get scaffoldBg => isDark ? Colors.black : const Color(0xFFF8FAFC);

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
        color: isDark ? Colors.black.withAlpha(80) : primaryGreen.withAlpha(38),
        blurRadius: 20,
        offset: const Offset(0, 8),
      );
}

class AddDependentPage extends StatefulWidget {
  const AddDependentPage({super.key});

  @override
  State<AddDependentPage> createState() => _AddDependentPageState();
}

class _AddDependentPageState extends State<AddDependentPage>
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
  String? _userId;

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
    _loadUserId();
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

  Future<void> _loadUserId() async {
    final userId = await TokenManager.getUserId();
    if (mounted) {
      setState(() => _userId = userId);
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
    final design = _DependentDesign(context);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
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
      setState(() => _selectedDate = picked);
    }
  }

  void _addChronicDisease() {
    HapticFeedback.lightImpact();
    _showAddDialog(
      title: 'Add Chronic Disease',
      hint: 'e.g., Diabetes, Hypertension',
      icon: Icons.medication_outlined,
      color: Colors.orange,
      onAdd: (value) => setState(() => _chronicDiseases.add(value)),
    );
  }

  void _addAllergy() {
    HapticFeedback.lightImpact();
    _showAddDialog(
      title: 'Add Allergy',
      hint: 'e.g., Penicillin, Peanuts',
      icon: Icons.warning_amber_rounded,
      color: Colors.red,
      onAdd: (value) => setState(() => _allergies.add(value)),
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
                  'Cancel',
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
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedRelationship == null) {
      CustomPopup.warning(context, 'Please select a relationship');
      return;
    }

    if (_selectedDate == null) {
      CustomPopup.warning(context, 'Please select date of birth');
      return;
    }

    if (_nationalIdController.text.trim().isEmpty &&
        _birthCertificateIdController.text.trim().isEmpty) {
      CustomPopup.warning(
        context,
        'Please provide either National ID or Birth Certificate ID',
      );
      return;
    }

    if (_userId == null || _userId!.isEmpty) {
      CustomPopup.error(context, 'User ID not found. Please log in again.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/user/addDependent',
        body: {
          'fullName': _fullNameController.text.trim(),
          'relationship': _selectedRelationship!.toLowerCase(),
          'dateOfBirth': _selectedDate!.toIso8601String().substring(0, 10),
          'gender': _selectedGender,
          'mobile': _mobileController.text.trim(),
          'chronicConditions': _chronicDiseases,
          'allergies': _allergies,
          'nationalId': _nationalIdController.text.trim(),
          'birthCertificateId': _birthCertificateIdController.text.trim(),
          'responsibleUser': _userId!,
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
            response['message'] ?? 'Failed to add member',
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
                  'Family Member Added!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The family member has been added successfully.',
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
                  child: const Text(
                    'Done',
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
    final design = _DependentDesign(context);
    return Scaffold(
      backgroundColor: design.scaffoldBg,
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
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final design = _DependentDesign(context);
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
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
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
                      'Add Family Member',
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Family Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fill in the details below to add a family member',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
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
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: 'Basic Information',
      icon: Icons.person_outline_rounded,
      children: [
        _buildTextField(
          controller: _fullNameController,
          label: 'Full Name',
          icon: Icons.badge_outlined,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
          label: 'Mobile Number (Optional)',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildIdentificationCard() {
    final design = _DependentDesign(context);
    return _buildCard(
      title: 'Identification',
      icon: Icons.credit_card_outlined,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(design.isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: design.isDark ? Colors.amber[400] : Colors.amber[800], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Provide at least one ID',
                  style: TextStyle(
                    fontSize: 13,
                    color: design.isDark ? Colors.amber[300] : Colors.amber[800],
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
          label: 'National ID',
          icon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
          maxLength: 14,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _birthCertificateIdController,
          label: 'Birth Certificate ID',
          icon: Icons.description_outlined,
          keyboardType: TextInputType.number,
          maxLength: 20,
        ),
      ],
    );
  }

  Widget _buildMedicalInfoCard() {
    return _buildCard(
      title: 'Medical Information',
      icon: Icons.medical_information_outlined,
      children: [
        _buildChipSection(
          title: 'Chronic Diseases',
          items: _chronicDiseases,
          onAdd: _addChronicDisease,
          onRemove: (i) => setState(() => _chronicDiseases.removeAt(i)),
          color: Colors.orange,
          icon: Icons.medication_outlined,
        ),
        const SizedBox(height: 20),
        _buildChipSection(
          title: 'Allergies',
          items: _allergies,
          onAdd: _addAllergy,
          onRemove: (i) => setState(() => _allergies.removeAt(i)),
          color: Colors.red,
          icon: Icons.warning_amber_rounded,
        ),
      ],
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
    return DropdownButtonFormField<String>(
      initialValue: _selectedRelationship,
      decoration: InputDecoration(
        labelText: 'Relationship',
        labelStyle: TextStyle(color: design.textSecondary),
        prefixIcon: Icon(
          Icons.family_restroom,
          color: design.primaryGreen,
        ),
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
                    child: Text(rel, style: TextStyle(color: design.textPrimary)),
                  ))
              .toList(),
      onChanged: (val) {
        HapticFeedback.selectionClick();
        setState(() => _selectedRelationship = val);
      },
    );
  }

  Widget _buildGenderSelector() {
    final design = _DependentDesign(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: design.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                'Male',
                'male',
                Icons.male,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildGenderOption(
                'Female',
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
        setState(() => _selectedGender = value);
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
                    'Date of Birth',
                    style: TextStyle(fontSize: 12, color: design.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDate == null
                        ? 'Select date'
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
              label: Text('Add', style: TextStyle(color: color)),
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
                  color: color.withOpacity(design.isDark ? 0.15 : 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(design.isDark ? 0.3 : 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18, color: color.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Text(
                      'No $title added',
                      style: TextStyle(
                        fontSize: 13,
                        color: design.isDark ? color.withOpacity(0.9) : color.withOpacity(0.7),
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
                        backgroundColor: color.withOpacity(design.isDark ? 0.18 : 0.1),
                        labelStyle: TextStyle(
                          color: design.isDark ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                        ),
                        deleteIconColor: design.isDark ? Colors.white70 : color,
                        side: BorderSide(color: color.withOpacity(design.isDark ? 0.4 : 0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
              ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final design = _DependentDesign(context);
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
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: design.primaryGreen,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_rounded, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Add Family Member',
                            style: TextStyle(
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
}
