import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../l10n/app_localizations.dart';

class NurseCredentialsPage extends StatelessWidget {
  const NurseCredentialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.credentials,
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
            return const Center(child: Text('No credentials data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Identifiers'),
                _buildInfoCard(context, [
                  _buildInfoRow(context, 'License Number', profile.licenseNumber ?? 'Not provided', Icons.badge_outlined, showBottomDivider: false),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Uploaded Documents'),
                _buildInfoCard(context, [
                  _buildDocumentRow(
                    context,
                    'National ID',
                    profile.nationalIdUrl,
                    Icons.credit_card_outlined,
                  ),
                  _buildDocumentRow(
                    context,
                    'Medical Degree / Certificate',
                    profile.degreeUrl,
                    Icons.school_outlined,
                  ),
                  _buildDocumentRow(
                    context,
                    'Professional License',
                    profile.licenseUrl,
                    Icons.verified_outlined,
                    showBottomDivider: false,
                  ),
                ]),
              ],
            ),
          );
        },
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
            crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _buildDocumentRow(BuildContext context, String label, String? url, IconData icon, {bool showBottomDivider = true}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasDocument = url != null && url.isNotEmpty;

    return Column(
      children: [
        InkWell(
          onTap: hasDocument ? () => _launchUrl(url) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasDocument 
                        ? AppColors.primary50.withAlpha(isDark ? 30 : 25) 
                        : theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: hasDocument ? AppColors.primary500 : theme.colorScheme.onSurface.withAlpha(100), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasDocument ? 'View Document' : 'Not Uploaded',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: hasDocument ? AppColors.primary500 : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDocument)
                  Icon(Icons.open_in_new, color: theme.colorScheme.onSurface.withAlpha(100), size: 20),
              ],
            ),
          ),
        ),
        if (showBottomDivider)
          Divider(height: 1, thickness: 1, color: theme.colorScheme.outline.withAlpha(50), indent: 64),
      ],
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $urlString');
    }
  }
}
