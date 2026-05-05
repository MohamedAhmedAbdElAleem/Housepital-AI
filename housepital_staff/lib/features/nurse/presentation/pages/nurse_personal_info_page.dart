import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';

class NursePersonalInfoPage extends StatelessWidget {
  const NursePersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<NurseProfileCubit, NurseProfileState>(
        builder: (context, state) {
          NurseProfile? profile;
          if (state is NurseProfileLoaded) {
            profile = state.profile;
          } else {
            profile = context.read<NurseProfileCubit>().currentProfile;
          }

          if (profile == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(profile),
                const SizedBox(height: 24),
                
                _buildSectionTitle('Personal Details'),
                _buildInfoCard([
                  _buildInfoRow('Full Name', profile.userName ?? 'Not set', Icons.person_outline),
                  _buildInfoRow('Email', profile.userEmail ?? 'Not set', Icons.email_outlined),
                  _buildInfoRow('Mobile', profile.userMobile ?? 'Not set', Icons.phone_outlined, showBottomDivider: false),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('Professional Details'),
                _buildInfoCard([
                  _buildInfoRow('Specialization', profile.specialization ?? 'Not set', Icons.medical_services_outlined),
                  _buildInfoRow('Experience', '${profile.yearsOfExperience ?? 0} Years', Icons.history_edu_outlined),
                  _buildInfoRow('Bio', profile.bio != null && profile.bio!.isNotEmpty ? profile.bio! : 'Not provided', Icons.info_outline, showBottomDivider: false),
                ]),
                if (profile.skills.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills'),
                  _buildSkillsCard(profile.skills),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(NurseProfile profile) {
    final userName = profile.userName ?? 'Nurse';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'N';
    final specialization = profile.specialization ?? 'Registered Nurse';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary500,
            AppColors.primary400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary500.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                userInitial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and Specialization
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialization,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool showBottomDivider = true}) {
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
                  color: AppColors.primary50.withOpacity(0.5),
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
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showBottomDivider)
          Divider(height: 1, thickness: 1, color: Colors.grey[100], indent: 64),
      ],
    );
  }

  Widget _buildSkillsCard(List<String> skills) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills
            .map(
              (skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary500.withOpacity(0.2)),
                ),
                child: Text(
                  skill.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
