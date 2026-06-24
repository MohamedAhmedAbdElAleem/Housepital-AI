import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../cubit/nurse_booking_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class NurseHistoryPage extends StatefulWidget {
  const NurseHistoryPage({super.key});

  @override
  State<NurseHistoryPage> createState() => _NurseHistoryPageState();
}

class _NurseHistoryPageState extends State<NurseHistoryPage> {
  List<NurseBooking> _cachedHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<NurseBookingCubit>().fetchHistory();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('EEE, d MMM yyyy  •  HH:mm').format(dt.toLocal());
  }

  String _formatDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '--:--';
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    return '${hours > 0 ? '$hours h ' : ''}$minutes m';
  }

  String _translateService(String service) {
    // Basic mapping for common services
    switch (service.toLowerCase().replaceAll(' ', '_')) {
      case 'wound_care': return 'العناية بالجروح';
      case 'iv_insertion': return 'تركيب الكانيولا';
      case 'injections': 
      case 'injection': return 'الحقن';
      case 'blood_draw': return 'سحب الدم';
      case 'elderly_care': return 'رعاية المسنين';
      case 'patient_monitoring': return 'مراقبة المريض';
      case 'physiotherapy_support': return 'دعم العلاج الطبيعي';
      case 'baby_care': return 'رعاية الأطفال';
      case 'emergency_response': return 'الاستجابة للطوارئ';
      default: return service;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.history,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: theme.colorScheme.primary,
            tooltip: 'Refresh',
            onPressed: () => context.read<NurseBookingCubit>().fetchHistory(),
          ),
        ],
      ),
      body: BlocConsumer<NurseBookingCubit, NurseBookingState>(
        listener: (context, state) {
          if (state is NurseBookingHistoryLoading) {
            setState(() => _isLoading = true);
          } else if (state is NurseBookingHistoryLoaded) {
            setState(() {
              _cachedHistory = state.history;
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (_isLoading && _cachedHistory.isEmpty) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }

          if (_cachedHistory.isEmpty) {
            return _buildEmpty(l10n);
          }

          return RefreshIndicator(
            color: theme.colorScheme.primary,
            onRefresh: () => context.read<NurseBookingCubit>().fetchHistory(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _cachedHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildHistoryCard(_cachedHistory[index], index, l10n),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withAlpha(40),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noSessionsYet,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.historyEmptyDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(NurseBooking booking, int index, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = booking.status == 'completed';

    final Color accentColor = isCompleted ? Colors.green : Colors.red;
    final Color bgColor = accentColor.withAlpha(isDark ? 40 : 25);
    final IconData statusIcon = isCompleted ? Icons.task_alt_rounded : Icons.cancel_rounded;
    final String statusLabel = isCompleted ? l10n.completedStatus : l10n.cancelledStatus;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: accentColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(booking.visitEndedAt ?? booking.createdAt),
                  style: TextStyle(
                    color: accentColor.withAlpha(200),
                    fontSize: 11,
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
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _translateService(booking.serviceName),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.patientName,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(isDark ? 40 : 25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'EGP ${booking.servicePrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                if (booking.address != null) ...[
                  Divider(height: 20, color: theme.colorScheme.outline.withAlpha(50)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.address!.fullAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                if (isCompleted &&
                    booking.visitStartedAt != null &&
                    booking.visitEndedAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${l10n.durationLabel}: ${_formatDuration(booking.visitStartedAt, booking.visitEndedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
