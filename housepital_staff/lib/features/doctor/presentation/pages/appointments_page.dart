import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/appointment_cubit.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _bg = Color(0xFFF4F8FF);
  static const _surface = Color(0xFFFFFFFF);
  static const _primary = Color(0xFF2664EC);
  static const _primaryDark = Color(0xFF1136A8);
  static const _secondary = Color(0xFF3498BB);
  static const _warning = Color(0xFFF59E0B);
  static const _success = Color(0xFF16A34A);
  static const _danger = Color(0xFFDC2626);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF475569);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AppointmentCubit>().fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentCubit, AppointmentState>(
      listener: (ctx, state) {
        if (state is AppointmentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
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
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('المواعيد'),
          backgroundColor: _orange,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed:
                  () => context.read<AppointmentCubit>().fetchAppointments(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions_rounded, size: 18),
                text: 'طلبات',
              ),
              Tab(icon: Icon(Icons.upcoming_rounded, size: 18), text: 'قادمة'),
              Tab(icon: Icon(Icons.history_rounded, size: 18), text: 'السابقة'),
            ],
          ),
        ),
        body: BlocBuilder<AppointmentCubit, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return const Center(
                child: CircularProgressIndicator(color: _orange),
              );
            }
            if (state is AppointmentError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          () =>
                              context
                                  .read<AppointmentCubit>()
                                  .fetchAppointments(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is! AppointmentLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: _orange),
              );
            }

            return RefreshIndicator(
              onRefresh:
                  () => context.read<AppointmentCubit>().fetchAppointments(),
              color: _orange,
              child: TabBarView(
                controller: _tabController,
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
    );
  }

  // ── Tab 1: Pending (slot bookings waiting for doctor confirm) ─────────────

  Widget _buildPendingTab(List<dynamic> list) {
    if (list.isEmpty) {
      return _emptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'No pending requests',
        subtitle: 'Appointment requests awaiting your approval appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
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
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE6BF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'بانتظار التأكيد',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(b['scheduledDate'] as String?),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: Color(0xFFF59E0B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['serviceName'] ?? 'خدمة',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${b['patientName'] ?? 'مريض'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _priceText(b['servicePrice']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        if (b['scheduledTime'] != null)
                          Text(
                            b['scheduledTime'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (b['notes'] != null &&
                    (b['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notes_rounded,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b['notes'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Accept',
                        icon: Icons.check_rounded,
                        color: _success,
                        onTap: () => cubit.confirmAppointment(id),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: _danger,
                        outlined: true,
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
      return _emptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No upcoming appointments',
        subtitle: 'Confirmed visits will appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
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

    final accentColor = isInProgress ? _orange : _blue;
    final statusLabel = isInProgress ? 'جاري الكشف' : 'مؤكد';
    final statusIcon =
        isInProgress ? Icons.play_circle_rounded : Icons.check_circle_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isQueue
                        ? Icons.people_rounded
                        : Icons.local_hospital_rounded,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['serviceName'] ?? 'خدمة',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        b['patientName'] ?? 'مريض',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isQueue
                                ? _formatDate(b['scheduledDate'] as String?)
                                : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: accentColor, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${b['servicePrice'] ?? 0} جنيه',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isInProgress)
              _actionButton(
                label: 'Complete visit',
                icon: Icons.task_alt_rounded,
                color: _success,
                onTap: () => cubit.completeVisit(id),
              )
            else
              _actionButton(
                label: 'Start visit',
                icon: Icons.play_arrow_rounded,
                color: _primary,
                onTap: () => cubit.startVisit(id),
              ),
          ],
        ),
      ),
    );
  }

  // ── Tab 3: Past ───────────────────────────────────────────────────────────

  Widget _buildPastTab(List<dynamic> list) {
    if (list.isEmpty) {
      return _emptyState(
        icon: Icons.history_rounded,
        title: 'No past appointments',
        subtitle: 'Completed and cancelled visits will appear here.',
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        final color =
            b['status'] == 'cancelled' ? Colors.red : const Color(0xFF00B870);
        return _buildAppointmentCard(b, color);
      },
    );
  }

  Widget _buildAppointmentCard(dynamic b, Color accentColor) {
    final status = b['status'] ?? '';
    final isQueue = b['timeOption'] == 'queue';

    String statusLabel;
    IconData statusIcon;
    switch (status) {
      case 'confirmed':
        statusLabel = 'Confirmed';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'completed':
        statusLabel = 'Completed';
        statusIcon = Icons.task_alt_rounded;
        break;
      case 'cancelled':
        statusLabel = 'Cancelled';
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusLabel = status;
        statusIcon = Icons.info_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isQueue ? Icons.people_rounded : Icons.local_hospital_rounded,
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b['serviceName'] ?? 'خدمة',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    b['patientName'] ?? 'مريض',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isQueue
                            ? _formatDate(b['scheduledDate'] as String?)
                            : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: accentColor, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${b['servicePrice'] ?? 0} جنيه',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(12),
          border: outlined ? Border.all(color: color) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: outlined ? color : Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: outlined ? color : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _primary.withValues(alpha: 0.15),
                    _secondary.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Icon(icon, size: 42, color: _primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
