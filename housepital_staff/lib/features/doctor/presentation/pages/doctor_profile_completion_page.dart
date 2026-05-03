import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';

class DoctorProfileCompletionPage extends StatefulWidget {
  const DoctorProfileCompletionPage({super.key});

  @override
  State<DoctorProfileCompletionPage> createState() =>
      _DoctorProfileCompletionPageState();
}

class _DoctorProfileCompletionPageState
    extends State<DoctorProfileCompletionPage> {
  static const _primary = Color(0xFF2664EC);
  static const _primaryDark = Color(0xFF1136A8);

  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Personal Info
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedSpecialization;
  String? _selectedGender;

  // Step 2: Document Uploads
  File? _nationalIdFile;
  File? _licenseFile;
  File? _degreeCertificateFile;
  File? _syndicateCardFile;

  // Pre-existing URLs for re-submission
  String? _existingNationalIdUrl;
  String? _existingLicenseUrl;
  String? _existingDegreeCertUrl;
  String? _existingSyndicateUrl;

  // Submission state
  bool _isSubmitting = false;
  String _uploadProgressText = '';
  double _uploadProgressValue = 0;

  DoctorModel? _existingProfile;
  final ImagePicker _picker = ImagePicker();

  final List<String> _specializations = [
    'General Practice',
    'Pediatrics',
    'Internal Medicine',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Psychiatry',
    'Neurology',
    'Physiotherapy',
    'Urology',
    'Oncology',
    'Endocrinology',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final cubit = context.read<DoctorCubit>();
    await cubit.fetchProfile();
    if (!mounted) return;

    final state = cubit.state;
    if (state is DoctorProfileLoaded) {
      final p = state.profile;
      setState(() {
        _existingProfile = p;
        _licenseController.text = p.licenseNumber;
        _experienceController.text = p.yearsOfExperience.toString();
        _bioController.text = p.bio ?? '';
        _selectedSpecialization = p.specialization.isNotEmpty
            ? p.specialization
            : null;
        if (_selectedSpecialization != null &&
            !_specializations.contains(_selectedSpecialization)) {
          _specializations.add(_selectedSpecialization!);
        }
        _selectedGender = p.gender;
        _existingNationalIdUrl = p.nationalIdUrl;
        _existingLicenseUrl = p.licenseUrl;
        _existingDegreeCertUrl = p.degreeCertificateUrl;
        _existingSyndicateUrl = p.syndicateCardUrl;
      });
    }
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      if (_selectedSpecialization == null) {
        _showError('Please select a specialization');
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
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
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.read<AuthCubit>().logout();
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      }
    }
  }

  Future<void> _pickDocument(String type) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload from',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: _primary),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(type, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: _primary),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromSource(type, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined, color: _primary),
                  title: const Text('Document (PDF)'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile(type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromSource(String type, ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image == null || !mounted) return;
      setState(() {
        _setFileByType(type, File(image.path));
      });
    } catch (_) {}
  }

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null || !mounted) return;
      setState(() {
        _setFileByType(type, File(result.files.single.path!));
      });
    } catch (_) {}
  }

  void _setFileByType(String type, File file) {
    switch (type) {
      case 'nationalId':
        _nationalIdFile = file;
        break;
      case 'license':
        _licenseFile = file;
        break;
      case 'degree':
        _degreeCertificateFile = file;
        break;
      case 'syndicate':
        _syndicateCardFile = file;
        break;
    }
  }

  Future<void> _submitProfile() async {
    // Validate documents
    final hasNationalId = _nationalIdFile != null || _existingNationalIdUrl != null;
    final hasLicense = _licenseFile != null || _existingLicenseUrl != null;
    final hasDegree = _degreeCertificateFile != null || _existingDegreeCertUrl != null;
    final hasSyndicate = _syndicateCardFile != null || _existingSyndicateUrl != null;

    if (!hasNationalId || !hasLicense || !hasDegree || !hasSyndicate) {
      _showError('Please upload all required documents');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgressText = 'Preparing...';
      _uploadProgressValue = 0.05;
    });

    final cubit = context.read<DoctorCubit>();

    try {
      final userId = await TokenManager.getUserId();

      // Upload documents
      String? nationalIdUrl = _existingNationalIdUrl;
      String? licenseUrl = _existingLicenseUrl;
      String? degreeCertUrl = _existingDegreeCertUrl;
      String? syndicateUrl = _existingSyndicateUrl;

      int step = 0;
      final totalUploads = [
        _nationalIdFile,
        _licenseFile,
        _degreeCertificateFile,
        _syndicateCardFile,
      ].where((f) => f != null).length;

      Future<String> uploadWithProgress(File file, String label) async {
        step++;
        setState(() {
          _uploadProgressText = 'Uploading $label...';
          _uploadProgressValue = step / (totalUploads + 1);
        });
        return await cubit.uploadImage(file);
      }

      if (_nationalIdFile != null) {
        nationalIdUrl = await uploadWithProgress(_nationalIdFile!, 'National ID');
      }
      if (_licenseFile != null) {
        licenseUrl = await uploadWithProgress(_licenseFile!, 'Medical License');
      }
      if (_degreeCertificateFile != null) {
        degreeCertUrl = await uploadWithProgress(_degreeCertificateFile!, 'Degree Certificate');
      }
      if (_syndicateCardFile != null) {
        syndicateUrl = await uploadWithProgress(_syndicateCardFile!, 'Syndicate Card');
      }

      setState(() {
        _uploadProgressText = 'Saving profile...';
        _uploadProgressValue = 0.9;
      });

      final profile = DoctorModel(
        id: _existingProfile?.id,
        userId: _existingProfile?.userId ?? userId ?? '',
        licenseNumber: _licenseController.text.trim(),
        specialization: _selectedSpecialization!,
        yearsOfExperience: int.parse(_experienceController.text),
        bio: _bioController.text.trim(),
        gender: _selectedGender,
        nationalIdUrl: nationalIdUrl,
        licenseUrl: licenseUrl,
        degreeCertificateUrl: degreeCertUrl,
        syndicateCardUrl: syndicateUrl,
        verificationStatus: 'pending',
        isActive: false,
      );

      if (_existingProfile != null) {
        await cubit.updateProfile(profile);
      } else {
        await cubit.createProfile(profile);
      }
      
      if (cubit.state is DoctorError) {
        throw Exception((cubit.state as DoctorError).message);
      }

      setState(() {
        _uploadProgressText = 'Done!';
        _uploadProgressValue = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      // Save verification status and navigate
      await TokenManager.saveHasProfile(true);
      await TokenManager.saveVerificationStatus('pending');

      if (mounted) {
        context.read<AuthCubit>().logout();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile submitted successfully! Please login to check your status.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            _prevStep();
            return false;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F8FF),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(onPressed: _prevStep, color: _primaryDark),
            title: Text(
              _existingProfile != null
                  ? 'Update Your Profile'
                  : 'Complete Your Profile',
              style: TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildStepIndicator(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1PersonalInfo(),
                      _buildStep2Documents(),
                      _buildStep3Review(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
        ),
        if (_isSubmitting) _buildOverlay(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
      child: Row(
        children: [
          _buildStepDot(0, 'Personal'),
          _buildStepLine(0),
          _buildStepDot(1, 'Documents'),
          _buildStepLine(1),
          _buildStepDot(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index, String label) {
    final isActive = _currentStep == index;
    final isDone = _currentStep > index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? Colors.green
                : isActive
                    ? _primary
                    : Colors.grey[300],
            boxShadow: isActive
                ? [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 8)]
                : [],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? _primary : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int index) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Container(
          height: 2,
          color: _currentStep > index ? Colors.green : Colors.grey[300],
        ),
      ),
    );
  }

  // ─── Step 1: Personal Info ──────────────────────────────────────────
  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Professional Information'),
          const SizedBox(height: 16),
          _buildTextField(
            _licenseController,
            'Medical License Number',
            Icons.badge_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _buildDropdown(),
          const SizedBox(height: 16),
          _buildTextField(
            _experienceController,
            'Years of Experience',
            Icons.work_history_outlined,
            inputType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final n = int.tryParse(v);
              if (n == null || n < 0) return 'Invalid';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildGenderSelector(),
          const SizedBox(height: 16),
          _buildTextField(
            _bioController,
            'Short Bio (optional)',
            Icons.edit_note_rounded,
            maxLines: 3,
            required: false,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Step 2: Documents ──────────────────────────────────────────────
  Widget _buildStep2Documents() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Verification Documents'),
          const SizedBox(height: 8),
          Text(
            'Upload clear photos of the following documents',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          _buildDocCard(
            'National ID',
            Icons.credit_card_rounded,
            _nationalIdFile,
            _existingNationalIdUrl,
            () => _pickDocument('nationalId'),
          ),
          const SizedBox(height: 12),
          _buildDocCard(
            'Medical License',
            Icons.verified_rounded,
            _licenseFile,
            _existingLicenseUrl,
            () => _pickDocument('license'),
          ),
          const SizedBox(height: 12),
          _buildDocCard(
            'Degree Certificate',
            Icons.school_rounded,
            _degreeCertificateFile,
            _existingDegreeCertUrl,
            () => _pickDocument('degree'),
          ),
          const SizedBox(height: 12),
          _buildDocCard(
            'Syndicate Card',
            Icons.card_membership_rounded,
            _syndicateCardFile,
            _existingSyndicateUrl,
            () => _pickDocument('syndicate'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Step 3: Review ─────────────────────────────────────────────────
  Widget _buildStep3Review() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Review Your Profile'),
          const SizedBox(height: 16),
          _reviewRow('License Number', _licenseController.text),
          _reviewRow('Specialization', _selectedSpecialization ?? '--'),
          _reviewRow('Experience', '${_experienceController.text} years'),
          _reviewRow('Gender', _selectedGender ?? 'Not specified'),
          if (_bioController.text.isNotEmpty)
            _reviewRow('Bio', _bioController.text),
          const SizedBox(height: 24),
          _sectionTitle('Documents'),
          const SizedBox(height: 12),
          _docStatus('National ID', _nationalIdFile != null || _existingNationalIdUrl != null),
          _docStatus('Medical License', _licenseFile != null || _existingLicenseUrl != null),
          _docStatus('Degree Certificate', _degreeCertificateFile != null || _existingDegreeCertUrl != null),
          _docStatus('Syndicate Card', _syndicateCardFile != null || _existingSyndicateUrl != null),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'After submission, your account will be reviewed by our team. You will receive an email notification.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ───────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _primaryDark,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
      validator: validator ??
          (required
              ? (v) => v == null || v.isEmpty ? 'Required' : null
              : null),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSpecialization,
      decoration: InputDecoration(
        labelText: 'Specialization',
        prefixIcon: const Icon(Icons.local_hospital_outlined, color: _primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      items: _specializations
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: (v) => setState(() => _selectedSpecialization = v),
      validator: (v) => v == null ? 'Please select a specialization' : null,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _genderChip('Male', 'male', Icons.male)),
            const SizedBox(width: 12),
            Expanded(child: _genderChip('Female', 'female', Icons.female)),
          ],
        ),
      ],
    );
  }

  Widget _genderChip(String label, String value, IconData icon) {
    final selected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _primary : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? _primary : Colors.grey[500], size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? _primary : Colors.grey[700],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(
    String title,
    IconData icon,
    File? file,
    String? existingUrl,
    VoidCallback onPick,
  ) {
    final hasFile = file != null || (existingUrl != null && existingUrl.isNotEmpty);
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile ? Colors.green[300]! : Colors.grey[300]!,
            width: hasFile ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.green[50]
                    : _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_rounded : icon,
                color: hasFile ? Colors.green : _primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile
                        ? (file != null ? 'New file selected' : 'Previously uploaded')
                        : 'Tap to upload',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasFile ? Colors.green[700] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.upload_file_rounded,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _docStatus(String label, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            uploaded ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: uploaded ? Colors.green : Colors.red[300],
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 2 ? Colors.green : _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: Text(
                _currentStep == 2 ? 'Submit for Review' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.4),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: _uploadProgressValue,
                      strokeWidth: 6,
                      backgroundColor: Colors.grey[200],
                      color: _uploadProgressValue >= 1.0
                          ? Colors.green
                          : _primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _uploadProgressValue >= 1.0
                        ? 'Submitted!'
                        : 'Uploading...',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _uploadProgressText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
