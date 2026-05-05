import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/token_manager.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
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
    if (!_formKey.currentState!.validate()) return;

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

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully'),
        backgroundColor: DoctorTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background,
      body: BackgroundBlobs(
        child: SafeArea(
          child: BlocConsumer<DoctorCubit, DoctorState>(
            listener: (context, state) {
              if (state is DoctorProfileLoaded) _populateFields(state.profile);
              if (state is DoctorError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: DoctorTheme.danger,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is DoctorLoading;
              return Column(
                children: [
                  GlassHeader(
                    title: 'Professional Profile',
                    subtitle: 'Set your identity for patient trust',
                    onBack: () => Navigator.maybePop(context),
                    actionIcon: Icons.refresh_rounded,
                    actionTooltip: 'Refresh',
                    onAction: () => context.read<DoctorCubit>().fetchProfile(),
                  ),
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
                            _buildSaveButton(isLoading),
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
      ),
    );
  }

  // ── Identity Card ──────────────────────────────────────────────

  Widget _buildIdentityCard() {
    final verificationStatus =
        _currentProfile?.verificationStatus ?? 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(),
      child: Row(
        children: [
          // Avatar with gradient ring
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  DoctorTheme.primary.withValues(alpha: 0.2),
                  DoctorTheme.secondary.withValues(alpha: 0.12),
                ],
              ),
              border: Border.all(
                color: DoctorTheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: DoctorTheme.primaryDark,
              size: 36,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Doctor Account', style: DoctorTheme.headingSmall),
                    const SizedBox(width: 8),
                    _buildVerificationBadge(verificationStatus),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete your details to improve visibility and booking confidence.',
                  style: DoctorTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(String status) {
    final normalized = status.toLowerCase();
    Color color;
    String label;
    IconData icon;

    switch (normalized) {
      case 'approved':
        color = DoctorTheme.success;
        label = 'Verified';
        icon = Icons.verified_rounded;
        break;
      case 'rejected':
        color = DoctorTheme.danger;
        label = 'Rejected';
        icon = Icons.cancel_rounded;
        break;
      default:
        color = DoctorTheme.warning;
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Card ──────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('Medical Details'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: DoctorTheme.inputDecoration(
              label: 'Specialization',
              icon: Icons.medical_services_outlined,
            ),
            items: _specializations
                .map((spec) => DropdownMenuItem<String>(
                      value: spec,
                      child: Text(spec),
                    ))
                .toList(),
            onChanged: (value) =>
                setState(() => _selectedSpecialization = value),
            validator: (value) =>
                value == null ? 'Please select a specialization' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _licenseController,
            decoration: DoctorTheme.inputDecoration(
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
            decoration: DoctorTheme.inputDecoration(
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
            decoration: DoctorTheme.inputDecoration(
              label: 'Gender',
              icon: Icons.person_outline_rounded,
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) =>
                value == null ? 'Please select gender' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: DoctorTheme.inputDecoration(
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

  // ── Save Button ────────────────────────────────────────────────

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading ? null : DoctorTheme.headerGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: DoctorTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: DoctorTheme.headerGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: DoctorTheme.titleMedium),
      ],
    );
  }
}
