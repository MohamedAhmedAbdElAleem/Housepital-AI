import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/nurse_booking_cubit.dart';
import '../../data/models/booking_model.dart';
import '../../../../l10n/app_localizations.dart';

class PinVerificationPage extends StatefulWidget {
  final NurseBooking booking;

  const PinVerificationPage({super.key, required this.booking});

  @override
  State<PinVerificationPage> createState() => _PinVerificationPageState();
}

class _PinVerificationPageState extends State<PinVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _pin => _controllers.map((c) => c.text).join();

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 3) { _focusNodes[index + 1].requestFocus(); }
    else if (value.isEmpty && index > 0) { _focusNodes[index - 1].requestFocus(); }
    if (_pin.length == 4) { _verifyPin(); }
    setState(() { _errorMessage = null; });
  }

  Future<void> _verifyPin() async {
    if (_pin.length != 4) {
      setState(() { _errorMessage = 'Please enter all 4 digits'; }); // ARB needed for precise error?
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    await context.read<NurseBookingCubit>().verifyPinAndStartVisit(widget.booking.id, _pin);
    if (mounted) { setState(() { _isLoading = false; }); }
  }

  void _clearPin() {
    for (var c in _controllers) { c.clear(); }
    _focusNodes[0].requestFocus();
    setState(() { _errorMessage = null; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<NurseBookingCubit, NurseBookingState>(
        listener: (context, state) {
          if (state is NurseBookingError) {
            setState(() { _errorMessage = state.message; });
            _clearPin();
          } else if (state is NurseBookingInProgress) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        child: Stack(
          children: [
            Container(
              height: 260, width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary700, AppColors.primary500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(20)))),
                  Positioned(bottom: 20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withAlpha(15)))),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                              Expanded(child: Text(l10n.verifyVisit, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.5))),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(l10n.enterSecurityCode, style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(l10n.askPatientCode, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withAlpha(180), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 170, left: 24, right: 24, bottom: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 20), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary500, width: 2)),
                            child: CircleAvatar(radius: 30, backgroundColor: theme.colorScheme.primaryContainer.withAlpha(isDark ? 50 : 255), child: Icon(Icons.person_rounded, size: 35, color: theme.colorScheme.primary)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.booking.patientName, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                                Text(widget.booking.serviceName, style: TextStyle(fontFamily: 'Inter', color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(32), border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100))),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) => Flexible(
                                child: Container(
                                  height: 70, constraints: const BoxConstraints(maxWidth: 60), margin: const EdgeInsets.symmetric(horizontal: 4),
                                  child: TextField(
                                    controller: _controllers[index], focusNode: _focusNodes[index], onChanged: (value) => _onDigitEntered(index, value),
                                    textAlign: TextAlign.center, keyboardType: TextInputType.number,
                                    inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: theme.colorScheme.primary),
                                    decoration: InputDecoration(
                                      counterText: '', filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 100 : 255),
                                      contentPadding: EdgeInsets.zero,
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100), width: 2)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.error50.withAlpha(isDark ? 40 : 255), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Text(_errorMessage!, style: TextStyle(color: isDark ? AppColors.error200 : AppColors.error, fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                          if (_isLoading) CircularProgressIndicator(color: theme.colorScheme.primary)
                          else
                            Container(
                              width: double.infinity, height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [AppColors.primary600, AppColors.primary400]),
                                boxShadow: [BoxShadow(color: AppColors.primary500.withAlpha(60), blurRadius: 12, offset: const Offset(0, 6))],
                              ),
                              child: ElevatedButton(
                                onPressed: _pin.length != 4 ? null : _verifyPin,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, shadowColor: Colors.transparent, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), disabledBackgroundColor: Colors.transparent),
                                child: Text(l10n.startVisit, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextButton(onPressed: () { Navigator.pop(context); context.read<NurseBookingCubit>().declineBooking(widget.booking.id); }, child: Text(l10n.cancelVisit, style: TextStyle(fontFamily: 'Inter', color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
