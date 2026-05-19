import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme_cubit.dart';
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
    'general_practice'.tr(),
    'Pediatrics',
    'internal_medicine'.tr(),
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
    'home_nursing'.tr(),
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
        content: Text('profile_saved_successfully'.tr()),
        backgroundColor: DoctorTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
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
                    title: 'professional_profile'.tr(),
                    subtitle: 'set_your_identity_for_patient_trust'.tr(),
                    onBack: () => Navigator.maybePop(context),
                    actionIcon: Icons.refresh_rounded,
                    actionTooltip: 'Refresh',
                    onAction: () => context.read<DoctorCubit>().fetchProfile(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 6, 16, 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildIdentityCard(),
                            SizedBox(height: 14),
                            _buildFormCard(),
                            SizedBox(height: 14),
                            _buildSettingsCard(context),
                            SizedBox(height: 20),
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
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
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
            child: Icon(
              Icons.person_rounded,
              color: DoctorTheme.primaryDark,
              size: 36,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('doctor_account'.tr(), style: DoctorTheme.headingSmall(context)),
                    SizedBox(width: 8),
                    _buildVerificationBadge(verificationStatus),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'complete_your_details_to_improve_visibility_and_booking_confidence'.tr(),
                  style: DoctorTheme.bodySmall(context),
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
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
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
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('medical_details'.tr()),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: DoctorTheme.inputDecoration(context, 
              label: 'specialization'.tr(),
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
                value == null ? 'please_select_a_specialization'.tr() : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _licenseController,
            decoration: DoctorTheme.inputDecoration(context, 
              label: 'medical_license_number'.tr(),
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'license_number_is_required'.tr();
              }
              if (value.trim().length < 5) {
                return 'must_be_at_least_5_characters'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: DoctorTheme.inputDecoration(context, 
              label: 'years_of_experience'.tr(),
              icon: Icons.timeline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'years_of_experience_is_required'.tr();
              }
              if (int.tryParse(value) == null) {
                return 'must_be_a_valid_number'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: DoctorTheme.inputDecoration(context, 
              label: 'gender'.tr(),
              icon: Icons.person_outline_rounded,
            ),
            items: [
              DropdownMenuItem(value: 'male', child: Text('male'.tr())),
              DropdownMenuItem(value: 'female', child: Text('female'.tr())),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) =>
                value == null ? 'please_select_gender'.tr() : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: DoctorTheme.inputDecoration(context, 
              label: 'professional_bio'.tr(),
              icon: Icons.edit_note_rounded,
              hint: 'tell_patients_about_your_expertise'.tr(),
            ),
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'bio_is_too_long'.tr();
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  // ── Settings Card ──────────────────────────────────────────────

  Widget _buildSettingsCard(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state == ThemeMode.dark;
    final locale = context.locale.languageCode;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel('app_settings'.tr()),
          SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('dark_mode'.tr(), style: DoctorTheme.bodyMedium(context)),
            secondary: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: DoctorTheme.primary,
            ),
            value: isDark,
            activeColor: DoctorTheme.primary,
            onChanged: (val) => themeCubit.toggleTheme(val),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('language'.tr(), style: DoctorTheme.bodyMedium(context)),
            leading: Icon(Icons.language_rounded, color: DoctorTheme.primary),
            trailing: DropdownButton<String>(
              value: locale,
              underline: SizedBox(),
              items: [
                DropdownMenuItem(value: 'en', child: Text('english'.tr())),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (val) {
                if (val != null) {
                  context.setLocale(Locale(val));
                }
              },
            ),
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
          gradient: isLoading ? null : DoctorTheme.headerGradient(context),
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
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: DoctorTheme.surface(context),
                  ),
                )
              : Icon(Icons.save_rounded),
          label: Text(
            isLoading ? 'Saving...' : 'save_profile'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
            gradient: DoctorTheme.headerGradient(context),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Text(text, style: DoctorTheme.titleMedium(context)),
      ],
    );
  }
}
