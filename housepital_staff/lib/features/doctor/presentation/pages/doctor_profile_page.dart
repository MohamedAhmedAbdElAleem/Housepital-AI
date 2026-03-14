import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/token_manager.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  static const Color _bg = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF2664EC);
  static const Color _primaryDark = Color(0xFF1136A8);
  static const Color _secondary = Color(0xFF3498BB);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);

  final _formKey = GlobalKey<FormState>();

  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedSpecialization;
  String? _selectedGender;

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

    _selectedSpecialization =
        profile.specialization.isNotEmpty ? profile.specialization : null;

    if (_selectedSpecialization != null &&
        !_specializations.contains(_selectedSpecialization)) {
      _specializations.add(_selectedSpecialization!);
    }

    _selectedGender = profile.gender;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final doctorCubit = context.read<DoctorCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final userId = await TokenManager.getUserId();

    final profileToSave = DoctorModel(
      id: _currentProfile?.id,
      userId: _currentProfile?.userId ?? userId ?? '',
      licenseNumber: _licenseController.text.trim(),
      specialization: _selectedSpecialization!,
      yearsOfExperience: int.parse(_experienceController.text),
      bio: _bioController.text.trim(),
      gender: _selectedGender,
      qualifications: _currentProfile?.qualifications ?? const [],
      verificationStatus: _currentProfile?.verificationStatus ?? 'pending',
      profilePictureUrl: _currentProfile?.profilePictureUrl,
      licenseUrl: _currentProfile?.licenseUrl,
      nationalIdUrl: _currentProfile?.nationalIdUrl,
      rejectionReason: _currentProfile?.rejectionReason,
      bookingMode: _currentProfile?.bookingMode ?? 'slots',
      minAdvanceBookingHours: _currentProfile?.minAdvanceBookingHours ?? 3,
      rushBookingEnabled: _currentProfile?.rushBookingEnabled ?? false,
      rushBookingPremiumPercent:
          _currentProfile?.rushBookingPremiumPercent ?? 25,
      reliabilityRate: _currentProfile?.reliabilityRate ?? 100,
      rating: _currentProfile?.rating ?? 0,
      totalRatings: _currentProfile?.totalRatings ?? 0,
    );

    if (_currentProfile == null) {
      await doctorCubit.createProfile(profileToSave);
    } else {
      await doctorCubit.updateProfile(profileToSave);
    }

    if (!mounted) {
      return;
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully'),
        backgroundColor: Color(0xFF16A34A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _buildBackgroundBlob(
              size: 280,
              colors: const [Color(0x2A2664EC), Color(0x003498BB)],
            ),
          ),
          Positioned(
            top: 220,
            left: -100,
            child: _buildBackgroundBlob(
              size: 240,
              colors: const [Color(0x1A1136A8), Color(0x002664EC)],
            ),
          ),
          SafeArea(
            child: BlocConsumer<DoctorCubit, DoctorState>(
              listener: (context, state) {
                if (state is DoctorProfileLoaded) {
                  _populateFields(state.profile);
                }

                if (state is DoctorError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is DoctorLoading;

                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildIdentityCard(),
                              const SizedBox(height: 14),
                              _buildFormCard(),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: isLoading ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: Text(
                                    isLoading ? 'Saving...' : 'Save Profile',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob(
      {required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryDark, _primary, _secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                fixedSize: const Size(40, 40),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Set your identity for patient trust',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.read<DoctorCubit>().fetchProfile(),
              icon: const Icon(Icons.refresh_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                fixedSize: const Size(40, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _primary.withValues(alpha: 0.2),
                  _secondary.withValues(alpha: 0.12),
                ],
              ),
            ),
            child:
                const Icon(Icons.person_rounded, color: _primaryDark, size: 36),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Account',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete your details to improve visibility and booking confidence.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 12.8,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('Medical Details'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: _fieldDecoration(
              label: 'Specialization',
              icon: Icons.medical_services_outlined,
            ),
            items: _specializations.map((spec) {
              return DropdownMenuItem<String>(value: spec, child: Text(spec));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSpecialization = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a specialization';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _licenseController,
            decoration: _fieldDecoration(
              label: 'Medical License Number',
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'License number is required';
              }
              if (value.trim().length < 5) {
                return 'Must be at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: _fieldDecoration(
              label: 'Years of Experience',
              icon: Icons.timeline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Years of experience is required';
              }
              if (int.tryParse(value) == null) {
                return 'Must be a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: _fieldDecoration(
              label: 'Gender',
              icon: Icons.person_outline_rounded,
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select gender';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: _fieldDecoration(
              label: 'Professional Bio',
              icon: Icons.edit_note_rounded,
              hint: 'Tell patients about your expertise...',
            ),
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Bio is too long';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FBFF),
      prefixIcon: Icon(icon, color: _primaryDark),
      labelStyle: const TextStyle(color: _textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8E5FF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8E5FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.4),
      ),
    );
  }
}
