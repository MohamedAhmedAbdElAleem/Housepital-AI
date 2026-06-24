import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../config/theme/theme_cubit.dart';
import '../../../../config/language/language_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class NurseSettingsPage extends StatelessWidget {
  const NurseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final langCubit = context.watch<LanguageCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.profile, theme),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.edit_outlined,
                title: l10n.editProfileData,
                showBottomDivider: false,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.nurseProfileCompletion,
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.appPreferences, theme),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle:
                    langCubit.state.languageCode == 'en'
                        ? 'English'
                        : 'العربية',
                onTap: () => _showLanguageDialog(context),
              ),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary50.withOpacity(
                              isDark ? 0.2 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: AppColors.primary500,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.darkMode,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                isDark
                                    ? l10n.darkThemeEnabled
                                    : l10n.lightThemeEnabled,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDark,
                          onChanged: (val) {
                            context.read<ThemeCubit>().setTheme(
                              val ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                          activeColor: AppColors.primary500,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.security, theme),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.lock_outline,
                title: l10n.changePassword,
                showBottomDivider: false,
                onTap: () => _showChangePasswordDialog(context),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle(l10n.about, theme),
            _buildSettingsCard(context, [
              _buildSettingsTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {
                  _showPolicyDialog(
                    context,
                    l10n.privacyPolicy,
                    l10n.privacyPolicyContent,
                  );
                },
              ),
              _buildSettingsTile(
                context,
                icon: Icons.description_outlined,
                title: l10n.termsOfService,
                showBottomDivider: false,
                onTap: () {
                  _showPolicyDialog(
                    context,
                    l10n.termsOfService,
                    l10n.termsOfServiceContent,
                  );
                },
              ),
              // Sign out
              _buildSettingsTile(
                context,
                icon: Icons.logout_rounded,
                title: l10n.signOut,
                iconColor: Colors.red,
                textColor: Colors.red,
                showBottomDivider: false,
                onTap: () => _showLogoutConfirmation(context, l10n),
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Text(
                l10n.appVersion,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(
                      theme.brightness == Brightness.dark ? 40 : 25,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${l10n.signOut}?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out of your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: theme.colorScheme.onSurface
                              .withAlpha(150),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withAlpha(100),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.goBack,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<LanguageCubit>();
                          context.read<ThemeCubit>();
                          context.read<AuthCubit>().logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.signOut),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final langCubit = context.read<LanguageCubit>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(
                  context,
                  'English',
                  'en',
                  langCubit.state.languageCode == 'en',
                  () {
                    langCubit.setLanguage('en');
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context,
                  'العربية',
                  'ar',
                  langCubit.state.languageCode == 'ar',
                  () {
                    langCubit.setLanguage('ar');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String label,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary500.withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? AppColors.primary500
                    : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected
                        ? AppColors.primary500
                        : theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary500,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.changePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.currentPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.passwordUpdated)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary500),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(content, style: const TextStyle(height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.closeButton),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    bool showBottomDivider = true,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseIconColor = iconColor ?? AppColors.primary500;
    final baseTextColor = textColor ?? theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: baseIconColor.withAlpha(isDark ? 30 : 25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: baseIconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: baseTextColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
          if (showBottomDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.dark400 : Colors.grey[100],
              indent: 64,
            ),
        ],
      ),
    );
  }
}
