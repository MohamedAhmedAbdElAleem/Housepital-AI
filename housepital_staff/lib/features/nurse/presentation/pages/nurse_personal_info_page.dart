import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../../../l10n/app_localizations.dart';

class NursePersonalInfoPage extends StatelessWidget {
  const NursePersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.personalDetails,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: BlocBuilder<NurseProfileCubit, NurseProfileState>(
        builder: (context, state) {
          NurseProfile? profile = state is NurseProfileLoaded 
              ? state.profile 
              : context.read<NurseProfileCubit>().currentProfile;

          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, profile, l10n),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, l10n.personalDetails),
                _buildInfoCard(context, [
                  _buildInfoRow(context, 'Full Name', profile.userName ?? 'Not set', Icons.person_outline),
                  _buildInfoRow(context, 'Email', profile.userEmail ?? 'Not set', Icons.email_outlined),
                  _buildInfoRow(context, 'Mobile', profile.userMobile ?? 'Not set', Icons.phone_outlined, showBottomDivider: false),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, l10n.professionalDetails),
                _buildInfoCard(context, [
                  _buildInfoRow(context, 'Specialization', _translateSpecialization(profile.specialization ?? 'Not set'), Icons.medical_services_outlined),
                  _buildInfoRow(context, 'Experience', '${profile.yearsOfExperience ?? 0} Years', Icons.history_edu_outlined),
                  _buildInfoRow(context, 'Bio', profile.bio != null && profile.bio!.isNotEmpty ? profile.bio! : 'Not provided', Icons.info_outline, showBottomDivider: false),
                ]),
                if (profile.skills.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, l10n.skills),
                  _buildSkillsCard(context, profile.skills),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, NurseProfile profile, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userName = profile.userName ?? 'Nurse';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    final specialization = profile.specialization ?? 'Registered Nurse';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary600, AppColors.primary400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withAlpha(isDark ? 40 : 80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10)],
            ),
            child: Center(
              child: Text(
                userInitial,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withAlpha(230)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(theme.brightness == Brightness.dark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon, {bool showBottomDivider = true}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary50.withAlpha(isDark ? 30 : 25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary500, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withAlpha(150)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showBottomDivider)
          Divider(height: 1, thickness: 1, color: theme.colorScheme.outline.withAlpha(50), indent: 64),
      ],
    );
  }

  Widget _buildSkillsCard(BuildContext context, List<String> skills) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary500.withAlpha(isDark ? 30 : 25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary500.withAlpha(isDark ? 80 : 50)),
          ),
          child: Text(
            _translateSkill(skill),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary500),
          ),
        )).toList(),
      ),
    );
  }

  String _translateSpecialization(String spec) {
    switch (spec) {
      case 'Critical Care': return 'العناية المركزة';
      case 'Elderly Care': return 'رعاية المسنين';
      case 'Pediatrics': return 'طب الأطفال';
      case 'General Nursing': return 'التمريض العام';
      case 'Post-Surgery': return 'رعاية ما بعد الجراحة';
      case 'Wound Care': return 'العناية بالجروح';
      default: return spec;
    }
  }

  String _translateSkill(String skill) {
    switch (skill) {
      case 'wound_care': return 'العناية بالجروح';
      case 'iv_insertion': return 'تركيب الكانيولا';
      case 'injections': return 'الحقن';
      case 'blood_draw': return 'سحب الدم';
      case 'elderly_care': return 'رعاية المسنين';
      case 'patient_monitoring': return 'مراقبة المريض';
      case 'physiotherapy_support': return 'دعم العلاج الطبيعي';
      case 'baby_care': return 'رعاية الأطفال';
      case 'emergency_response': return 'الاستجابة للطوارئ';
      default: return skill.replaceAll('_', ' ').toUpperCase();
    }
  }
}
