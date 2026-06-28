import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/appointment_cubit.dart';
import '../../../../core/network/api_client.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';
import '../widgets/empty_state_widget.dart';
import 'package:housepital_staff/features/nurse/data/services/visit_report_pdf_service.dart';

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
        backgroundColor: DoctorTheme.background(context),
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
                        return Center(
                          child: CircularProgressIndicator(
                            color: DoctorTheme.primary,
                          ),
                        );
                      }
                      if (state is AppointmentError) {
                        return _buildErrorState(state.message);
                      }
                      if (state is! AppointmentLoaded) {
                        return Center(
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
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: DoctorTheme.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DoctorTheme.border(context)),
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
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: DoctorTheme.heroGradient(context),
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
                            : DoctorTheme.textSecondary(context),
                      ),
                      SizedBox(width: 6),
                      Text(
                        tabs[index].label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : DoctorTheme.textSecondary(context),
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
          SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center, style: DoctorTheme.bodyMedium(context)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.read<AppointmentCubit>().fetchAppointments(),
            icon: Icon(Icons.refresh_rounded),
            label: Text('Retry'),
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildPendingCard(list[i]),
    );
  }

  Widget _buildPendingCard(dynamic b) {
    final id = _bookingId(b);
    final cubit = context.read<AppointmentCubit>();

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: DoctorTheme.surface(context), size: 16),
                SizedBox(width: 8),
                Text(
                  'Awaiting Confirmation',
                  style: TextStyle(color: DoctorTheme.surface(context), fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    _formatDate(b['scheduledDate'] as String?),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: DoctorTheme.warningLight,
                        borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
                      ),
                      child: Icon(Icons.medical_services_rounded, color: Color(0xFFF59E0B), size: 22),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium(context)),
                          SizedBox(height: 2),
                          Text('${b['patientName'] ?? 'Patient'}', style: DoctorTheme.bodySmall(context)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_priceText(b['servicePrice']),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF59E0B))),
                        if (b['scheduledTime'] != null)
                          Text(b['scheduledTime'], style: DoctorTheme.caption(context)),
                      ],
                    ),
                  ],
                ),
                if (b['notes'] != null && (b['notes'] as String).isNotEmpty) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DoctorTheme.surfaceDim(context),
                      borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 14, color: DoctorTheme.textHint(context)),
                        SizedBox(width: 8),
                        Expanded(child: Text(b['notes'], style: DoctorTheme.caption(context))),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Accept', icon: Icons.check_rounded,
                        color: DoctorTheme.success, onTap: () => cubit.confirmAppointment(id),
                      ),
                    ),
                    SizedBox(width: 10),
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
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
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusSM),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: accentColor.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
                  ),
                  child: Icon(
                    isQueue ? Icons.people_rounded : Icons.local_hospital_rounded,
                    color: accentColor, size: 22,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium(context)),
                      SizedBox(height: 3),
                      Text(b['patientName'] ?? 'Patient', style: DoctorTheme.bodySmall(context)),
                      SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: accentColor),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isQueue
                                  ? _formatDate(b['scheduledDate'] as String?)
                                  : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                              style: DoctorTheme.caption(context),
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
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: accentColor, size: 13),
                          SizedBox(width: 4),
                          Text(statusLabel, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('${b['servicePrice'] ?? 0} EGP',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DoctorTheme.textSecondary(context))),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Patient History',
                    icon: Icons.history_edu_rounded,
                    color: DoctorTheme.primary,
                    outlined: true,
                    onTap: () => _showPatientHistory(b),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: isInProgress
                      ? _actionButton(
                          label: 'Complete visit',
                          icon: Icons.task_alt_rounded,
                          color: DoctorTheme.success,
                          onTap: () => cubit.completeVisit(id),
                        )
                      : _actionButton(
                          label: 'Start visit',
                          icon: Icons.play_arrow_rounded,
                          color: DoctorTheme.primary,
                          onTap: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (_) => _PinVerificationDialog(bookingId: id),
                            );
                            if (result == true) {
                              cubit.fetchAppointments();
                            }
                          },
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPatientHistory(dynamic b) {
    dynamic rawPatientId = b['dependentId'] ?? b['patientId'];
    String? patientId;
    if (rawPatientId is String) {
      patientId = rawPatientId;
    } else if (rawPatientId is Map) {
      patientId = (rawPatientId['_id'] ?? rawPatientId['id'])?.toString();
    }

    dynamic rawPatientName = b['patientName'] ?? 'Patient';
    String patientName = 'Patient';
    if (rawPatientName is String) {
      patientName = rawPatientName;
    } else if (rawPatientName is Map) {
      patientName = (rawPatientName['name'] ?? rawPatientName['patientName'] ?? 'Patient').toString();
    }

    if (patientId == null || patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Patient Profile')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: _PatientHistoryModal(
          patientId: patientId!,
          patientName: patientName,
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
      padding: EdgeInsets.fromLTRB(16, 8, 16, 18),
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
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(DoctorTheme.radiusSM),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
        boxShadow: [BoxShadow(color: DoctorTheme.textPrimary(context).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DoctorTheme.radiusXS),
              ),
              child: Icon(isQueue ? Icons.people_rounded : Icons.local_hospital_rounded, color: accentColor, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['serviceName'] ?? 'Service', style: DoctorTheme.titleMedium(context)),
                  SizedBox(height: 3),
                  Text(b['patientName'] ?? 'Patient', style: DoctorTheme.bodySmall(context)),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: accentColor),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isQueue
                              ? _formatDate(b['scheduledDate'] as String?)
                              : '${_formatDate(b['scheduledDate'] as String?)}${b['scheduledTime'] != null ? '  ·  ${b['scheduledTime']}' : ''}',
                          style: DoctorTheme.caption(context),
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DoctorTheme.radiusChip),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: accentColor, size: 13),
                      SizedBox(width: 4),
                      Text(statusLabel, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                Text('${b['servicePrice'] ?? 0} EGP',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DoctorTheme.textSecondary(context))),
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
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: outlined ? DoctorTheme.surface(context) : color,
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
            SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: outlined ? color : Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _PinVerificationDialog extends StatefulWidget {
  final String bookingId;
  const _PinVerificationDialog({required this.bookingId});

  @override
  State<_PinVerificationDialog> createState() => _PinVerificationDialogState();
}

