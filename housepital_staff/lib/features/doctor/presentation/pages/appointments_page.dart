import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/appointment_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';
import '../widgets/empty_state_widget.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<AppointmentCubit>().fetchAppointments();
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      return DateFormat('EEE, d MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _bookingId(dynamic b) => (b['_id'] ?? b['id'] ?? '') as String;

  String _priceText(dynamic price) {
    if (price == null) return '0 EGP';
    return '$price EGP';
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentCubit, AppointmentState>(
      listener: (ctx, state) {
        if (state is AppointmentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DoctorTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state is AppointmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DoctorTheme.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: DoctorTheme.background,
        body: BackgroundBlobs(
          child: SafeArea(
            child: Column(
              children: [
                GlassHeader(
                  title: 'Appointments',
                  subtitle: 'Manage your patient visits',
                  onBack: () => Navigator.maybePop(context),
                  actionIcon: Icons.refresh_rounded,
                  actionTooltip: 'Refresh',
                  onAction: () =>
                      context.read<AppointmentCubit>().fetchAppointments(),
                ),
                _buildSegmentedTabs(),
                Expanded(
                  child: BlocBuilder<AppointmentCubit, AppointmentState>(
                    builder: (context, state) {
                      if (state is AppointmentLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: DoctorTheme.primary,
                          ),
                        );
                      }
                      if (state is AppointmentError) {
                        return _buildErrorState(state.message);
                      }
                      if (state is! AppointmentLoaded) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: DoctorTheme.primary,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () =>
                            context.read<AppointmentCubit>().fetchAppointments(),
                        color: DoctorTheme.primary,
                        child: IndexedStack(
                          index: _selectedTab,
                          children: [
                            _buildPendingTab(state.pending),
                            _buildUpcomingTab(state.upcoming),
                            _buildPastTab(state.past),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Segmented Tab Bar ──────────────────────────────────────────────────

  Widget _buildSegmentedTabs() {
    final tabs = [
      (icon: Icons.pending_actions_rounded, label: 'Requests'),
      (icon: Icons.upcoming_rounded, label: 'Upcoming'),
      (icon: Icons.history_rounded, label: 'Past'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: DoctorTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DoctorTheme.border),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: DoctorTheme.heroGradient,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: DoctorTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tabs[index].icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : DoctorTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : DoctorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: DoctorTheme.danger.withValues(alpha: 0.6)),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: DoctorTheme.bodyMedium),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<AppointmentCubit>().fetchAppointments(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DoctorTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Pending ─────────────────────────────────────────────────────

  Widget _buildPendingTab(List<dynamic> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline_rounded,
        title: 'No pending requests',
        subtitle: 'Appointment requests awaiting your approval appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildPendingCard(list[i]),
    );
  }

  Widget _buildPendingCard(dynamic b) {
    final id = _bookingId(b);
    final cubit = context.read<AppointmentCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DoctorTheme.surface,
        borderRadius: BorderRadius.circular(DoctorTheme.radiusMD),
        border: Border.all(color: DoctorTheme.warningLight),
        boxShadow: [
          BoxShadow(
            color: DoctorTheme.warning.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Awaiting Confirmation',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    _formatDate(b['scheduledDate'] as String?),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DoctorTheme.warningLight,
                        borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
                      ),
                      child: const Icon(Icons.medical_services_rounded, color: Color(0xFFF59E0B), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text('${b['patientName'] ?? 'Patient'}', style: DoctorTheme.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_priceText(b['servicePrice']),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF59E0B))),
                        if (b['scheduledTime'] != null)
                          Text(b['scheduledTime'], style: DoctorTheme.caption),
                      ],
                    ),
                  ],
                ),
                if (b['notes'] != null && (b['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DoctorTheme.surfaceDim,
                      borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 14, color: DoctorTheme.textHint),
                        const SizedBox(width: 8),
                        Expanded(child: Text(b['notes'], style: DoctorTheme.caption)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Accept', icon: Icons.check_rounded,
                        color: DoctorTheme.success, onTap: () => cubit.confirmAppointment(id),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: 'Reject', icon: Icons.close_rounded,
                        color: DoctorTheme.danger, outlined: true,
                        onTap: () => cubit.rejectAppointment(id),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Upcoming ───────────────────────────────────────────────────────

  Widget _buildUpcomingTab(List<dynamic> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'No upcoming appointments',
        subtitle: 'Confirmed visits will appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildUpcomingCard(list[i]),
    );
  }

  Widget _buildUpcomingCard(dynamic b) {
    final id = _bookingId(b);
    final cubit = context.read<AppointmentCubit>();
    final status = b['status'] ?? 'confirmed';
    final isInProgress = status == 'in-progress';
    final isQueue = b['timeOption'] == 'queue';

    final accentColor = isInProgress ? DoctorTheme.warning : DoctorTheme.primary;
    final statusLabel = isInProgress ? 'In Progress' : 'Confirmed';
    final statusIcon = isInProgress ? Icons.play_circle_rounded : Icons.check_circle_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DoctorTheme.surface,
        borderRadius: BorderRadius.circular(DoctorTheme.radiusSM),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
                  ),
                  child: Icon(
                    isQueue ? Icons.people_rounded : Icons.local_hospital_rounded,
                    color: accentColor, size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(b['patientName'] ?? 'Patient', style: DoctorTheme.bodySmall),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: accentColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isQueue
                                  ? _formatDate(b['scheduledDate'] as String?)
                                  : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                              style: DoctorTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: accentColor, size: 13),
                          const SizedBox(width: 4),
                          Text(statusLabel, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${b['servicePrice'] ?? 0} EGP',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DoctorTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isInProgress)
              _actionButton(label: 'Complete visit', icon: Icons.task_alt_rounded, color: DoctorTheme.success, onTap: () => cubit.completeVisit(id))
            else
              _actionButton(label: 'Start visit', icon: Icons.play_arrow_rounded, color: DoctorTheme.primary, onTap: () => cubit.startVisit(id)),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Past ───────────────────────────────────────────────────────────

  Widget _buildPastTab(List<dynamic> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history_rounded,
        title: 'No past appointments',
        subtitle: 'Completed and cancelled visits will appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        final color = b['status'] == 'cancelled' ? DoctorTheme.danger : DoctorTheme.success;
        return _buildPastCard(b, color);
      },
    );
  }

  Widget _buildPastCard(dynamic b, Color accentColor) {
    final status = b['status'] ?? '';
    final isQueue = b['timeOption'] == 'queue';

    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'confirmed': statusLabel = 'Confirmed'; statusIcon = Icons.check_circle_rounded; break;
      case 'completed': statusLabel = 'Completed'; statusIcon = Icons.task_alt_rounded; break;
      case 'cancelled': statusLabel = 'Cancelled'; statusIcon = Icons.cancel_rounded; break;
      default: statusLabel = status; statusIcon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DoctorTheme.surface,
        borderRadius: BorderRadius.circular(DoctorTheme.radiusSM),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
              ),
              child: Icon(isQueue ? Icons.people_rounded : Icons.local_hospital_rounded, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(b['patientName'] ?? 'Patient', style: DoctorTheme.bodySmall),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: accentColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isQueue
                              ? _formatDate(b['scheduledDate'] as String?)
                              : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                          style: DoctorTheme.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: accentColor, size: 13),
                      const SizedBox(width: 4),
                      Text(statusLabel, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('${b['servicePrice'] ?? 0} EGP',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DoctorTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: outlined ? DoctorTheme.surface : color,
          borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
          border: outlined ? Border.all(color: color) : null,
          boxShadow: outlined
              ? null
              : [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: outlined ? color : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: outlined ? color : Colors.white)),
          ],
        ),
      ),
    );
  }
}
