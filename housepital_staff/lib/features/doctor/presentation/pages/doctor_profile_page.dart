import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  // Dropdown Values
  String? _selectedSpecialization;
  String? _selectedGender;

  // Images State
  bool _isPickingImage = false;
  bool _isUploadingProfile = false;
  bool _isUploadingLicense = false;
  bool _isSaving = false;
  bool _isEditing = true;

  // Image Picker
  final ImagePicker _picker = ImagePicker();

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
    // Fetch existing profile if any
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
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      // PlatformException(already_active) — ignore
      if (mounted) setState(() => _isPickingImage = false);
      return;
    } finally {
      if (mounted && pickedFile == null)
        setState(() => _isPickingImage = false);
    }
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

    // Capture cubit BEFORE any await so it's safe after suspension
    final cubit = context.read<DoctorCubit>();

    try {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${isProfile ? "Profile" : "License"} photo updated!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
          if (isProfile) {
            _isUploadingProfile = false;
          } else {
            _isUploadingLicense = false;
          }
        });
      }
    }
  }

  // _submitForm is the canonical save method used by the Submit button
  Future<void> _submitForm() => _saveChanges();

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _currentProfile == null) return;

    setState(() => _isSaving = true);
    // Capture cubit BEFORE any await
    final cubit = context.read<DoctorCubit>();

    try {
      final userId = await TokenManager.getUserId();

      final doctor = DoctorModel(
        userId: userId ?? '',
        licenseNumber: _licenseController.text,
        specialization: _selectedSpecialization!,
        yearsOfExperience: int.parse(_experienceController.text),
        bio: _bioController.text,
        gender: _selectedGender,
        // Default values for now, will be implemented with upload
        qualifications: [],
      );

      await cubit.updateProfile(doctor);

      if (mounted) setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Profile')),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile Saved Successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Pre-fill form if loaded
            if (_licenseController.text.isEmpty) {
              _licenseController.text = state.profile.licenseNumber;
              _experienceController.text = state.profile.yearsOfExperience
                  .toString();
              _bioController.text = state.profile.bio ?? '';
              setState(() {
                _selectedSpecialization =
                    state.profile.specialization.isNotEmpty
                    ? state.profile.specialization
                    : null;
                // Handle case where spec might not be in list
                if (_selectedSpecialization != null &&
                    !_specializations.contains(_selectedSpecialization)) {
                  _specializations.add(_selectedSpecialization!);
                }
                _selectedGender = state.profile.gender;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete your professional profile to start receiving bookings.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Specialization
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items: _specializations.map((spec) {
                      return DropdownMenuItem(value: spec, child: Text(spec));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSpecialization = val),
                    validator: (val) =>
                        val == null ? 'Please select a specialization' : null,
                  ),
                  const SizedBox(height: 16),

                  // License Number
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: 'Medical License Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (val.length < 5)
                        return 'Must be at least 5 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Years of Experience
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.history),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                    validator: (val) =>
                        val == null ? 'Please select gender' : null,
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Professional Bio',
                      hintText: 'Tell patients about your expertise...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val != null && val.length > 500 ? 'Too long' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
