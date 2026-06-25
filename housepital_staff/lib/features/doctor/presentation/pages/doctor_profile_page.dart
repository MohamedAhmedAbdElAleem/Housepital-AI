import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/theme_cubit.dart';
import '../../../../config/language/language_cubit.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        content: Text(l10n.save),
        backgroundColor: DoctorTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    title: l10n.myProfile,
                    subtitle: l10n.editProfileData,
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
                            _buildIdentityCard(l10n),
                            SizedBox(height: 14),
                            _buildSettingsCard(l10n),
                            SizedBox(height: 14),
                            _buildFormCard(l10n),
                            SizedBox(height: 20),
                            _buildSaveButton(isLoading, l10n),
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

  Widget _buildIdentityCard(AppLocalizations l10n) {
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
                    Text(l10n.myProfile, style: DoctorTheme.headingSmall(context)),
                    SizedBox(width: 8),
                    _buildVerificationBadge(verificationStatus),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  l10n.editProfileData,
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

  // ── Settings Card (Dark Mode + Language) ───────────────────────

  Widget _buildSettingsCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(l10n.settings),
          SizedBox(height: 12),
          // Dark Mode Toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.darkMode, style: DoctorTheme.titleMedium(context)),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? l10n.darkThemeEnabled
                      : l10n.lightThemeEnabled,
                  style: DoctorTheme.caption(context),
                ),
                secondary: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: DoctorTheme.primary,
                ),
                value: themeMode == ThemeMode.dark,
                activeColor: DoctorTheme.primary,
                onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
          Divider(color: DoctorTheme.border(context)),
          // Language Toggle
          BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.language_rounded, color: DoctorTheme.primary),
                title: Text(l10n.language, style: DoctorTheme.titleMedium(context)),
                subtitle: Text(
                  locale.languageCode == 'ar' ? 'العربية' : 'English',
                  style: DoctorTheme.caption(context),
                ),
                trailing: SizedBox(
                  width: 90,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => context.read<LanguageCubit>().toggleLanguage(),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          locale.languageCode == 'ar' ? 'English' : 'العربية',
                          style: TextStyle(
                            color: DoctorTheme.primary,
                            fontWeight: FontWeight.w700,
                            inherit: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Form Card ──────────────────────────────────────────────────

  Widget _buildFormCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionLabel(l10n.professionalDetails),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: DoctorTheme.inputDecoration(context,
              label: l10n.professionalDetails,
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
                value == null ? l10n.somethingWentWrong : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _licenseController,
            decoration: DoctorTheme.inputDecoration(context,
              label: l10n.credentials,
              icon: Icons.badge_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.somethingWentWrong;
              }
              if (value.trim().length < 5) {
                return l10n.somethingWentWrong;
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: DoctorTheme.inputDecoration(context,
              label: l10n.personalDetails,
              icon: Icons.timeline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.somethingWentWrong;
              }
              if (int.tryParse(value) == null) {
                return l10n.somethingWentWrong;
              }
              return null;
            },
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: DoctorTheme.inputDecoration(context,
              label: l10n.personalDetails,
              icon: Icons.person_outline_rounded,
            ),
            items: [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) =>
                value == null ? l10n.somethingWentWrong : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: DoctorTheme.inputDecoration(context,
              label: l10n.professionalDetails,
              icon: Icons.edit_note_rounded,
            ),
            validator: (value) {
              if (value != null && value.length > 500) {
                return l10n.somethingWentWrong;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Save Button ────────────────────────────────────────────────

  Widget _buildSaveButton(bool isLoading, AppLocalizations l10n) {
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
                    offset: Offset(0, 4),
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
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.save_rounded),
          label: Text(
            isLoading ? '...' : l10n.save,
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
