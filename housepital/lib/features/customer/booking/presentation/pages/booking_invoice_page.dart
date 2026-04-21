import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';

/// Patient invoice & rating page shown after a visit is completed.
///
/// Pulls real pricing, nurse name, and visit report from booking data.
/// Submits ratings to `POST /bookings/:id/rate`.
class BookingInvoicePage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingInvoicePage({Key? key, required this.booking}) : super(key: key);

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
  String get _nurseName => widget.booking['nurseName'] ?? 'Nurse';
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
    if (_rating == 0) {
      setState(() => _ratingError = 'Please select a rating');
      return;
    }

    setState(() {
      _isSubmittingRating = true;
      _ratingError = null;
    });

    try {
      final apiService = ApiService();
      final response = await apiService.post(
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
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Thank you for rating!'),
              ],
            ),
            backgroundColor: const Color(0xFF17C47F),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Success header
          _buildHeader(),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Invoice card
                _buildInvoiceCard(),

                const SizedBox(height: 24),

                // Visit Report (if exists)
                if (_visitReport != null && _visitReport!.isNotEmpty) ...[
                  _buildVisitReportCard(),
                  const SizedBox(height: 24),
                ],

                // Rating section
                _buildRatingSection(),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 210,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF17C47F), Color(0xFF10B068)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            const Text(
              'Visit Completed',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _nurseName,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              Icon(Icons.receipt_long_rounded,
                  size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Service
          _buildInvoiceRow(
            widget.booking['serviceName'] ?? 'Service',
            _servicePrice,
          ),

          // Destination fee
          if (_destinationFee > 0) ...[
            const SizedBox(height: 12),
            _buildInvoiceRow('Destination Fee', _destinationFee),
          ],

          // Platform fee (if shown)
          if (_platformFee > 0) ...[
            const SizedBox(height: 12),
            _buildInvoiceRow(
              'Platform Fee',
              _platformFee,
              isSubtle: true,
            ),
          ],

          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 16),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${_totalAmount.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17C47F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  size: 18,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Visit Report',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _visitReport!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final bool canRate = !_alreadyRated && !_ratingSubmitted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            canRate ? 'Rate $_nurseName' : 'Rating Submitted',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            canRate
                ? 'How was the service provided?'
                : 'Thank you for your feedback!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Icon(
                    index < displayRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 42,
                    color: index < displayRating
                        ? const Color(0xFFFBBF24)
                        : Colors.grey[300],
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
                color: Color(0xFFEF4444),
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
              decoration: InputDecoration(
                hintText: 'Write a review (optional)...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF17C47F),
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
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.star_rounded, size: 20),
                label: Text(
                  _isSubmittingRating ? 'Submitting...' : 'Submit Rating',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBBF24),
                  foregroundColor: const Color(0xFF1E293B),
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
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '"${widget.booking['customerReview']}"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
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
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: Color(0xFF17C47F), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Rating saved successfully!',
                    style: TextStyle(
                      color: Color(0xFF17C47F),
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
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF17C47F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Back to Home',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isSubtle = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDiscount
                ? const Color(0xFF17C47F)
                : isSubtle
                    ? Colors.grey[500]
                    : Colors.grey[700],
          ),
        ),
        Text(
          '${isDiscount ? "-" : ""}${amount.toStringAsFixed(0)} EGP',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF17C47F)
                : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
