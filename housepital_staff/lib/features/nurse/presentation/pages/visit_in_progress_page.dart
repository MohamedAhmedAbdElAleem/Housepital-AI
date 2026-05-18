import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/visit_report_data.dart';
import '../../data/services/visit_report_pdf_service.dart';
import '../cubit/nurse_booking_cubit.dart';
import '../widgets/visit_report_form.dart';

/// Full-screen page the nurse sees **while a visit is in progress**.
///
/// Displayed after the 4-digit PIN is verified and the visit starts.
/// Houses a live duration timer, patient/service info, a visit-report
/// text field, and the "Complete Visit" action button.
class VisitInProgressPage extends StatefulWidget {
  final NurseBooking booking;

  const VisitInProgressPage({super.key, required this.booking});

  @override
  State<VisitInProgressPage> createState() => _VisitInProgressPageState();
}

class _VisitInProgressPageState extends State<VisitInProgressPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;
  bool _isCompleting = false;

  // Visit report state
  late VisitReportData _reportData;

  // Nurse name (loaded from prefs for PDF header)
  String _nurseName = 'Nurse';
  bool _pdfGenerating = false;

  // Scroll controller to jump to the report section on validation failure
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reportSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _reportData = VisitReportData(
      servicesPerformed: [widget.booking.serviceName],
    );

    // Load nurse name from JWT for PDF header
    TokenManager.getUserFromToken().then((user) {
      if (mounted && user != null) {
        setState(() {
          _nurseName = (user['name'] as String?) ??
              (user['fullName'] as String?) ??
              'Nurse';
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start counting from visitStartedAt or now
    final visitStartedAt = widget.booking.visitStartedAt ?? DateTime.now();
    _elapsed = DateTime.now().difference(visitStartedAt);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(visitStartedAt);
        });
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns a human-readable list of missing required fields.
  List<String> get _missingFields {
    final missing = <String>[];
    if (_reportData.bpSystolic == null || _reportData.bpDiastolic == null) {
      missing.add('Blood Pressure');
    }
    if (_reportData.heartRate == null) missing.add('Heart Rate');
    if (_reportData.temperature == null) missing.add('Temperature');
    if (_reportData.oxygenSaturation == null) missing.add('SpO₂');
    if (_reportData.servicesPerformed.isEmpty) missing.add('Services Performed');
    return missing;
  }

  void _confirmCompleteVisit() {
    if (!_reportData.isReadyToSubmit) {
      // Scroll to the report section so the nurse can see what's missing
      _scrollToReportSection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Missing: ${_missingFields.join(', ')}. Please fill required fields first.',
          ),
          backgroundColor: AppColors.warning500,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'GO TO FORM',
            textColor: Colors.white,
            onPressed: _scrollToReportSection,
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success500,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Complete Visit?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will finalize the visit and deduct the platform commission from your wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.light100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow('Patient', widget.booking.patientName),
                  const SizedBox(height: 8),
                  _summaryRow('Service', widget.booking.serviceName),
                  const SizedBox(height: 8),
                  _summaryRow('Duration', _formatDuration(_elapsed)),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'Condition',
                    _reportData.overallCondition.toUpperCase(),
                  ),
                  if (_reportData.bpSystolic != null) ...[
                    const SizedBox(height: 8),
                    _summaryRow(
                      'BP',
                      '${_reportData.bpSystolic}/${_reportData.bpDiastolic} mmHg',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _doCompleteVisit();
                    },
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text(
                      'Complete Visit',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _doCompleteVisit() async {
    setState(() => _isCompleting = true);
    _durationTimer?.cancel();

    context.read<NurseBookingCubit>().completeVisit(
          widget.booking.id,
          reportData: _reportData,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NurseBookingCubit, NurseBookingState>(
      listener: (context, state) {
        if (state is NurseBookingCompleted) {
          _showSuccessAndReturn();
        } else if (state is NurseBookingError) {
          setState(() => _isCompleting = false);
          // Restart timer
          final visitStartedAt =
              widget.booking.visitStartedAt ?? DateTime.now();
          _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
            if (mounted) {
              setState(() {
                _elapsed = DateTime.now().difference(visitStartedAt);
              });
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: PopScope(
        canPop: false, // Prevent accidental back navigation
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _isCompleting
                ? _buildCompletingView()
                : _buildActiveVisitContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              color: AppColors.success500,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Completing Visit...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Calculating commission & finalizing...',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showSuccessAndReturn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated check
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppColors.success50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success500,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Visit Completed! 🎉',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Great job! The commission has been processed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stats strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.light100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem(Icons.timer_outlined,
                            _formatDuration(_elapsed)),
                        Container(
                            width: 1,
                            height: 24,
                            color: AppColors.light500),
                        _statItem(Icons.medical_services_outlined,
                            widget.booking.serviceName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── PDF Buttons ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Visit Report PDF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Preview button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pdfGenerating
                              ? null
                              : () async {
                                  setDialogState(
                                      () => _pdfGenerating = true);
                                  try {
                                    await VisitReportPdfService().preview(
                                      widget.booking,
                                      _reportData,
                                      _nurseName,
                                      _elapsed,
                                    );
                                  } finally {
                                    if (mounted) {
                                      setDialogState(() =>
                                          _pdfGenerating = false);
                                    }
                                  }
                                },
                          icon: const Icon(Icons.visibility_rounded,
                              size: 16),
                          label: const Text('Preview',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary500,
                            side: const BorderSide(
                                color: AppColors.primary500),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Download / Share button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pdfGenerating
                              ? null
                              : () async {
                                  setDialogState(
                                      () => _pdfGenerating = true);
                                  try {
                                    await VisitReportPdfService().share(
                                      widget.booking,
                                      _reportData,
                                      _nurseName,
                                      _elapsed,
                                    );
                                  } finally {
                                    if (mounted) {
                                      setDialogState(() =>
                                          _pdfGenerating = false);
                                    }
                                  }
                                },
                          icon: _pdfGenerating
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                              : const Icon(
                                  Icons.download_rounded,
                                  size: 16),
                          label: Text(
                              _pdfGenerating ? 'Generating...' : 'Download',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Back to Home
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
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

  Widget _statItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary500),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _scrollToReportSection() {
    final context = _reportSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    } else {
      // Fallback: scroll to bottom of the scrollable area
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Widget _buildActiveVisitContent() {
    return Column(
      children: [
        // ── Header ──
        _buildHeader(),

        // ── Content ──
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timer Card
                _buildTimerCard(),
                const SizedBox(height: 20),

                // Patient Info
                _buildPatientCard(),
                const SizedBox(height: 20),

                // Service Details
                _buildServiceDetailsCard(),
                const SizedBox(height: 20),

                // Device Management
                _buildDeviceManagementCard(),
                const SizedBox(height: 20),

                // ── Required Fields Reminder ──
                if (!_reportData.isReadyToSubmit) _buildRequiredFieldsReminder(),
                if (!_reportData.isReadyToSubmit) const SizedBox(height: 12),

                // Visit Report
                _buildReportSection(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ),

        // ── Bottom Complete Button ──
        _buildBottomCompleteButton(),
      ],
    );
  }

  /// A banner shown above the report form reminding the nurse which fields
  /// are required before the visit can be completed.
  Widget _buildRequiredFieldsReminder() {
    final missing = _missingFields;
    if (missing.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _scrollToReportSection,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF3CD), Color(0xFFFFE69C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warning300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning300.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.warning500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.assignment_late_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required before completing visit:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: missing.map((field) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        field,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.warning600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated pulsing dot
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      AppColors.success500.withOpacity(0.5 + _pulseController.value * 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success500
                          .withOpacity(0.3 * _pulseController.value),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          const Text(
            'VISIT IN PROGRESS',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.success700,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDuration(_elapsed),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.success700,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A048)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.success500.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ELAPSED TIME',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatDuration(_elapsed),
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Started at ${_formatTime(widget.booking.visitStartedAt ?? DateTime.now())}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Patient name
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary50,
                child: Text(
                  widget.booking.patientName.isNotEmpty
                      ? widget.booking.patientName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary500,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.patientName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.booking.customerName !=
                        widget.booking.patientName)
                      Text(
                        'Booked by: ${widget.booking.customerName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),

              // Call button
              if (widget.booking.patientPhone != null &&
                  widget.booking.patientPhone!.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    final uri =
                        Uri(scheme: 'tel', path: widget.booking.patientPhone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.phone_rounded),
                  color: AppColors.primary500,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary50,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
            ],
          ),

          // Address
          if (widget.booking.address != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.light100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.warning500, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.booking.address!.fullAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: AppColors.secondary500,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Service Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _detailRow(Icons.medical_services_outlined, 'Service',
              widget.booking.serviceName),
          const SizedBox(height: 12),
          _detailRow(Icons.payments_outlined, 'Price',
              'EGP ${widget.booking.servicePrice.toStringAsFixed(0)}'),
          if (widget.booking.notes != null &&
              widget.booking.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _detailRow(Icons.note_outlined, 'Notes', widget.booking.notes!),
          ],
          const SizedBox(height: 12),
          _detailRow(
            Icons.schedule_outlined,
            'Type',
            widget.booking.isAsap ? 'ASAP (Immediate)' : 'Scheduled',
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.nurseDeviceManagement,
              arguments: {
                'bookingId': widget.booking.id,
                'patientId': widget.booking.patientId,
                'patientName': widget.booking.patientName,
              },
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device & Vitals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Monitor live patient vitals via device.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return KeyedSubtree(
      key: _reportSectionKey,
      child: VisitReportForm(
        initialService: widget.booking.serviceName,
        onChanged: (data) {
          setState(() => _reportData = data);
        },
      ),
    );
  }

  Widget _buildBottomCompleteButton() {
    final missing = _missingFields;
    final isReady = missing.isEmpty;
    final filledCount = 5 - missing.length; // 5 required fields total

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar showing required fields completion
            if (!isReady) ...[
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.warning600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Fill required vitals to complete ($filledCount/5 done)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _scrollToReportSection,
                    child: const Text(
                      'Fill now ↑',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: filledCount / 5,
                  minHeight: 5,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isReady ? AppColors.success500 : AppColors.warning500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmCompleteVisit,
                icon: Icon(
                  isReady
                      ? Icons.check_circle_rounded
                      : Icons.assignment_late_rounded,
                  size: 22,
                ),
                label: Text(
                  isReady ? 'Complete Visit' : 'Complete Visit (${missing.length} fields missing)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReady ? AppColors.success500 : AppColors.warning500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
