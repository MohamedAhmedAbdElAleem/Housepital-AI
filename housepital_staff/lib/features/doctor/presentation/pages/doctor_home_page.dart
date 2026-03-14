import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../presentation/cubit/appointment_cubit.dart';
import '../../presentation/cubit/doctor_cubit.dart';
import '../../presentation/cubit/clinic_cubit.dart';
import '../../presentation/cubit/notification_cubit.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage>
    with TickerProviderStateMixin {
  static const Color _bg = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);

  static const List<Color> _heroGradient = [
    Color(0xFF1136A8),
    Color(0xFF2664EC),
    Color(0xFF3498BB),
  ];

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final List<_HomeAction> _actions = const [
    _HomeAction(
      title: 'My Profile',
      subtitle: 'Credentials and identity',
      icon: Icons.person_outline,
      color: Color(0xFF2664EC),
      route: AppRoutes.doctorProfile,
    ),
    _HomeAction(
      title: 'My Clinics',
      subtitle: 'Locations and working hours',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFF00A8A8),
      route: AppRoutes.myClinics,
    ),
    _HomeAction(
      title: 'Appointments',
      subtitle: 'Today and upcoming visits',
      icon: Icons.calendar_month_outlined,
      color: Color(0xFF0EA5E9),
      route: AppRoutes.myAppointments,
    ),
    _HomeAction(
      title: 'Services',
      subtitle: 'Consultations and pricing',
      icon: Icons.medical_services_outlined,
      color: Color(0xFF1746C0),
      route: AppRoutes.myServices,
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

    final todayAppointments = appointmentState is AppointmentLoaded
        ? appointmentState.pending.length + appointmentState.upcoming.length
        : 0;

    final ratingValue = doctorState is DoctorProfileLoaded
        ? doctorState.profile.rating.toStringAsFixed(1)
        : '--';

    final unreadCount = notificationState is NotificationLoaded
        ? notificationState.unreadCount
        : 0;

    final metrics = [
      _OverviewMetric(
        label: 'Today',
        value: '$todayAppointments',
        icon: Icons.today_outlined,
      ),
      _OverviewMetric(
        label: 'Clinics',
        value: '$clinicsCount',
        icon: Icons.apartment_outlined,
      ),
      _OverviewMetric(
        label: 'Rating',
        value: ratingValue,
        icon: Icons.star_border_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -60,
            child: _buildBackgroundBlob(
              size: 260,
              gradient: const [Color(0x332664EC), Color(0x003498BB)],
            ),
          ),
          Positioned(
            top: 170,
            left: -110,
            child: _buildBackgroundBlob(
              size: 240,
              gradient: const [Color(0x25113AA8), Color(0x002664EC)],
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                      sliver: SliverToBoxAdapter(
                        child: _buildTopBar(context, doctorName, unreadCount),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverToBoxAdapter(
                        child: _buildHeroCard(doctorName, metrics),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                      sliver: SliverToBoxAdapter(
                        child: _buildSectionTitle(
                          title: 'Quick Actions',
                          subtitle: 'Everything you need in one place',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
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
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                      sliver: SliverToBoxAdapter(
                        child: _buildSectionTitle(
                          title: 'Today Snapshot',
                          subtitle: 'Keep your clinic day under control',
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 26),
                      sliver: SliverList.separated(
                        itemBuilder: (context, index) =>
                            _buildSnapshotItem(index),
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemCount: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob({
    required double size,
    required List<Color> gradient,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
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
                'Welcome back',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _textSecondary,
                      letterSpacing: 0.2,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                doctorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _CircleActionButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifications',
              onTap: () => _showNotificationsPreview(context),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  constraints: const BoxConstraints(minWidth: 18),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        _CircleActionButton(
          icon: Icons.logout_rounded,
          tooltip: 'Logout',
          onTap: () => context.read<AuthCubit>().logout(),
        ),
      ],
    );
  }

  Widget _buildHeroCard(String doctorName, List<_OverviewMetric> metrics) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: _heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1746C0).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today\'s Overview',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                    SizedBox(width: 6),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Dr. $doctorName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ready for a productive clinic day',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < metrics.length; i++) ...[
                Expanded(child: _buildMetricTile(metrics[i])),
                if (i < metrics.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(_OverviewMetric metric) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: Colors.white70, size: 18),
          const SizedBox(height: 8),
          Text(
            metric.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: const TextStyle(
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
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
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
              color: _surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: action.color.withValues(alpha: 0.16),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
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
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
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
        title: 'No pending appointments right now',
        subtitle: 'You are clear for the next time block.',
      ),
      (
        icon: Icons.location_on_outlined,
        title: 'Clinic details are up to date',
        subtitle: 'Patients can discover your current locations.',
      ),
      (
        icon: Icons.medical_services_outlined,
        title: 'Services are visible to patients',
        subtitle: 'Keep prices and descriptions updated regularly.',
      ),
    ];

    final item = items[index];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDBEAFE)),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: 420,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF1746C0),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2664EC),
                          ),
                        );
                      }

                      if (state is NotificationError) {
                        return Center(
                          child: Text(
                            'Could not load notifications',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      if (state is! NotificationLoaded ||
                          state.notifications.isEmpty) {
                        return const Center(
                          child: Text(
                            'No new notifications right now.',
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
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = state.notifications[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              context
                                  .read<NotificationCubit>()
                                  .markAsRead(item.id);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: item.isRead
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: item.isRead
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
                                      color: const Color(0xFF2664EC)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_rounded,
                                      size: 18,
                                      color: Color(0xFF1746C0),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          item.body.isEmpty
                                              ? 'Tap to mark as read'
                                              : item.body,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
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
        color: Colors.white,
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
