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
import '../../../../l10n/app_localizations.dart';

class VisitInProgressPage extends StatefulWidget {
  final NurseBooking booking;
  const VisitInProgressPage({super.key, required this.booking});
  @override
  State<VisitInProgressPage> createState() => _VisitInProgressPageState();
}

class _VisitInProgressPageState extends State<VisitInProgressPage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;
  bool _isCompleting = false;
  late VisitReportData _reportData;
  String _nurseName = 'Nurse';
  bool _pdfGenerating = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reportSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _reportData = VisitReportData(servicesPerformed: [widget.booking.serviceName]);
    TokenManager.getUserFromToken().then((user) {
      if (mounted && user != null) {
        setState(() { _nurseName = (user['name'] as String?) ?? (user['fullName'] as String?) ?? 'Nurse'; });
      }
    });
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    final visitStartedAt = widget.booking.visitStartedAt ?? DateTime.now();
    _elapsed = DateTime.now().difference(visitStartedAt);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) { setState(() { _elapsed = DateTime.now().difference(visitStartedAt); }); }
    });
  }

  @override
  void dispose() { _durationTimer?.cancel(); _pulseController.dispose(); _scrollController.dispose(); super.dispose(); }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  List<String> _getMissingFieldLabels(AppLocalizations l10n) {
    final missing = <String>[];
    if (_reportData.bpSystolic == null || _reportData.bpDiastolic == null) missing.add(l10n.bloodPressure);
    if (_reportData.heartRate == null) missing.add(l10n.heartRate);
    if (_reportData.temperature == null) missing.add(l10n.temperature);
    if (_reportData.oxygenSaturation == null) missing.add(l10n.oxygenSaturation);
    if (_reportData.servicesPerformed.isEmpty) missing.add(l10n.servicesPerformed.replaceAll(' *', ''));
    return missing;
  }

  void _confirmCompleteVisit() {
    final l10n = AppLocalizations.of(context)!;
    if (!_reportData.isReadyToSubmit) {
      _scrollToReportSection();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Missing: ${_getMissingFieldLabels(l10n).join(', ')}. Please fill required fields first.'),
        backgroundColor: AppColors.warning500, duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'GO TO FORM', textColor: Colors.white, onPressed: _scrollToReportSection),
      ));
      return;
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withAlpha(100), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 24),
          Container(width: 72, height: 72, decoration: BoxDecoration(color: AppColors.primary50.withAlpha(isDark ? 40 : 255), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary500, size: 40)),
          const SizedBox(height: 20),
          Text(l10n.confirmCompleteTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(l10n.confirmCompleteSub, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14, height: 1.4, fontFamily: 'Inter')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255), borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.outline.withAlpha(50))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _summaryRow(l10n.profile, widget.booking.patientName, theme),
              const SizedBox(height: 8),
              _summaryRow(l10n.home, widget.booking.serviceName, theme),
              const SizedBox(height: 8),
              _summaryRow(l10n.liveDuration, _formatDuration(_elapsed), theme),
              const SizedBox(height: 8),
              _summaryRow(l10n.overallCondition.replaceAll(' *', ''), _reportData.overallCondition.toUpperCase(), theme),
              if (_reportData.bpSystolic != null) ...[const SizedBox(height: 8), _summaryRow(l10n.bloodPressure, '${_reportData.bpSystolic}/${_reportData.bpDiastolic} mmHg', theme)],
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withAlpha(150), side: BorderSide(color: theme.colorScheme.outline.withAlpha(100)), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(l10n.goBack))),
            const SizedBox(width: 14),
            Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () { Navigator.pop(ctx); _doCompleteVisit(); }, icon: const Icon(Icons.check_rounded, size: 20), label: Text(l10n.completeVisit), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary500, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          ]),
        ]),
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150), fontWeight: FontWeight.w500))),
      Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface))),
    ]);
  }

  Future<void> _doCompleteVisit() async {
    setState(() => _isCompleting = true);
    _durationTimer?.cancel();
    context.read<NurseBookingCubit>().completeVisit(widget.booking.id, reportData: _reportData);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<NurseBookingCubit, NurseBookingState>(
      listener: (context, state) {
        if (state is NurseBookingCompleted) { _showSuccessAndReturn(); }
        else if (state is NurseBookingError) {
          setState(() => _isCompleting = false);
          final visitStartedAt = widget.booking.visitStartedAt ?? DateTime.now();
          _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) { setState(() { _elapsed = DateTime.now().difference(visitStartedAt); }); } });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
        }
      },
      child: PopScope(canPop: false, child: Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: SafeArea(child: _isCompleting ? _buildCompletingView(theme, l10n) : _buildActiveVisitContent()))),
    );
  }

  Widget _buildCompletingView(ThemeData theme, AppLocalizations l10n) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(width: 56, height: 56, child: CircularProgressIndicator(color: AppColors.primary500, strokeWidth: 3)),
      const SizedBox(height: 24),
      Text(l10n.completeVisit + '...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, fontFamily: 'Poppins')),
      const SizedBox(height: 8),
      Text('Finalizing...', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14, fontFamily: 'Inter')),
    ]));
  }

  void _showSuccessAndReturn() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) { return StatefulBuilder(builder: (ctx, setDialogState) { return PopScope(canPop: false, child: Dialog(
        backgroundColor: Colors.transparent, insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 80 : 20), blurRadius: 40, offset: const Offset(0, 20))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(32), child: Stack(children: [
            Positioned(top: -50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary50.withAlpha(isDark ? 20 : 100)))),
            Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
              TweenAnimationBuilder<double>(tween: Tween(begin: 0.0, end: 1.0), duration: const Duration(milliseconds: 800), curve: Curves.elasticOut, builder: (context, value, child) {
                return Transform.scale(scale: value, child: Container(width: 90, height: 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary600, AppColors.primary400], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary500.withAlpha(60), blurRadius: 20, offset: const Offset(0, 10))]), child: const Icon(Icons.check_rounded, color: Colors.white, size: 50)));
              }),
              const SizedBox(height: 24),
              Text(l10n.visitCompleted, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, fontFamily: 'Poppins')),
              const SizedBox(height: 8),
              Text(l10n.visitCompletedSub, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14, height: 1.5, fontFamily: 'Inter')),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255), borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.colorScheme.outline.withAlpha(50))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _modernStatItem(Icons.timer_outlined, l10n.liveDuration, _formatDuration(_elapsed), theme),
                  Container(width: 1, height: 30, color: theme.colorScheme.outline.withAlpha(100)),
                  _modernStatItem(Icons.medical_services_outlined, l10n.home, widget.booking.serviceName, theme),
                ]),
              ),
              const SizedBox(height: 28),
              Align(alignment: Alignment.centerLeft, child: Text(l10n.documentation, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withAlpha(100), letterSpacing: 1.2))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(onPressed: _pdfGenerating ? null : () async { setDialogState(() => _pdfGenerating = true); try { await VisitReportPdfService().share(widget.booking, _reportData, _nurseName, _elapsed); } finally { if (mounted) { setDialogState(() => _pdfGenerating = false); } } }, icon: _pdfGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.share_rounded, size: 18), label: Text(l10n.sharePdf), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
              ]),
              const SizedBox(height: 12),
              TextButton(onPressed: _pdfGenerating ? null : () async { setDialogState(() => _pdfGenerating = true); try { await VisitReportPdfService().preview(widget.booking, _reportData, _nurseName, _elapsed); } finally { if (mounted) { setDialogState(() => _pdfGenerating = false); } } }, child: Text(l10n.previewReport, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, letterSpacing: 0.5))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.onSurface, foregroundColor: theme.colorScheme.surface, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(l10n.backToHome, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)))),
            ])),
          ])),
        ),
      )); }); },
    );
  }

  Widget _modernStatItem(IconData icon, String label, String value, ThemeData theme) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 20, color: AppColors.primary500), const SizedBox(height: 8),
      Text(label.toUpperCase(), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withAlpha(100), fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: theme.colorScheme.onSurface)),
    ]);
  }

  void _scrollToReportSection() {
    final context = _reportSectionKey.currentContext;
    if (context != null) { Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.0); }
    else if (_scrollController.hasClients) { _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut); }
  }

  Widget _buildActiveVisitContent() {
    return Stack(children: [
      _buildHeader(),
      SafeArea(child: SingleChildScrollView(controller: _scrollController, padding: const EdgeInsets.only(top: 140, left: 20, right: 20, bottom: 120), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildTimerCard(), const SizedBox(height: 20),
        _buildPatientCard(), const SizedBox(height: 20),
        _buildServiceDetailsCard(), const SizedBox(height: 20),
        _buildDeviceManagementCard(), const SizedBox(height: 20),
        if (!_reportData.isReadyToSubmit) _buildRequiredFieldsReminder(),
        if (!_reportData.isReadyToSubmit) const SizedBox(height: 12),
        _buildReportSection(),
      ]))),
      _buildBottomCompleteButton(),
    ]);
  }
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 240, width: double.infinity,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary700, AppColors.primary500], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))),
      child: Stack(children: [
        Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(20)))),
        SafeArea(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(animation: _pulseController, builder: (context, child) { return Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.6 + _pulseController.value * 0.4), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.4 * _pulseController.value), blurRadius: 8, spreadRadius: 2)])); }),
            const SizedBox(width: 12),
            Text(l10n.visitInProgress, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
          ]),
          const SizedBox(height: 20),
          Text(_formatDuration(_elapsed), style: const TextStyle(fontFamily: 'monospace', fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(l10n.liveDuration, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withAlpha(180), letterSpacing: 2)),
        ]))),
      ]),
    );
  }

  Widget _buildTimerCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 10), blurRadius: 20, offset: const Offset(0, 10))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(28), child: Stack(children: [
        Positioned(bottom: -30, right: -30, child: Icon(Icons.timer_outlined, size: 100, color: AppColors.primary50.withAlpha(isDark ? 30 : 150))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.sessionOverview, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 16),
          Row(children: [
            _buildMiniStat(Icons.calendar_today_rounded, l10n.started, TimeOfDay.fromDateTime(widget.booking.visitStartedAt ?? DateTime.now()).format(context)),
            const SizedBox(width: 24),
            _buildMiniStat(Icons.medical_services_rounded, l10n.type, l10n.inPerson),
          ]),
        ]),
      ])),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary50.withAlpha(isDark ? 40 : 255), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: AppColors.primary600)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withAlpha(100), letterSpacing: 0.5)),
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
      ]),
    ]);
  }

  Widget _buildPatientCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 40 : 100))),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary500, width: 2)), child: CircleAvatar(radius: 28, backgroundColor: theme.colorScheme.primaryContainer.withAlpha(isDark ? 50 : 255), child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 30))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.booking.patientName, style: TextStyle(fontFamily: 'Poppins', fontSize: 17, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          Text(l10n.patientRecord + ' #12345', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150))),
        ])),
        IconButton(onPressed: () {}, icon: Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary)),
      ]),
    );
  }

  Widget _buildServiceDetailsCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.secondary700, AppColors.secondary500], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.secondary500.withAlpha(40), blurRadius: 15, offset: const Offset(0, 8))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: Stack(children: [
        Positioned(bottom: -20, right: -20, child: Icon(Icons.medical_information_rounded, size: 80, color: Colors.white.withAlpha(30))),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.serviceDetails, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(widget.booking.serviceName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.payments_rounded, color: Colors.white, size: 16), const SizedBox(width: 8),
            Text('${l10n.egp} ${widget.booking.servicePrice.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ]),
      ])),
    );
  }

  Widget _buildRequiredFieldsReminder() {
    final l10n = AppLocalizations.of(context)!;
    final missingCount = _getMissingFieldLabels(l10n).length;
    if (missingCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _scrollToReportSection,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.warning50.withAlpha(Theme.of(context).brightness == Brightness.dark ? 40 : 255), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.warning300.withAlpha(100), width: 1)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.warning500, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.assignment_late_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.completeReportForm, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? AppColors.warning200 : AppColors.warning700)),
            Text(l10n.fieldsRemaining(missingCount), style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: (Theme.of(context).brightness == Brightness.dark ? AppColors.warning200 : AppColors.warning700).withAlpha(180))),
          ])),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).brightness == Brightness.dark ? AppColors.warning200 : AppColors.warning600),
        ]),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(key: _reportSectionKey, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(l10n.visitReport, style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface, letterSpacing: 1))),
      VisitReportForm(initialService: widget.booking.serviceName, prefill: _reportData, onChanged: (updated) { setState(() => _reportData = updated); }),
    ]);
  }

  Widget _buildBottomCompleteButton() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: theme.colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 80 : 30), blurRadius: 15, offset: const Offset(0, -5))]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (!_reportData.isReadyToSubmit) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error), const SizedBox(width: 8), Text(l10n.fillVitalsToComplete, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600))])),
          Container(
            width: double.infinity, height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: LinearGradient(colors: _reportData.isReadyToSubmit ? [AppColors.primary700, AppColors.primary500] : [Colors.grey[400]!, Colors.grey[300]!]), boxShadow: _reportData.isReadyToSubmit ? [BoxShadow(color: AppColors.primary500.withAlpha(80), blurRadius: 12, offset: const Offset(0, 6))] : null),
            child: ElevatedButton(onPressed: _reportData.isReadyToSubmit ? _confirmCompleteVisit : null, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, shadowColor: Colors.transparent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: Text(l10n.completeVisit, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1))),
          ),
        ]),
      ),
    );
  }
}
