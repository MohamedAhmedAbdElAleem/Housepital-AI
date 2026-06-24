import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import '../cubit/nurse_booking_cubit.dart';
import 'pin_verification_page.dart';
import '../../../../l10n/app_localizations.dart';

class NurseTrackingPage extends StatelessWidget {
  final NurseBooking booking;

  const NurseTrackingPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.location, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary50.withAlpha(isDark ? 40 : 255),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.navigation_rounded, size: 60, color: AppColors.primary500),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    booking.status == 'on-the-way' ? 'Arriving Soon' : 'Preparing for Visit',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are navigating to the patient location',
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withAlpha(150)),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 10), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 25, backgroundColor: AppColors.primary50, child: const Icon(Icons.person, color: AppColors.primary500)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.patientName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                          Text(booking.serviceName, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.green),
                      onPressed: () => launchUrl(Uri.parse('tel:${booking.patientPhone}')),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                if (booking.address != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: theme.colorScheme.onSurface.withAlpha(100), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.location, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withAlpha(100))),
                            const SizedBox(height: 4),
                            Text(booking.address!.fullAddress, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.map_rounded, color: AppColors.primary500),
                        onPressed: () => launchUrl(Uri.parse('google.navigation:q=${booking.address!.lat},${booking.address!.lng}')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: theme.colorScheme.onSurface.withAlpha(150),
                          side: BorderSide(color: theme.colorScheme.outline.withAlpha(100)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(l10n.goBack),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PinVerificationPage(booking: booking)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(l10n.verifyVisit, style: const TextStyle(fontWeight: FontWeight.bold)),
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
}
