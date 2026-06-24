import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../../../l10n/app_localizations.dart';

class NurseReviewsPage extends StatelessWidget {
  const NurseReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.performanceReviews,
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
            return Center(child: Text(l10n.noPerformanceData));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, l10n.myPerformance),
                _buildPerformanceOverview(context, profile, l10n),
                const SizedBox(height: 32),
                _buildSectionTitle(context, l10n.patientReviewsTitle),
                _buildEmptyReviewsState(context, l10n),
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

  Widget _buildPerformanceOverview(BuildContext context, NurseProfile profile, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  profile.rating.toStringAsFixed(1),
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < profile.rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  '${profile.totalRatings} ${l10n.reviewsCountText}',
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150)),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: theme.colorScheme.outline.withAlpha(50),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Expanded(
            child: Column(
              children: [
                _buildStatRow(context, l10n.visitsStat, profile.completedVisits.toString(), Icons.check_circle, Colors.green),
                const SizedBox(height: 16),
                _buildStatRow(context, l10n.rateStat, '${profile.completionRate.toStringAsFixed(0)}%', Icons.speed, AppColors.primary500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(150)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyReviewsState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurface.withAlpha(50)),
          const SizedBox(height: 16),
          Text(
            l10n.noReviewsYet,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.patientFeedbackDesc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(150), height: 1.5),
          ),
        ],
      ),
    );
  }
}
