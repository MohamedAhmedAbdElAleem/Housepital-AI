import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/widgets/custom_popup.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';

class MedicalHistoryPage extends StatefulWidget {
  final String email;

  const MedicalHistoryPage({super.key, required this.email});

  @override
  State<MedicalHistoryPage> createState() => _MedicalHistoryPageState();
}

class _MedicalHistoryPageState extends State<MedicalHistoryPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Repository
  late final ProfileRepositoryImpl _profileRepository;
  bool _isLoading = false;

  // Blood types
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  String? _selectedBloodType;

  // Chronic diseases
  final Map<String, bool> _chronicDiseases = {
    'Diabetes': false,
    'High Blood Pressure': false,
    'Heart Disease': false,
    'Asthma': false,
    'Kidney Disease': false,
    'Liver Disease': false,
    'Cancer': false,
    'Thyroid Disorder': false,
    'Arthritis': false,
    'Epilepsy': false,
  };

  // Allergies
  final Map<String, bool> _allergies = {
    'Penicillin': false,
    'Sulfa Drugs': false,
    'Aspirin': false,
    'Ibuprofen': false,
    'Latex': false,
    'Peanuts': false,
    'Shellfish': false,
    'Eggs': false,
  };

  // Other fields
  final _otherConditionsController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  bool _hasNoChronicDiseases = false;
  bool _hasNoAllergies = false;

  @override
  void initState() {
    super.initState();
    _initRepository();
    _initAnimations();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initRepository() {
    final apiService = ApiService();
    final remoteDataSource = ProfileRemoteDataSourceImpl(
      apiService: apiService,
    );
    _profileRepository = ProfileRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
  }

  void _initAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _otherConditionsController.dispose();
    _currentMedicationsController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    try {
      // Save medical info to backend
      await _profileRepository.updateMedicalInfo(
        bloodType: _selectedBloodType,
        chronicDiseases:
            _chronicDiseases.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList(),
        allergies:
            _allergies.entries.where((e) => e.value).map((e) => e.key).toList(),
        otherConditions: _otherConditionsController.text.trim(),
        currentMedications: _currentMedicationsController.text.trim(),
        hasNoChronicDiseases: _hasNoChronicDiseases,
        hasNoAllergies: _hasNoAllergies,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to ID verification
        Navigator.pushNamed(
          context,
          AppRoutes.verifyIdentity,
          arguments: {'email': widget.email},
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Still navigate even if save fails (data is optional)
        CustomPopup.warning(
          context,
          'Could not save medical info. You can update it later.',
        );
        Navigator.pushNamed(
          context,
          AppRoutes.verifyIdentity,
          arguments: {'email': widget.email},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(size),

          // Main Content
          SafeArea(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Column(
                      children: [
                        // Custom App Bar
                        _buildAppBar(),

                        // Progress Indicator
                        _buildProgressIndicator(),

                        // Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),

                                // Header
                                _buildHeader(),

                                const SizedBox(height: 32),

                                // Blood Type Section
                                _buildBloodTypeSection(),

                                const SizedBox(height: 32),

                                // Chronic Diseases Section
                                _buildChronicDiseasesSection(),

                                const SizedBox(height: 32),

                                // Allergies Section
                                _buildAllergiesSection(),

                                const SizedBox(height: 32),

                                // Other Conditions
                                _buildOtherConditionsSection(),

                                const SizedBox(height: 32),

                                // Current Medications
                                _buildCurrentMedicationsSection(),

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top gradient
            Container(
              height: size.height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary500,
                    AppColors.primary400,
                    AppColors.primary300.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Floating medical icons
            ..._buildFloatingIcons(size),

            // Bottom curve - positioned below the progress indicator
            Positioned(
              top: size.height * 0.22,
              left: 0,
              right: 0,
              child: Container(
                height: size.height * 0.78,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingIcons(Size size) {
    final icons = [
      Icons.favorite_rounded,
      Icons.medical_services_rounded,
      Icons.healing_rounded,
      Icons.local_hospital_rounded,
      Icons.monitor_heart_rounded,
    ];

    return List.generate(icons.length, (index) {
      final progress = (_floatingController.value + index * 0.2) % 1.0;
      final x = math.sin(progress * math.pi * 2 + index) * 30;
      final y = math.cos(progress * math.pi * 2 + index) * 20;

      return Positioned(
        top: 80 + index * 25.0 + y,
        left: (size.width / (icons.length + 1)) * (index + 1) - 15 + x,
        child: Opacity(
          opacity: 0.15,
          child: Icon(
            icons[index],
            size: 30 + (index % 3) * 10.0,
            color: Colors.white,
          ),
        ),
      );
    });
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const Expanded(
            child: Text(
              'Medical History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Skip Button
          TextButton(
            onPressed: _handleContinue,
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: [
              _buildStepDot(1, true, 'Info'),
              _buildStepLine(true),
              _buildStepDot(2, true, 'Medical'),
              _buildStepLine(false),
              _buildStepDot(3, false, 'ID'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, bool isActive, String label) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale =
                isActive && step == 2
                    ? 1.0 + (_pulseController.value * 0.1)
                    : 1.0;

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow:
                      isActive
                          ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child:
                      isActive && step < 2
                          ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primary500,
                            size: 20,
                          )
                          : Text(
                            '$step',
                            style: TextStyle(
                              color:
                                  isActive
                                      ? AppColors.primary500
                                      : Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                color: AppColors.primary500,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Help us provide better care for you',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.info200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.info500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This information helps our medical team prepare better for your visits and ensures your safety.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.info700,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Blood Type', Icons.bloodtype_rounded),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _bloodTypes.map((type) {
                final isSelected = _selectedBloodType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedBloodType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: (MediaQuery.of(context).size.width - 48 - 36) / 4,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary500
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary500
                                : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary500.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          color:
                              isSelected ? Colors.white : Colors.red.shade300,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildChronicDiseasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Chronic Diseases', Icons.healing_rounded),
        const SizedBox(height: 16),

        // No chronic diseases checkbox
        _buildCheckboxTile(
          'I don\'t have any chronic diseases',
          _hasNoChronicDiseases,
          (value) {
            setState(() {
              _hasNoChronicDiseases = value ?? false;
              if (_hasNoChronicDiseases) {
                _chronicDiseases.updateAll((key, value) => false);
              }
            });
          },
          isSpecial: true,
        ),

        const SizedBox(height: 12),

        // Disease chips
        AnimatedOpacity(
          opacity: _hasNoChronicDiseases ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: _hasNoChronicDiseases,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _chronicDiseases.entries.map((entry) {
                    return _buildSelectableChip(entry.key, entry.value, (
                      selected,
                    ) {
                      setState(() {
                        _chronicDiseases[entry.key] = selected;
                        if (selected) _hasNoChronicDiseases = false;
                      });
                    }, _getDiseaseIcon(entry.key));
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Allergies', Icons.warning_amber_rounded),
        const SizedBox(height: 16),

        // No allergies checkbox
        _buildCheckboxTile(
          'I don\'t have any known allergies',
          _hasNoAllergies,
          (value) {
            setState(() {
              _hasNoAllergies = value ?? false;
              if (_hasNoAllergies) {
                _allergies.updateAll((key, value) => false);
              }
            });
          },
          isSpecial: true,
        ),

        const SizedBox(height: 12),

        // Allergy chips
        AnimatedOpacity(
          opacity: _hasNoAllergies ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: _hasNoAllergies,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _allergies.entries.map((entry) {
                    return _buildSelectableChip(entry.key, entry.value, (
                      selected,
                    ) {
                      setState(() {
                        _allergies[entry.key] = selected;
                        if (selected) _hasNoAllergies = false;
                      });
                    }, Icons.do_not_disturb_alt_rounded);
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherConditionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Other Medical Conditions', Icons.edit_note_rounded),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _otherConditionsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe any other medical conditions...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Current Medications', Icons.medication_rounded),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _currentMedicationsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'List any medications you are currently taking...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary500, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(Optional)',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged, {
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              value
                  ? AppColors.success500.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? AppColors.success500 : Colors.grey.shade200,
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? AppColors.success500 : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.success500 : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child:
                  value
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                  color: value ? AppColors.success700 : Colors.black87,
                ),
              ),
            ),
            if (value)
              const Icon(
                Icons.verified_rounded,
                color: AppColors.success500,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary500.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary500 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary500 : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary700 : Colors.black87,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primary500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getDiseaseIcon(String disease) {
    switch (disease) {
      case 'Diabetes':
        return Icons.bloodtype_rounded;
      case 'High Blood Pressure':
        return Icons.monitor_heart_rounded;
      case 'Heart Disease':
        return Icons.favorite_rounded;
      case 'Asthma':
        return Icons.air_rounded;
      case 'Kidney Disease':
        return Icons.water_drop_rounded;
      case 'Liver Disease':
        return Icons.medical_services_rounded;
      case 'Cancer':
        return Icons.coronavirus_rounded;
      case 'Thyroid Disorder':
        return Icons.waves_rounded;
      case 'Arthritis':
        return Icons.accessibility_new_rounded;
      case 'Epilepsy':
        return Icons.psychology_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary300,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppColors.primary500.withValues(alpha: 0.4),
            ),
            child:
                _isLoading
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
