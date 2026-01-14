import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/clinic_model.dart';
import '../cubit/doctor_cubit.dart';

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
  final _slotDurationController = TextEditingController(text: '30');
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
      _stateController.text = clinic.address.state ?? '';
      _zipController.text = clinic.address.zipCode ?? '';

      _bookingMode = clinic.bookingMode;
      _slotDurationController.text = clinic.slotDurationMinutes.toString();
      _maxPatients = clinic.maxPatientsPerSlot;

      _existingClinicImages.addAll(clinic.images);
      _existingDocs.addAll(clinic.verificationDocuments ?? []);

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

  Future<void> _pickImages(List<File> targetList) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        targetList.addAll(images.map((e) => File(e.path)));
      });
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
      _showError('Please add at least one clinic image');
      return;
    }
    if (_ownershipDocs.isEmpty && _existingDocs.isEmpty) {
      _showError('Please upload ownership proof documents');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgressText = 'Preparing files...';
      _uploadProgressValue = 0.05;
    });

    try {
      final cubit = context.read<DoctorCubit>();
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
        final url = await cubit.uploadImage(_clinicImages[i]);
        newClinicUrls.add(url);
        processed++;
      }
      final allClinicImages = [..._existingClinicImages, ...newClinicUrls];

      // 2. Upload New Ownership Docs
      List<String> newDocUrls = [];
      for (int i = 0; i < _ownershipDocs.length; i++) {
        updateProgress('Verifying Document ${i + 1}');
        final url = await cubit.uploadImage(_ownershipDocs[i]);
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

      final workingHours = _workingHoursMap.values
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
        await cubit.updateClinic(clinicData);
      } else {
        await cubit.addClinic(clinicData);
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
          const SnackBar(
            content: Text('Clinic Created Successfully!'),
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(onPressed: _prevStep, color: Colors.blue[900]),
            title: Text(
              'New Clinic Setup',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
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
                            'Basic Information',
                            'Tell us about your clinic',
                          ),
                          _buildStepContainer(
                            _buildStep2Location(),
                            'Location',
                            'Where can patients find you?',
                          ),
                          _buildStepContainer(
                            _buildStep3Config(),
                            'Configuration',
                            'Set up schedules & booking',
                          ),
                          _buildStepContainer(
                            _buildStep4Docs(),
                            'Verification',
                            'Upload legal documents',
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
                color: Colors.black.withOpacity(
                  0.4,
                ), // Slightly darker for contrast
                padding: const EdgeInsets.symmetric(horizontal: 32),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 32,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Progress Indicator "طرش" style
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
                                                        end: Alignment
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
                                        transitionBuilder: (child, anim) =>
                                            ScaleTransition(
                                              scale: anim,
                                              child: child,
                                            ),
                                        child: _uploadProgressValue >= 1.0
                                            ? Container(
                                                key: const ValueKey('done'),
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.greenAccent,
                                                      blurRadius: 15,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 40,
                                                  color: Colors.white,
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
                                const SizedBox(height: 24),

                                // Main Title
                                Text(
                                  _uploadProgressValue >= 1.0
                                      ? 'Completed!'
                                      : 'Processing...',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                    decoration: TextDecoration
                                        .none, // Explicit fix for yellow lines
                                  ),
                                ),

                                const SizedBox(height: 12),

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
                                      color: Colors
                                          .grey[700], // Darker grey for readability
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration
                                          .none, // Explicit fix for yellow lines
                                    ),
                                  ),
                                ),

                                /* 
                              const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(top: 16, bottom: 24, left: 24, right: 24),
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
        color: isCompleted
            ? Colors.green
            : (isActive ? Colors.blue : Colors.white),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted
              ? Colors.green
              : (isActive ? Colors.blue : Colors.grey[300]!),
          width: 2,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8)]
            : [],
      ),
      child: Center(
        child: Icon(
          isCompleted ? Icons.check : icon,
          color: isCompleted || isActive ? Colors.white : Colors.grey[400],
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
        color: isCompleted ? Colors.green : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepContainer(Widget content, String title, String subtitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
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
          'Clinic Name',
          Icons.local_hospital,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          _phoneController,
          'Phone Number',
          Icons.phone,
          inputType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          _descriptionController,
          'Description',
          Icons.notes,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        _buildImageUploadCard(
          'Clinic Photos',
          _clinicImages,
          _pickClinicImages,
          existingImages: _existingClinicImages,
          onRemoveExisting: (index) =>
              setState(() => _existingClinicImages.removeAt(index)),
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
          'Street Address',
          Icons.location_on,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCustomTextField(
                _cityController,
                'City',
                Icons.location_city,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCustomTextField(
                _stateController,
                'State',
                Icons.map,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          _zipController,
          'Zip Code',
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
        const Text(
          'Booking Mode',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSelectableCard(
                'Time Slots',
                'Defined periods',
                Icons.calendar_today,
                'slots',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectableCard(
                'Queue',
                'First come first served',
                Icons.people_outline,
                'queue',
              ),
            ),
          ],
        ),
        if (_bookingMode == 'slots') ...[
          const SizedBox(height: 24),
          const Text(
            'Slot Duration (Minutes)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          _buildCustomTextField(
            _slotDurationController,
            'Duration',
            Icons.timer,
            inputType: TextInputType.number,
            suffix: 'min',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [10, 15, 20, 30, 45, 60].map((val) {
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
        const SizedBox(height: 24),
        const Text(
          'Working Hours',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._days.map((day) => _buildDayTile(day)).toList(),
      ],
    );
  }

  // --- Step 4 ---
  Widget _buildStep4Docs() {
    return Column(
      children: [
        _buildImageUploadCard(
          'Ownership Proof / Rent Contract',
          _ownershipDocs,
          _pickOwnershipDocs,
          subtitle: 'Please upload a valid contract or utility bill.',
          existingImages: _existingDocs,
          onRemoveExisting: (index) =>
              setState(() => _existingDocs.removeAt(index)),
        ),
      ],
    );
  }

  // --- Components ---

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep == 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Back', style: TextStyle(color: Colors.blue[700])),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep == 3 ? 'Submit Clinic' : 'Continue',
                style: const TextStyle(
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[300]),
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: isRequired
            ? (val) => (val == null || val.isEmpty) ? 'Required' : null
            : null,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue[900] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
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
                          margin: const EdgeInsets.only(right: 12),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(entry.value),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
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
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
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

                // New Images (File)
                ...newImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
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
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
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
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wh.isOpen ? Colors.blue[100]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Switch(
                value: wh.isOpen,
                activeColor: Colors.blue,
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
                  color: wh.isOpen ? Colors.blue[900] : Colors.grey,
                ),
              ),
              const Spacer(),
              if (!wh.isOpen)
                const Text('Closed', style: TextStyle(color: Colors.grey)),
            ],
          ),
          if (wh.isOpen) ...[
            const Divider(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, day, isStart: true),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        wh.openTime ?? '09:00',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to'),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, day, isStart: false),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        wh.closeTime ?? '17:00',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
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

    final paint = Paint()
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
