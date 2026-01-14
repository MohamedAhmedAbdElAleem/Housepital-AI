import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Mode State
  bool _isEditing = false;

  // Controllers
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  // Dropdown Values
  String? _selectedSpecialization;
  String? _selectedGender;

  // Images State
  bool _isUploadingProfile = false;
  bool _isUploadingLicense = false;
  bool _isSaving = false;

  // Current Profile Data
  DoctorModel? _currentProfile;

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
    'Home Nursing',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DoctorCubit>().fetchProfile();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _populateFields(DoctorModel profile) {
    _currentProfile = profile;
    _licenseController.text = profile.licenseNumber;
    _experienceController.text = profile.yearsOfExperience.toString();
    _bioController.text = profile.bio ?? '';
    _selectedSpecialization = profile.specialization.isNotEmpty
        ? profile.specialization
        : null;
    if (_selectedSpecialization != null &&
        !_specializations.contains(_selectedSpecialization)) {
      _specializations.add(_selectedSpecialization!);
    }
    _selectedGender = profile.gender;
  }

  Future<void> _pickAndUploadImage(bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // If no profile yet (create mode), we can't update.
    // Ideally we should create profile first or handle this case.
    // Assuming profile exists if we are in this page or init handled it.
    if (pickedFile == null || _currentProfile == null) return;

    final file = File(pickedFile.path);

    setState(() {
      if (isProfile) {
        _isUploadingProfile = true;
      } else {
        _isUploadingLicense = true;
      }
    });

    try {
      final cubit = context.read<DoctorCubit>();
      final url = await cubit.uploadImage(file);

      // Clone current profile with new URL
      final updatedProfile = DoctorModel(
        id: _currentProfile!.id,
        userId: _currentProfile!.userId,
        licenseNumber: _currentProfile!.licenseNumber,
        specialization: _currentProfile!.specialization,
        yearsOfExperience: _currentProfile!.yearsOfExperience,
        bio: _currentProfile!.bio,
        gender: _currentProfile!.gender,
        qualifications: _currentProfile!.qualifications,
        verificationStatus: _currentProfile!.verificationStatus,
        // Update specific URL
        profilePictureUrl: isProfile ? url : _currentProfile!.profilePictureUrl,
        licenseUrl: !isProfile ? url : _currentProfile!.licenseUrl,
        nationalIdUrl: _currentProfile!.nationalIdUrl,
        rejectionReason: _currentProfile!.rejectionReason,
        bookingMode: _currentProfile!.bookingMode,
        minAdvanceBookingHours: _currentProfile!.minAdvanceBookingHours,
        rushBookingEnabled: _currentProfile!.rushBookingEnabled,
        rushBookingPremiumPercent: _currentProfile!.rushBookingPremiumPercent,
        reliabilityRate: _currentProfile!.reliabilityRate,
        rating: _currentProfile!.rating,
        totalRatings: _currentProfile!.totalRatings,
      );

      await cubit.updateProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isProfile ? "Profile" : "License"} photo updated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        if (isProfile) {
          _isUploadingProfile = false;
        } else {
          _isUploadingLicense = false;
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _currentProfile == null) return;

    setState(() => _isSaving = true);

    try {
      final userId = await TokenManager.getUserId();
      final doctor = DoctorModel(
        id: _currentProfile!.id,
        userId: userId ?? '',
        licenseNumber: _licenseController.text,
        specialization: _selectedSpecialization!,
        yearsOfExperience: int.parse(_experienceController.text),
        bio: _bioController.text,
        gender: _selectedGender,
        // Keep existing URLs and other fields
        profilePictureUrl: _currentProfile!.profilePictureUrl,
        licenseUrl: _currentProfile!.licenseUrl,
        nationalIdUrl: _currentProfile!.nationalIdUrl,
        qualifications: _currentProfile!.qualifications,
        verificationStatus: _currentProfile!
            .verificationStatus, // Keep existing status? Or reset if license changed?
        // Logic in controller resets status if license number changes.
        rejectionReason: _currentProfile!.rejectionReason,
        bookingMode: _currentProfile!.bookingMode,
        minAdvanceBookingHours: _currentProfile!.minAdvanceBookingHours,
        rushBookingEnabled: _currentProfile!.rushBookingEnabled,
        rushBookingPremiumPercent: _currentProfile!.rushBookingPremiumPercent,
        reliabilityRate: _currentProfile!.reliabilityRate,
        rating: _currentProfile!.rating,
        totalRatings: _currentProfile!.totalRatings,
      );

      await context.read<DoctorCubit>().updateProfile(doctor);

      setState(() => _isEditing = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state is DoctorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DoctorProfileLoaded) {
            _populateFields(state.profile);
            if (_isSaving) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // Show loading initially, but not during our manual async ops (uploading/saving) which have their own indicators
          if (state is DoctorLoading &&
              !_isUploadingProfile &&
              !_isUploadingLicense &&
              !_isSaving) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentProfile == null && state is! DoctorLoading) {
            return const Center(child: Text("No profile data"));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: _isEditing ? _buildEditForm() : _buildViewMode(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: !_isEditing
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _isEditing = true),
              backgroundColor: const Color(0xFF1565C0),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildViewMode() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSectionTitle('Professional Info'),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow(
            Icons.medical_services_outlined,
            'Specialization',
            _currentProfile?.specialization ?? '-',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.work_history_outlined,
            'Experience',
            '${_currentProfile?.yearsOfExperience ?? 0} Years',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'License Number',
            _currentProfile?.licenseNumber ?? '-',
          ),
        ]),

        if (_currentProfile?.licenseUrl != null) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('License Document'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _currentProfile!.licenseUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],

        const SizedBox(height: 32),
        _buildSectionTitle('Personal Details'),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow(
            Icons.person_outline,
            'Gender',
            _currentProfile?.gender != null &&
                    _currentProfile!.gender!.isNotEmpty
                ? _currentProfile!.gender![0].toUpperCase() +
                      _currentProfile!.gender!.substring(1)
                : '-',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.description_outlined,
            'Bio',
            _currentProfile?.bio ?? 'No bio provided.',
          ),
        ]),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('Edit Professional Info'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Specialization',
                  icon: Icons.medical_services_outlined,
                  value: _selectedSpecialization,
                  items: _specializations,
                  onChanged: (val) =>
                      setState(() => _selectedSpecialization = val),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _experienceController,
                  label: 'Experience (Years)',
                  icon: Icons.work_history_outlined,
                  isNumber: true,
                  hint: 'e.g. 5',
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _licenseController,
                  label: 'License Number',
                  icon: Icons.verified_user_outlined,
                  hint: 'e.g. LIC-12345678',
                  validator: (val) =>
                      val != null && val.length < 5 ? 'Invalid License' : null,
                ),
                const SizedBox(height: 24),
                _buildLicenseUpload(),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Edit Personal Details'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Gender',
                  icon: Icons.person_outline,
                  value: _selectedGender,
                  items: const ['Male', 'Female'],
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _bioController,
                  label: 'About Me',
                  icon: Icons.description_outlined,
                  maxLines: 5,
                  hint: 'Write a short overview...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (_currentProfile != null)
                      _populateFields(_currentProfile!);
                    setState(() => _isEditing = false);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final user = context.select(
      (AuthCubit c) => c.state is AuthAuthenticated
          ? (c.state as AuthAuthenticated).user
          : null,
    );

    final profileUrl = _currentProfile?.profilePictureUrl;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0D47A1),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () => _pickAndUploadImage(true),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: profileUrl != null
                              ? NetworkImage(profileUrl)
                              : null,
                          child: _isUploadingProfile
                              ? const CircularProgressIndicator()
                              : (profileUrl == null
                                    ? Text(
                                        user?.name.isNotEmpty == true
                                            ? user!.name[0].toUpperCase()
                                            : 'D',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1565C0),
                                        ),
                                      )
                                    : null),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Doctor Name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user?.email ?? 'doctor@example.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLicenseUpload() {
    final licenseUrl = _currentProfile?.licenseUrl;
    final hasImage = licenseUrl != null && licenseUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LICENSE ID PHOTO (AUTO-UPLOAD)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF90A4AE),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickAndUploadImage(false),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              image: (hasImage && !_isUploadingLicense)
                  ? DecorationImage(
                      image: NetworkImage(licenseUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _isUploadingLicense
                ? const Center(child: CircularProgressIndicator())
                : (!hasImage
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 40,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to Upload License',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF90A4AE),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          validator:
              validator ??
              (val) => (val == null || val.isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1
                ? Icon(icon, color: const Color(0xFF1565C0))
                : Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      top: 12,
                      right: 12,
                    ),
                    child: Icon(icon, color: const Color(0xFF1565C0)),
                  ),
            filled: true,
            fillColor: const Color(0xFFF1F4F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF90A4AE),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value != null && value.isNotEmpty
              ? (label == 'Gender' && (value == 'male' || value == 'female')
                    ? value[0].toUpperCase() + value.substring(1)
                    : value)
              : null,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (val) {
            if (label == 'Gender' && val != null)
              onChanged(val.toLowerCase());
            else
              onChanged(val);
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
            filled: true,
            fillColor: const Color(0xFFF1F4F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
