import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:housepital/core/constants/app_colors.dart';
import 'package:housepital/generated/l10n/app_localizations.dart';
import '../../../../../core/network/api_service.dart';

/// Patient invoice & rating page shown after a visit is completed.
///
/// Pulls real pricing, nurse name, and visit report from booking data.
/// Submits ratings to `POST /bookings/:id/rate`.
class BookingInvoicePage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingInvoicePage({super.key, required this.booking});

  @override
  State<BookingInvoicePage> createState() => _BookingInvoicePageState();
}

class _BookingInvoicePageState extends State<BookingInvoicePage> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmittingRating = false;
  bool _ratingSubmitted = false;
  String? _ratingError;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // --- Data Extraction ---
  String _nurseName(AppLocalizations l10n) =>
      (widget.booking['nurseName'] ?? l10n.defaultNurseName).toString();
  double get _servicePrice =>
      (widget.booking['servicePrice'] ?? 0).toDouble();
  double get _destinationFee =>
      (widget.booking['destinationFee'] ?? 0).toDouble();
  double get _platformFee =>
      (widget.booking['platformFee'] ?? 0).toDouble();
  double get _totalAmount {
    final total = widget.booking['totalAmount'];
    if (total != null && (total as num).toDouble() > 0) {
      return total.toDouble();
    }
    return _servicePrice + _destinationFee;
  }

  String? get _visitReport => widget.booking['visitReport'];
  bool get _alreadyRated => widget.booking['customerRating'] != null;
  String get _bookingId =>
      (widget.booking['_id'] ?? widget.booking['id'] ?? '').toString();

  Future<void> _submitRating() async {
    final l10n = AppLocalizations.of(context)!;

    if (_rating == 0) {
      setState(() => _ratingError = l10n.ratingSelectError);
      return;
    }

    setState(() {
      _isSubmittingRating = true;
      _ratingError = null;
    });

    try {
      final apiService = ApiService();
      await apiService.post(
        '/api/bookings/$_bookingId/rate',
        body: {
          'rating': _rating,
          'review': _reviewController.text.trim(),
        },
      );

      if (mounted) {
        setState(() {
          _isSubmittingRating = false;
          _ratingSubmitted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(l10n.ratingThanksSnack),
              ],
            ),
            backgroundColor: AppColors.success500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingRating = false;
          _ratingError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Success header
          _buildHeader(context, l10n),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
              children: [
                // Invoice card
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: _buildInvoiceCard(context, l10n),
                ),
                const SizedBox(height: 8),

                // Visit Report (if exists)
                if (_visitReport != null && _visitReport!.isNotEmpty) ...[
                  _buildVisitReportCard(context, l10n),
                  const SizedBox(height: 20),
                ],

                // Rating section
                _buildRatingSection(context, l10n),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, l10n),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 240,
      width:  double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary500, AppColors.secondary500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.secondary500)
                .withOpacity(isDark ? 0.3 : 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -20,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 160,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Center(
            child: SafeArea(
              bottom: false,
              
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(26),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withAlpha(50),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.visitCompletedTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.visitCompletedSubtitle(_nurseName(l10n)),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.light50 : AppColors.dark500;
    final dividerColor = isDark ? AppColors.dark600 : AppColors.light400;
    final cardColor = (isDark ? AppColors.dark700 : AppColors.light50)
        .withOpacity(isDark ? 0.7 : 0.9);
    final borderColor = Colors.white.withAlpha(isDark ? 12 : 30);

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.secondary500)
                      .withOpacity(isDark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -6,
                  bottom: -14,
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 120,
                    color: Colors.white.withOpacity(isDark ? 0.06 : 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary500, AppColors.primary500],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.orderSummaryTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    // Service
                    _buildInvoiceRow(
                      context,
                      (widget.booking['serviceName'] ?? l10n.serviceLabel)
                          .toString(),
                      _servicePrice,
                      currencyLabel: l10n.currencyEgp,
                    ),

                    // Destination fee
                    if (_destinationFee > 0) ...[
                      const SizedBox(height: 12),
                      _buildInvoiceRow(
                        context,
                        l10n.destinationFeeLabel,
                        _destinationFee,
                        currencyLabel: l10n.currencyEgp,
                        isSubtle: true,
                      ),
                    ],

                    // Platform fee
                    if (_platformFee > 0) ...[
                      const SizedBox(height: 12),
                      _buildInvoiceRow(
                        context,
                        l10n.platformFeeLabel,
                        _platformFee,
                        currencyLabel: l10n.currencyEgp,
                        isSubtle: true,
                      ),
                    ],

                    const SizedBox(height: 16),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.totalLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '${_totalAmount.toStringAsFixed(0)} ${l10n.currencyEgp}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitReportCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.light50 : AppColors.dark500;
    final textSecondary = isDark ? AppColors.light700 : AppColors.dark300;
    final cardColor = (isDark ? AppColors.dark700 : AppColors.light50)
        .withOpacity(isDark ? 0.65 : 0.9);
    final borderColor = Colors.white.withAlpha(isDark ? 12 : 30);

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary500, AppColors.primary500],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n.visitReportTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _visitReport!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.light50 : AppColors.dark500;
    final textSecondary = isDark ? AppColors.light700 : AppColors.dark300;
    final cardColor = (isDark ? AppColors.dark700 : AppColors.light50)
        .withOpacity(isDark ? 0.7 : 0.95);
    final borderColor = Colors.white.withAlpha(isDark ? 12 : 30);
    final starActive = AppColors.warning500;
    final starInactive = isDark ? AppColors.dark400 : AppColors.light600;
    final bool canRate = !_alreadyRated && !_ratingSubmitted;

    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Text(
                  canRate
                      ? l10n.rateNurseTitle(_nurseName(l10n))
                      : l10n.ratingSubmittedTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  canRate ? l10n.ratingPrompt : l10n.ratingThanks,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final int displayRating = _alreadyRated
                        ? (widget.booking['customerRating'] as num).toInt()
                        : _rating;

                    return GestureDetector(
                      onTap: canRate
                          ? () => setState(() {
                                _rating = starValue;
                                _ratingError = null;
                              })
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Icon(
                          index < displayRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 42,
                          color: index < displayRating
                              ? starActive
                              : starInactive,
                        ),
                      ),
                    );
                  }),
                ),

                if (_ratingError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _ratingError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error500,
                    ),
                  ),
                ],

                // Review field
                if (canRate) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.reviewHint,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.dark600 : AppColors.light200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.dark500 : AppColors.light400,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.dark500 : AppColors.light400,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary500,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit rating button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmittingRating ? null : _submitRating,
                      icon: _isSubmittingRating
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark ? const Color(0xFF16151A) : Colors.white,
                              ),
                            )
                          : const Icon(Icons.star_rounded, size: 20),
                      label: Text(
                        _isSubmittingRating
                            ? l10n.submitting
                            : l10n.submitRating,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning500,
                        foregroundColor: AppColors.dark500,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],

                // Already rated show
                if (_alreadyRated) ...[
                  const SizedBox(height: 12),
                  if (widget.booking['customerReview'] != null &&
                      (widget.booking['customerReview'] as String).isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.dark600 : AppColors.light200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '"${widget.booking['customerReview']}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],

                // Just submitted
                if (_ratingSubmitted && !_alreadyRated) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success500
                          .withOpacity(isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success500,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.ratingSaved,
                          style: const TextStyle(
                            color: AppColors.success500,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = (isDark ? AppColors.dark700 : AppColors.light50)
        .withOpacity(isDark ? 0.65 : 0.85);
    final borderColor = Colors.white.withAlpha(isDark ? 12 : 30);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.secondary500)
                      .withOpacity(isDark ? 0.35 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success500, AppColors.primary500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.backToHome,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
    BuildContext context,
    String label,
    double amount, {
    required String currencyLabel,
    bool isDiscount = false,
    bool isSubtle = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.light50 : AppColors.dark500;
    final textSecondary = isDark ? AppColors.light700 : AppColors.dark300;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDiscount
                ? AppColors.success500
                : isSubtle
                    ? textSecondary
                    : textPrimary,
          ),
        ),
        Text(
          '${isDiscount ? "-" : ""}${amount.toStringAsFixed(0)} $currencyLabel',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? AppColors.success500
                : textPrimary,
          ),
        ),
      ],
    );
  }
}
