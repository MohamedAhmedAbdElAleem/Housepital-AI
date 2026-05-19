import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/doctor_cubit.dart';
import '../cubit/clinic_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';

class ClinicFormPage extends StatefulWidget {
  final ClinicModel? clinicToEdit; // Added
  const ClinicFormPage({super.key, this.clinicToEdit});

  @override
  State<ClinicFormPage> createState() => _ClinicFormPageState();
}

class _ClinicFormPageState extends State<ClinicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;
  bool _isPickingImage = false;
  String _uploadProgressText = '';
  double _uploadProgressValue = 0.0;

  // Fields and Setup (Same as before)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _existingClinicImages = []; // URLs
  final List<File> _clinicImages = []; // New Files

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  final List<String> _days = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];
  final Map<String, WorkingHour> _workingHoursMap = {};
  String _bookingMode = 'slots';
  final _slotDurationController = TextEditingController(text: '30'.tr());
  int _maxPatients = 1;

  final List<String> _existingDocs = []; // URLs
  final List<File> _ownershipDocs = []; // New Files
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize default hours first
    for (var day in _days) {
      _workingHoursMap[day] = WorkingHour(
        day: day,
        isOpen: false,
        openTime: '09:00',
        closeTime: '17:00',
      );
    }

    // Pre-fill if editing
    if (widget.clinicToEdit != null) {
      final clinic = widget.clinicToEdit!;
      _nameController.text = clinic.name;
      _phoneController.text = clinic.phone ?? '';
      _descriptionController.text = clinic.description ?? '';
      _streetController.text = clinic.address.street;
      _cityController.text = clinic.address.city;
      _stateController.text = clinic.address.state;
      _zipController.text = clinic.address.zipCode ?? '';

      _bookingMode = clinic.bookingMode;
      _slotDurationController.text = clinic.slotDurationMinutes.toString();
      _maxPatients = clinic.maxPatientsPerSlot;

      _existingClinicImages.addAll(clinic.images);
      _existingDocs.addAll(clinic.verificationDocuments);

      for (var wh in clinic.workingHours) {
        // Normalize day string case just in case
        String key = _days.firstWhere(
          (d) => d.toLowerCase() == wh.day.toLowerCase(),
          orElse: () => wh.day,
        );
        if (_workingHoursMap.containsKey(key)) {
          _workingHoursMap[key] = WorkingHour(
            day: key,
            isOpen: wh.isOpen,
            openTime: wh.openTime ?? '09:00',
            closeTime: wh.closeTime ?? '17:00',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _slotDurationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickClinicImages() async => _pickImages(_clinicImages);
  Future<void> _pickOwnershipDocs() async => _pickImages(_ownershipDocs);

  Future<File> _saveFileToSafeLocation(String originalPath) async {
    final originalFile = File(originalPath);
    final ext = originalPath.contains('.') ? originalPath.split('.').last : 'tmp';
    final appDir = await getApplicationDocumentsDirectory();
    final newPath = '${appDir.path}/clinic_img_${DateTime.now().microsecondsSinceEpoch}.$ext';
    return await originalFile.copy(newPath);
  }

  Future<void> _pickImages(List<File> targetList) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        final List<File> safeFiles = [];
        for (var img in images) {
          final safeFile = await _saveFileToSafeLocation(img.path);
          safeFiles.add(safeFile);
        }
        setState(() {
          targetList.addAll(safeFiles);
        });
      }
    } catch (e) {
      // PlatformException(already_active) or user cancelled — ignore silently
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removeImage(List<File> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clinicImages.isEmpty && _existingClinicImages.isEmpty) {
      _showError('please_add_at_least_one_clinic_image'.tr());
      return;
    }
    if (_ownershipDocs.isEmpty && _existingDocs.isEmpty) {
      _showError('please_upload_ownership_proof_documents'.tr());
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgressText = 'preparing_files'.tr();
      _uploadProgressValue = 0.05;
    });

    // Capture cubits BEFORE any await
    final doctorCubit = context.read<DoctorCubit>();
    final clinicCubit = context.read<ClinicCubit>();

    try {
      final userId = await TokenManager.getUserId();

      final totalItems = _clinicImages.length + _ownershipDocs.length;
      int processed = 0;

      void updateProgress(String msg) {
        if (mounted) {
          setState(() {
            _uploadProgressText = msg;
            _uploadProgressValue =
                (processed + 1) / (totalItems + 2); // +2 for saving steps
          });
        }
      }

      // 1. Upload New Clinic Images
      List<String> newClinicUrls = [];
      for (int i = 0; i < _clinicImages.length; i++) {
        updateProgress('Uploading Photo ${i + 1}');
        final url = await doctorCubit.uploadImage(_clinicImages[i]);
        newClinicUrls.add(url);
        processed++;
      }
      final allClinicImages = [..._existingClinicImages, ...newClinicUrls];

      // 2. Upload New Ownership Docs
      List<String> newDocUrls = [];
      for (int i = 0; i < _ownershipDocs.length; i++) {
        updateProgress('Verifying Document ${i + 1}');
        final url = await doctorCubit.uploadImage(_ownershipDocs[i]);
        newDocUrls.add(url);
        processed++;
      }
      final allDocImages = [..._existingDocs, ...newDocUrls];

      // 3. Prepare Data
      setState(() {
        _uploadProgressText = 'Finalizing...';
        _uploadProgressValue = 0.95;
      });

      final address = ClinicAddress(
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text.isNotEmpty ? _zipController.text : null,
      );

      final workingHours =
          _workingHoursMap.values
              .where((d) => d.isOpen)
              .map(
                (e) => WorkingHour(
                  day: e.day.toLowerCase(),
                  isOpen: e.isOpen,
                  openTime: e.openTime,
                  closeTime: e.closeTime,
                  breakStart: e.breakStart,
                  breakEnd: e.breakEnd,
                ),
              )
              .toList();

      final slotDuration = int.tryParse(_slotDurationController.text) ?? 30;

      final clinicData = ClinicModel(
        id: widget.clinicToEdit?.id,
        doctorId: userId ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        phone: _phoneController.text,
        address: address,
        images: allClinicImages,
        workingHours: workingHours,
        slotDurationMinutes: slotDuration,
        maxPatientsPerSlot: _maxPatients,
        bookingMode: _bookingMode,
        verificationDocuments: allDocImages,
        verificationStatus:
            widget.clinicToEdit?.verificationStatus ?? 'pending',
        isActive: widget.clinicToEdit?.isActive ?? true,
      );

      // 4. Submit (Add or Update)
      if (widget.clinicToEdit != null) {
        await clinicCubit.updateClinic(clinicData);
      } else {
        await clinicCubit.addClinic(clinicData);
      }

      setState(() {
        _uploadProgressValue = 1.0;
        _uploadProgressText = 'Success!';
      });
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Show success briefly

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.clinicToEdit != null
                  ? 'clinic_updated_successfully'.tr()
                  : 'clinic_created_successfully'.tr(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: DoctorTheme.background(context),
          body: BackgroundBlobs(
            child: SafeArea(
              child: Column(
                children: [
                  GlassHeader(
                    title: widget.clinicToEdit != null ? 'edit_clinic_setup'.tr() : 'new_clinic_setup'.tr(),
                    subtitle: widget.clinicToEdit != null ? 'update_your_clinic_parameters'.tr() : 'setup_your_new_clinic_location'.tr(),
                    onBack: _prevStep,
                  ),
                  _buildStepWizard(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStepContainer(
                            _buildStep1BasicInfo(),
                            'basic_information'.tr(),
                            widget.clinicToEdit != null
                                ? 'update_your_clinic_basic_details'.tr()
                                : 'tell_us_about_your_clinic'.tr(),
                          ),
                          _buildStepContainer(
                            _buildStep2Location(),
                            'Location',
                            'where_can_patients_find_you'.tr(),
                          ),
                          _buildStepContainer(
                            _buildStep3Config(),
                            'Configuration',
                            'set_up_schedules_booking'.tr(),
                          ),
                          _buildStepContainer(
                            _buildStep4Docs(),
                            'Verification',
                            widget.clinicToEdit != null
                                ? 'update_legal_documents_if_needed'.tr()
                                : 'upload_legal_documents'.tr(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ),
        ),

        // --- Premium Loading Overlay (Redesigned) ---
        if (_isSubmitting)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: DoctorTheme.textPrimary(context).withValues(
                  alpha: 0.4,
                ), // Slightly darker for contrast
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.9, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: DoctorTheme.surface(context),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: DoctorTheme.textPrimary(context).withValues(alpha: 0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Circular Progress Indicator
                                SizedBox(
                                  width: 110, // Larger size
                                  height: 110,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Background ring (More visible)
                                      Container(
                                        width: 110,
                                        height: 110,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 8,
                                          ),
                                        ),
                                      ),
                                      // Gradient Progress
                                      // Gradient Progress (Custom Painter)
                                      // Gradient Progress (Animated & Custom Painter)
                                      TweenAnimationBuilder<double>(
                                        tween: Tween<double>(
                                          begin: 0.0,
                                          end: _uploadProgressValue,
                                        ),
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ), // Smooth "filling" effect
                                        curve: Curves.fastOutSlowIn,
                                        builder: (context, value, _) {
                                          return CustomPaint(
                                            size: const Size(110, 110),
                                            painter:
                                                GradientCircularProgressPainter(
                                                  progress:
                                                      value, // Use animated value
                                                  strokeWidth: 8,
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF2196F3),
                                                          Color(0xFF00BCD4),
                                                          Color(0xFF9C27B0),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                ),
                                          );
                                        },
                                      ),

                                      // Animated Icon
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        transitionBuilder:
                                            (child, anim) => ScaleTransition(
                                              scale: anim,
                                              child: child,
                                            ),
                                        child:
                                            _uploadProgressValue >= 1.0
                                                ? Container(
                                                  key: const ValueKey('done'),
                                                  decoration:
                                                      BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors
                                                                    .greenAccent,
                                                            blurRadius: 15,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                  padding: EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 40,
                                                    color: DoctorTheme.surface(context),
                                                  ),
                                                )
                                                : Icon(
                                                  Icons.cloud_upload_rounded,
                                                  key: const ValueKey('upload'),
                                                  size: 45,
                                                  color: Colors.blue[300],
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Main Title
                                Text(
                                  _uploadProgressValue >= 1.0
                                      ? (widget.clinicToEdit != null
                                          ? 'update_completed'.tr()
                                          : 'Completed!')
                                      : 'Processing...',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                    decoration:
                                        TextDecoration
                                            .none, // Explicit fix for yellow lines
                                  ),
                                ),

                                SizedBox(height: 12),

                                // Detail Text (Improved Typography)
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _uploadProgressText,
                                    key: ValueKey<String>(_uploadProgressText),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4, // Better line height
                                      color:
                                          Colors
                                              .grey[700], // Darker grey for readability
                                      fontWeight: FontWeight.w500,
                                      decoration:
                                          TextDecoration
                                              .none, // Explicit fix for yellow lines
                                    ),
                                  ),
                                ),

                                /* 
                              SizedBox(height: 16),
                              // Optional: Percentage Text if needed
                              Text(
                                '${(_uploadProgressValue * 100).toInt()}%',
                                style: TextStyle(color: Colors.blue[300], fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              */
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStepWizard() {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
      child: Row(
        children: [
          _buildStepCircle(0, Icons.info_outline),
          _buildStepLine(0),
          _buildStepCircle(1, Icons.location_on_outlined),
          _buildStepLine(1),
          _buildStepCircle(2, Icons.settings_outlined),
          _buildStepLine(2),
          _buildStepCircle(3, Icons.verified_user_outlined),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepIndex, IconData icon) {
    bool isActive = _currentStep == stepIndex;
    bool isCompleted = _currentStep > stepIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color:
            isCompleted
                ? DoctorTheme.success
                : (isActive ? DoctorTheme.primary : DoctorTheme.surfaceDim(context)),
        shape: BoxShape.circle,
        border: Border.all(
          color:
              isCompleted
                  ? DoctorTheme.success
                  : (isActive ? DoctorTheme.primary : DoctorTheme.border(context)),
          width: 2,
        ),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: DoctorTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
                : [],
      ),
      child: Center(
        child: Icon(
          isCompleted ? Icons.check : icon,
          color: isCompleted || isActive ? Colors.white : DoctorTheme.textHint(context),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStepLine(int index) {
    bool isCompleted = _currentStep > index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2,
        color: isCompleted ? DoctorTheme.success : DoctorTheme.border(context),
      ),
    );
  }

  Widget _buildStepContainer(Widget content, String title, String subtitle) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DoctorTheme.headingLarge(context),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: DoctorTheme.bodyMedium(context),
          ),
          SizedBox(height: 24),
          content,
        ],
      ),
    );
  }

  // --- Step 1 ---
  Widget _buildStep1BasicInfo() {
    return Column(
      children: [
        _buildCustomTextField(
          _nameController,
          'clinic_name'.tr(),
          Icons.local_hospital,
        ),
        SizedBox(height: 16),
        _buildCustomTextField(
          _phoneController,
          'phone_number'.tr(),
          Icons.phone,
          inputType: TextInputType.phone,
          validator: (val) {
            if (val == null || val.isEmpty) return 'Required';
            // normalise then validate against Egyptian mobile regex
            String p = val.trim().replaceAll(' ', '');
            if (p.startsWith('+20')) p = '0${p.substring(3)}';
            if (p.startsWith('0020')) p = '0${p.substring(4)}';
            final reg = RegExp(r'^01[0125][0-9]{8}$');
            if (!reg.hasMatch(p)) {
              return 'enter_a_valid_egyptian_number_e_g_01012345678'.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16),
        _buildCustomTextField(
          _descriptionController,
          'Description',
          Icons.notes,
          maxLines: 3,
        ),
        SizedBox(height: 24),
        _buildImageUploadCard(
          'clinic_photos'.tr(),
          _clinicImages,
          _pickClinicImages,
          existingImages: _existingClinicImages,
          onRemoveExisting:
              (index) => setState(() => _existingClinicImages.removeAt(index)),
        ),
      ],
    );
  }

  // --- Step 2 ---
  Widget _buildStep2Location() {
    return Column(
      children: [
        _buildCustomTextField(
          _streetController,
          'street_address'.tr(),
          Icons.location_on,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                _cityController,
                'City',
                Icons.location_city,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                _stateController,
                'State',
                Icons.map,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildCustomTextField(
          _zipController,
          'zip_code'.tr(),
          Icons.pin_drop,
          isRequired: false,
        ),
      ],
    );
  }

  // --- Step 3 ---
  Widget _buildStep3Config() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_mode'.tr(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                'time_slots'.tr(),
                'defined_periods'.tr(),
                Icons.calendar_today,
                'slots',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildSelectableCard(
                'Queue',
                'first_come_first_served'.tr(),
                Icons.people_outline,
                'queue',
              ),
            ),
          ],
        ),
        if (_bookingMode == 'slots') ...[
          SizedBox(height: 24),
          Text('slot_duration_minutes'.tr(), style: DoctorTheme.titleMedium(context)),
          SizedBox(height: 12),
          _buildCustomTextField(
            _slotDurationController,
            'Duration',
            Icons.timer,
            inputType: TextInputType.number,
            suffix: 'min',
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                [10, 15, 20, 30, 45, 60].map((val) {
                  return ActionChip(
                    label: Text('$val min'),
                    backgroundColor: Colors.blue[50],
                    onPressed: () {
                      setState(() {
                        _slotDurationController.text = val.toString();
                      });
                    },
                  );
                }).toList(),
          ),
        ],
        SizedBox(height: 24),
        Text('working_hours'.tr(), style: DoctorTheme.titleMedium(context)),
        SizedBox(height: 12),
        ..._days.map((day) => _buildDayTile(day)),
      ],
    );
  }

  // --- Step 4 ---
  Widget _buildStep4Docs() {
    return Column(
      children: [
        _buildImageUploadCard(
          'ownership_proof_rent_contract'.tr(),
          _ownershipDocs,
          _pickOwnershipDocs,
          subtitle: 'please_upload_a_valid_contract_or_utility_bill'.tr(),
          existingImages: _existingDocs,
          onRemoveExisting:
              (index) => setState(() => _existingDocs.removeAt(index)),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        boxShadow: DoctorTheme.softShadow(context),
      ),
      child: Row(
        children: [
          if (_currentStep == 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: DoctorTheme.border(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'cancel'.tr(),
                  style: TextStyle(color: DoctorTheme.textSecondary(context)),
                ),
              ),
            ),
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: DoctorTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('back'.tr(), style: TextStyle(color: DoctorTheme.primary)),
              ),
            ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: DoctorTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3
                    ? (widget.clinicToEdit != null
                        ? 'update_clinic'.tr()
                        : 'submit_clinic'.tr())
                    : 'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: DoctorTheme.textPrimary(context).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: DoctorTheme.inputDecoration(context, 
          label: label,
          icon: icon,
          hint: suffix, // Use hint for suffix occasionally or ignore
        ),
        validator:
            validator ??
            (isRequired
                ? (val) => (val == null || val.isEmpty) ? 'Required' : null
                : null),
      ),
    );
  }

  Widget _buildSelectableCard(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final isSelected = _bookingMode == value;
    return InkWell(
      onTap: () => setState(() => _bookingMode = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? DoctorTheme.primary.withValues(alpha: 0.05) : DoctorTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? DoctorTheme.primary : DoctorTheme.border(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected) DoctorTheme.cardShadow(context).first,
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? DoctorTheme.primary : DoctorTheme.textHint(context), size: 32),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? DoctorTheme.primaryDark : DoctorTheme.textPrimary(context),
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: DoctorTheme.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(
    String title,
    List<File> newImages,
    VoidCallback onAdd, {
    String? subtitle,
    List<String>? existingImages,
    Function(int)? onRemoveExisting,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: DoctorTheme.caption(context),
            ),
          ],
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Existing Images (Network)
                if (existingImages != null)
                  ...existingImages.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 12),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(entry.value),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: DoctorTheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        if (onRemoveExisting != null)
                          Positioned(
                            top: -4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onRemoveExisting(entry.key),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: DoctorTheme.surface(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: DoctorTheme.danger,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),

                // New Images (File)
                ...newImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 12),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(newImages, entry.key),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: DoctorTheme.surface(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: DoctorTheme.surfaceDim(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: DoctorTheme.border(context),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Icon(Icons.add_a_photo, color: DoctorTheme.textHint(context)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Updated Working Hours Tile ---
  Widget _buildDayTile(String day) {
    final wh = _workingHoursMap[day]!;
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wh.isOpen ? DoctorTheme.primary.withValues(alpha: 0.2) : DoctorTheme.border(context),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Switch(
                value: wh.isOpen,
                activeColor: DoctorTheme.primary,
                onChanged: (val) {
                  setState(() {
                    _workingHoursMap[day] = WorkingHour(
                      day: day,
                      isOpen: val,
                      openTime: wh.openTime,
                      closeTime: wh.closeTime,
                    );
                  });
                },
              ),
              Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: wh.isOpen ? DoctorTheme.primaryDark : DoctorTheme.textHint(context),
                ),
              ),
              const Spacer(),
              if (!wh.isOpen)
                Text('closed'.tr(), style: TextStyle(color: DoctorTheme.textHint(context))),
            ],
          ),
          if (wh.isOpen) ...[
            const Divider(height: 16),
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, day, isStart: true),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DoctorTheme.surfaceDim(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DoctorTheme.border(context)),
                      ),
                      child: Text(
                        wh.openTime ?? '09:00',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to'.tr()),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, day, isStart: false),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DoctorTheme.surfaceDim(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DoctorTheme.border(context)),
                      ),
                      child: Text(
                        wh.closeTime ?? '17:00',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.nightlight_round_outlined,
                  size: 16,
                  color: Colors.indigo,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Updated to support start/end distinction
  Future<void> _pickTime(
    BuildContext context,
    String day, {
    required bool isStart,
  }) async {
    final wh = _workingHoursMap[day]!;
    // Parse current time to set initial time in picker
    final timeStr = (isStart ? wh.openTime : wh.closeTime) ?? "09:00";
    final parts = timeStr.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _workingHoursMap[day] = WorkingHour(
          day: day,
          isOpen: true,
          openTime: isStart ? formatted : wh.openTime,
          closeTime: !isStart ? formatted : wh.closeTime,
        );
      });
    }
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double strokeWidth;

  GradientCircularProgressPainter({
    required this.progress,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track (optional, if we want it part of this or separate)
    // We already have a Container for background, so we just draw progress.

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = gradient.createShader(
            Rect.fromCircle(center: center, radius: radius),
          );

    // -pi/2 to start from top
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
