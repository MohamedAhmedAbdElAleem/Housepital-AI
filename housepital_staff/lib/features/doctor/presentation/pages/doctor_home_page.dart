import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../presentation/cubit/appointment_cubit.dart';
import '../../presentation/cubit/doctor_cubit.dart';
import '../../presentation/cubit/clinic_cubit.dart';
import '../../presentation/cubit/notification_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage>
    with TickerProviderStateMixin {
  // Colors now handled by DoctorTheme

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  List<_HomeAction> get _actions => [
    _HomeAction(
      title: 'my_profile'.tr(),
      subtitle: 'credentials_and_identity'.tr(),
      icon: Icons.person_outline,
      color: Color(0xFF2664EC),
      route: AppRoutes.doctorProfile,
    ),
    _HomeAction(
      title: 'my_clinics'.tr(),
      subtitle: 'locations_and_working_hours'.tr(),
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF00A8A8),
      route: AppRoutes.myClinics,
    ),
    _HomeAction(
      title: 'appointments'.tr(),
      subtitle: 'today_and_upcoming_visits'.tr(),
      icon: Icons.calendar_month_outlined,
      color: Color(0xFF0EA5E9),
      route: AppRoutes.myAppointments,
    ),
    _HomeAction(
      title: 'services'.tr(),
      subtitle: 'consultations_and_pricing'.tr(),
      icon: Icons.medical_services_outlined,
      color: Color(0xFF1746C0),
      route: AppRoutes.myServices,
    ),
    _HomeAction(
      title: 'my_wallet'.tr(),
      subtitle: 'balance_and_payments'.tr(),
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF8B5CF6),
      route: AppRoutes.doctorWallet,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _entryController.forward();

    // Fetch profile and clinics so dashboard data is fresh.
    context.read<DoctorCubit>().fetchProfile();
    context.read<ClinicCubit>().fetchClinics();
    context.read<AppointmentCubit>().fetchAppointments();
    context.read<NotificationCubit>().fetchNotifications();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) {
      if (cubit.state is AuthAuthenticated) {
        return (cubit.state as AuthAuthenticated).user;
      }
      return null;
    });

    final doctorName =
        user?.name.trim().isNotEmpty == true ? user!.name : 'Doctor';

    final clinicState = context.watch<ClinicCubit>().state;
    final doctorState = context.watch<DoctorCubit>().state;
    final appointmentState = context.watch<AppointmentCubit>().state;
    final notificationState = context.watch<NotificationCubit>().state;

    final clinicsCount =
        clinicState is ClinicLoaded ? clinicState.clinics.length : 0;

    final todayAppointments =
        appointmentState is AppointmentLoaded
            ? appointmentState.pending.length + appointmentState.upcoming.length
            : 0;

    final ratingValue =
        doctorState is DoctorProfileLoaded
            ? doctorState.profile.rating.toStringAsFixed(1)
            : '--';

    final isActive =
        doctorState is DoctorProfileLoaded
            ? doctorState.profile.isActive
            : false;

    final unreadCount =
        notificationState is NotificationLoaded
            ? notificationState.unreadCount
            : 0;

    final metrics = [
      _OverviewMetric(
        label: 'today'.tr(),
        value: '$todayAppointments',
        icon: Icons.today_outlined,
      ),
      _OverviewMetric(
        label: 'clinics'.tr(),
        value: '$clinicsCount',
        icon: Icons.apartment_outlined,
      ),
      _OverviewMetric(
        label: 'rating'.tr(),
        value: ratingValue,
        icon: Icons.star_border_rounded,
      ),
    ];

    return BlocListener<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is DoctorToggleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'wallet'.tr(),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.doctorWallet);
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: DoctorTheme.background(context),
        body: BackgroundBlobs(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 10, 18, 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildTopBar(context, doctorName, unreadCount),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverToBoxAdapter(
                        child: _buildHeroCard(doctorName, metrics, isActive),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 22, 18, 12),
                      sliver: SliverToBoxAdapter(
                        child: _buildSectionTitle(
                          title: 'quick_actions'.tr(),
                          subtitle: 'everything_you_need_in_one_place'.tr(),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final action = _actions[index];
                          return _buildActionCard(
                            context,
                            action: action,
                            index: index,
                          );
                        }, childCount: _actions.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.98,
                            ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 22, 18, 12),
                      sliver: SliverToBoxAdapter(
                        child: _buildSectionTitle(
                          title: 'today_snapshot'.tr(),
                          subtitle: 'keep_your_clinic_day_under_control'.tr(),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, 26),
                      sliver: SliverList.separated(
                        itemBuilder:
                            (context, index) => _buildSnapshotItem(index),
                        separatorBuilder:
                            (context, index) => SizedBox(height: 12),
                        itemCount: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    String doctorName,
    int unreadCount,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'welcome_back'.tr(),
                style: DoctorTheme.bodyMedium(context),
              ),
              SizedBox(height: 3),
              Text(
                doctorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DoctorTheme.headingLarge(context),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _CircleActionButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'notifications'.tr(),
              onTap: () => _showNotificationsPreview(context),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  constraints: BoxConstraints(minWidth: 18),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DoctorTheme.surface(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 10),
        _CircleActionButton(
          icon: Icons.logout_rounded,
          tooltip: 'logout'.tr(),
          onTap: () {
            context.read<AuthCubit>().logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroCard(String doctorName, List<_OverviewMetric> metrics, bool isActive) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: DoctorTheme.headerGradient(context),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusXL),
        boxShadow: DoctorTheme.headerShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'today_s_overview'.tr(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Active toggle
              GestureDetector(
                onTap: () {
                  context.read<DoctorCubit>().toggleActive(!isActive);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: isActive
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 6),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: DoctorTheme.surface(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        isActive
                            ? Icons.toggle_on_rounded
                            : Icons.toggle_off_rounded,
                        color: DoctorTheme.surface(context),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            'Dr. $doctorName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: DoctorTheme.surface(context),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ready_for_a_productive_clinic_day'.tr(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < metrics.length; i++) ...[
                Expanded(child: _buildMetricTile(metrics[i])),
                if (i < metrics.length - 1) SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(_OverviewMetric metric) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: Colors.white70, size: 18),
          SizedBox(height: 8),
          Text(
            metric.value,
            style: TextStyle(
              color: DoctorTheme.surface(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            metric.label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DoctorTheme.headingMedium(context),
        ),
        SizedBox(height: 2),
        Text(
          subtitle,
          style: DoctorTheme.bodyMedium(context),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required _HomeAction action,
    required int index,
  }) {
    final delay = 0.14 + (index * 0.12);
    final curved = CurvedAnimation(
      parent: _entryController,
      curve: Interval(delay.clamp(0.0, 0.75), 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, action.route),
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: DoctorTheme.surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: action.color.withValues(alpha: 0.16),
                width: 1.2,
              ),
              boxShadow: DoctorTheme.softShadow(context),
            ),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [
                          action.color.withValues(alpha: 0.2),
                          action.color.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  ),
                  const Spacer(),
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DoctorTheme.titleMedium(context),
                  ),
                  SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DoctorTheme.bodySmall(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotItem(int index) {
    final items = [
      (
        icon: Icons.schedule_rounded,
        title: 'no_pending_appointments_right_now'.tr(),
        subtitle: 'you_are_clear_for_the_next_time_block'.tr(),
      ),
      (
        icon: Icons.location_on_outlined,
        title: 'clinic_details_are_up_to_date'.tr(),
        subtitle: 'patients_can_discover_your_current_locations'.tr(),
      ),
      (
        icon: Icons.medical_services_outlined,
        title: 'services_are_visible_to_patients'.tr(),
        subtitle: 'keep_prices_and_descriptions_updated_regularly'.tr(),
      ),
    ];

    final item = items[index];

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DoctorTheme.border(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2664EC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: const Color(0xFF1746C0), size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: DoctorTheme.titleMedium(context).copyWith(fontSize: 14.5),
                ),
                SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: DoctorTheme.bodySmall(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationsPreview(BuildContext context) {
    context.read<NotificationCubit>().fetchNotifications();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: DoctorTheme.background(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: 420,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF1746C0),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'notifications'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2664EC),
                          ),
                        );
                      }

                      if (state is NotificationError) {
                        return Center(
                          child: Text(
                            'could_not_load_notifications'.tr(),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      if (state is! NotificationLoaded ||
                          state.notifications.isEmpty) {
                        return Center(
                          child: Text(
                            'no_new_notifications_right_now'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.notifications.length,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.notifications[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              context.read<NotificationCubit>().markAsRead(
                                item.id,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    item.isRead
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      item.isRead
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2664EC,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      size: 18,
                                      color: Color(0xFF1746C0),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          item.body.isEmpty
                                              ? 'tap_to_mark_as_read'.tr()
                                              : item.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: DoctorTheme.surface(context),
        elevation: 0,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF1746C0)),
          ),
        ),
      ),
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
}

class _OverviewMetric {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
