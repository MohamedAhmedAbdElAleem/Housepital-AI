import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../cubit/nurse_booking_cubit.dart';

class NurseHistoryPage extends StatefulWidget {
  const NurseHistoryPage({super.key});

  @override
  State<NurseHistoryPage> createState() => _NurseHistoryPageState();
}

class _NurseHistoryPageState extends State<NurseHistoryPage> {
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
    if (start == null || end == null) return '—';
    final diff = end.difference(start);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Session History',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary500,
            ),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<NurseBookingCubit>().fetchHistory(),
          ),
        ],
      ),
      body: BlocBuilder<NurseBookingCubit, NurseBookingState>(
        builder: (context, state) {
          if (state is NurseBookingHistoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            );
          }

          if (state is NurseBookingHistoryLoaded) {
            if (state.history.isEmpty) {
              return _buildEmpty();
            }
            return RefreshIndicator(
              color: AppColors.primary500,
              onRefresh: () =>
                  context.read<NurseBookingCubit>().fetchHistory(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: state.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildHistoryCard(state.history[index], index),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary500),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
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
                color: AppColors.primary50,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 50,
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No sessions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your completed and cancelled visits will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(NurseBooking booking, int index) {
    final isCompleted = booking.status == 'completed';

    final Color accentColor =
        isCompleted ? AppColors.success500 : Colors.red.shade400;
    final Color bgColor =
        isCompleted ? AppColors.success50 : Colors.red.shade50;
    final IconData statusIcon =
        isCompleted ? Icons.task_alt_rounded : Icons.cancel_rounded;
    final String statusLabel = isCompleted ? 'Completed' : 'Cancelled';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
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
                    color: accentColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Body
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
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary500,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.serviceName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.patientName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'EGP ${booking.servicePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (booking.address != null) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking.address!.fullAddress,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
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
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Duration: ${_formatDuration(booking.visitStartedAt, booking.visitEndedAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
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