class _PinVerificationDialogState extends State<_PinVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (_pin.length != 4) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = ApiClient();
      await api.post('/bookings/${widget.bookingId}/verify-pin', body: {'pin': _pin});
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
        // Clear pin
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: DoctorTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: DoctorTheme.border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DoctorTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_person_rounded, color: DoctorTheme.primary, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Security Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DoctorTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask the patient for their 4-digit visit PIN to start this appointment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: DoctorTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    onChanged: (value) => _onDigitEntered(index, value),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DoctorTheme.primary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: DoctorTheme.surfaceDim(context),
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: DoctorTheme.border(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: DoctorTheme.primary, width: 2),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DoctorTheme.danger, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: DoctorTheme.textSecondary(context), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _pin.length != 4 ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: DoctorTheme.primary.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Verify & Start', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientHistoryModal extends StatefulWidget {
  final String patientId;
  final String patientName;

  const _PatientHistoryModal({
    required this.patientId,
    required this.patientName,
  });

  @override
  State<_PatientHistoryModal> createState() => _PatientHistoryModalState();
}

class _PatientHistoryModalState extends State<_PatientHistoryModal> {
  bool _isLoading = true;
  List<dynamic> _reports = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final api = ApiClient();
      final resp = await api.get('/bookings/patients/${widget.patientId}/visit-reports');
      final list = (resp is Map ? resp['reports'] : resp) as List? ?? [];
      if (mounted) {
        setState(() {
          _reports = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: DoctorTheme.background(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header Indicator
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DoctorTheme.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Records & History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DoctorTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Patient: ${widget.patientName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: DoctorTheme.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: DoctorTheme.textSecondary(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: DoctorTheme.border(context), height: 1),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: DoctorTheme.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: DoctorTheme.danger.withOpacity(0.7)),
              const SizedBox(height: 12),
              Text(
                'Failed to load history',
                style: TextStyle(fontWeight: FontWeight.bold, color: DoctorTheme.textPrimary(context)),
              ),
              const SizedBox(height: 4),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: DoctorTheme.textSecondary(context), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 64, color: DoctorTheme.textHint(context)),
              const SizedBox(height: 16),
              Text(
                'No past medical records found',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DoctorTheme.textPrimary(context)),
              ),
              const SizedBox(height: 6),
              Text(
                'All visit reports and clinical assessments will be archived here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: DoctorTheme.textSecondary(context)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildReportCard(dynamic r) {
    final dateStr = () {
      try {
        final created = r['createdAt'] as String?;
        if (created == null) return '—';
        return DateFormat('d MMM yyyy · hh:mm a').format(DateTime.parse(created));
      } catch (_) {
        return r['createdAt']?.toString() ?? '—';
      }
    }();

    final booking = r['bookingId'] ?? {};
    final serviceName = booking['serviceName'] ?? 'Nursing Visit';
    final nurse = r['nurseId'] ?? {};
    final nurseName = nurse['user']?['name'] ?? 'Assigned Nurse';

    final status = r['patientStatus'] ?? {};
    final condition = status['overallCondition'] ?? 'stable';
    final consciousness = status['consciousnessLevel'] ?? 'alert';
    final pain = status['painLevel'] ?? 0;
    final wound = status['woundSiteCondition'] ?? 'na';

    final vitals = r['vitals'] ?? {};
    final bp = vitals['bloodPressure'] ?? {};
    final bpSys = bp['systolic'];
    final bpDia = bp['diastolic'];
    final hr = vitals['heartRate'] ?? {};
    final temp = vitals['temperature'] ?? {};
    final spo2 = vitals['oxygenSaturation'] ?? {};

    final care = r['careProvided'] ?? {};
    final meds = care['medications'] as List? ?? [];
    final notes = r['notes'] ?? {};
    final observations = notes['clinicalObservations'] ?? '';
    final concerns = notes['patientFamilyConcerns'] ?? '';

    final followUp = r['followUp'] ?? {};
    final urgency = followUp['urgency'] ?? 'routine';
    final recommended = followUp['recommendedActions'] as List? ?? [];

    Color conditionColor;
    switch (condition.toString().toLowerCase()) {
      case 'excellent':
      case 'stable':
        conditionColor = DoctorTheme.success;
        break;
      case 'fair':
        conditionColor = DoctorTheme.warning;
        break;
      default:
        conditionColor = DoctorTheme.danger;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: DoctorTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DoctorTheme.border(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: DoctorTheme.primary,
          collapsedIconColor: DoctorTheme.textSecondary(context),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: DoctorTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By: $nurseName · $dateStr',
                      style: TextStyle(
                        fontSize: 12,
                        color: DoctorTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  condition.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: conditionColor,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),

                  // Consciousness & Pain & Wound
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo('Consciousness', consciousness.toString().toUpperCase()),
                      _buildMiniInfo('Pain Level', '$pain/10'),
                      _buildMiniInfo('Wound / IV', wound.toString().toUpperCase()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Vitals Grid
                  Text(
                    'VITAL SIGNS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: DoctorTheme.textHint(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                    children: [
                      _buildVitalTile(
                        'Blood Pressure',
                        bpSys != null && bpDia != null ? '$bpSys/$bpDia mmHg' : 'N/A',
                        bp['status'],
                        Icons.speed_rounded,
                      ),
                      _buildVitalTile(
                        'Heart Rate',
                        hr['value'] != null ? '${hr['value']} bpm' : 'N/A',
                        hr['status'],
                        Icons.favorite_rounded,
                      ),
                      _buildVitalTile(
                        'Temperature',
                        temp['value'] != null ? '${temp['value']} °C' : 'N/A',
                        temp['status'],
                        Icons.thermostat_rounded,
                      ),
                      _buildVitalTile(
                        'Oxygen (SpO₂)',
                        spo2['value'] != null ? '${spo2['value']} %' : 'N/A',
                        spo2['status'],
                        Icons.bubble_chart_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Medications
                  if (meds.isNotEmpty) ...[
                    Text(
                      'ADMINISTERED MEDICATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: DoctorTheme.textHint(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...meds.map((m) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Icon(Icons.lens, size: 6, color: DoctorTheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${m['name'] ?? ''} - ${m['dose'] ?? ''} (${m['route'] ?? ''})',
                              style: TextStyle(
                                fontSize: 13,
                                color: DoctorTheme.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // Clinical Observations
                  if (observations.isNotEmpty) ...[
                    Text(
                      'CLINICAL OBSERVATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: DoctorTheme.textHint(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      observations,
                      style: TextStyle(
                        fontSize: 13,
                        color: DoctorTheme.textPrimary(context),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Follow Up & Urgency
                  if (followUp['required'] == true) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DoctorTheme.warningLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DoctorTheme.warningLight.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: DoctorTheme.warning, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Follow-up Recommended',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: DoctorTheme.textPrimary(context),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                urgency.toString().toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                  color: DoctorTheme.warning,
                                ),
                              ),
                            ],
                          ),
                          if (recommended.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Recommended Actions: ${recommended.join(", ").replaceAll("_", " ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: DoctorTheme.textSecondary(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await VisitReportPdfService().previewFromRaw(r, widget.patientName);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error generating PDF: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('View Full PDF Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DoctorTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: DoctorTheme.textHint(context),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: DoctorTheme.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalTile(String label, String value, dynamic status, IconData icon) {
    Color statusColor;
    switch (status.toString().toLowerCase()) {
      case 'normal':
        statusColor = DoctorTheme.success;
        break;
      case 'high':
      case 'low':
        statusColor = DoctorTheme.warning;
        break;
      case 'critical':
        statusColor = DoctorTheme.danger;
        break;
      default:
        statusColor = DoctorTheme.textSecondary(context);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: DoctorTheme.surfaceDim(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DoctorTheme.border(context)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: DoctorTheme.textHint(context)),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: DoctorTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
