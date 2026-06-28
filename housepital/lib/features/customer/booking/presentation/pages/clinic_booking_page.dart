import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/booking_ticket_modal.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../profile/presentation/pages/add_dependent_page.dart';

class ClinicBookingPage extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialization;
  final Map<String, dynamic>? clinicData;

  const ClinicBookingPage({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialization,
    this.clinicData,
  });

  @override
  State<ClinicBookingPage> createState() => _ClinicBookingPageState();
}

class _ClinicBookingPageState extends State<ClinicBookingPage>
    with SingleTickerProviderStateMixin {
  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  bool get isAr => Localizations.localeOf(context).languageCode == 'ar';

  String t(String ar, String en) => isAr ? ar : en;

  String _formatAddress(dynamic address) {
    if (address == null) return '';
    if (address is String) return address;
    if (address is Map) {
      final street = address['street'] ?? '';
      final area = address['area'] ?? '';
      final city = address['city'] ?? '';
      final state = address['state'] ?? '';
      return [street, area, city, state]
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .join(', ');
    }
    return address.toString();
  }

  // Glass & Grid Theme (Medical Blue)
  static const _primary = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF1D4ED8);

  Color get surfaceColor => isDark ? const Color(0xFF0D0C11) : const Color(0xFFF0F4F8);
  Color get cardColor => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get textPrimaryColor => isDark ? const Color(0xFFF2F2F5) : const Color(0xFF1A202C);
  Color get textMutedColor => isDark ? const Color(0xFFA19EAB) : const Color(0xFFA0AEC0);

  late PageController _pageController;
  late AnimationController _animationController;
  int _currentStep = 0;
  static const _totalSteps = 4;

  // Step 1: Services
  List<Map<String, dynamic>> _services = [];
  bool _isLoadingServices = true;
  Map<String, dynamic>? _selectedService;

  // Step 2: Date & Time
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  // Step 3: Patient
  String? _userId;
  String? _userName;
  List<dynamic> _dependents = [];
  bool _isLoadingDependents = true;
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isForSelf = false;
  final TextEditingController _notesController = TextEditingController();

  // Submit
  bool _isSubmitting = false;

  List<String> get _timeSlots {
    final workingHours = widget.clinicData?['workingHours'] as List?;
    final dayName = DateFormat('EEEE').format(_selectedDate).toLowerCase();
    if (workingHours != null) {
      final dayEntry = workingHours.firstWhere(
        (wh) =>
            (wh['day'] as String?)?.toLowerCase() == dayName ||
            (wh['dayOfWeek'] as String?)?.toLowerCase() == dayName,
        orElse: () => null,
      );
      if (dayEntry != null && dayEntry['isOpen'] == true) {
        final open = dayEntry['openTime'] as String? ?? '09:00';
        final close = dayEntry['closeTime'] as String? ?? '17:00';
        final slot = (widget.clinicData?['slotDurationMinutes'] as int?) ?? 30;
        return _generateSlots(open, close, slot);
      }
    }
    return _generateSlots('09:00', '17:00', 30);
  }

  String get _bookingMode =>
      (widget.clinicData?['bookingMode'] as String?) ?? 'slots';

  List<String> _generateSlots(String open, String close, int slotMin) {
    final slots = <String>[];
    var cur = _parseTime(open);
    final end = _parseTime(close);
    while (cur.isBefore(end)) {
      slots.add(DateFormat('HH:mm').format(cur));
      cur = cur.add(Duration(minutes: slotMin));
    }
    return slots;
  }

  DateTime _parseTime(String t) {
    final parts = t.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 9,
      int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadServices();
    _loadUserAndDependents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final api = ApiService();
      final response = await api.get(
        '/api/services/public/by-clinic/${widget.clinicId}',
      );
      final data = response is Map ? response['data'] : response;
      if (mounted) {
        setState(() {
          _services = (data as List).cast<Map<String, dynamic>>();
          _isLoadingServices = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingServices = false);
    }
  }

  Future<void> _loadUserAndDependents() async {
    try {
      final userId = await TokenManager.getUserId();
      final api = ApiService();
      final userResp = await api.get('/api/auth/me');
      if (mounted) {
        setState(() {
          _userId =
              userResp is Map ? (userResp['user']?['_id'] ?? userId) : userId;
          _userName =
              userResp is Map ? (userResp['user']?['name'] ?? 'Me') : 'Me';
        });
      }
      if (userId != null) {
        final depResp = await api.post(
          '/api/user/getAllDependents',
          body: {'id': userId},
        );
        if (mounted) {
          setState(() {
            _dependents = depResp is List ? depResp : [];
            _isLoadingDependents = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingDependents = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingDependents = false);
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    setState(() => _currentStep = step);
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) _goToStep(_currentStep + 1);
  }

  void _back() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.pop(context);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedService != null;
      case 1:
        return _bookingMode == 'queue' ? true : _selectedTimeSlot != null;
      case 2:
        return _selectedPatientId != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);
    try {
      final api = ApiService();
      final isQueue = _bookingMode == 'queue';
      final body = {
        'type': 'clinic_appointment',
        'serviceId': _selectedService!['_id'],
        'serviceName': _selectedService!['name'],
        'servicePrice': (_selectedService!['price'] ?? 0).toDouble(),
        'patientId': _selectedPatientId,
        'patientName': _selectedPatientName,
        'isForSelf': _isForSelf,
        'clinicId': widget.clinicId,
        'doctorId': widget.doctorId,
        'timeOption': isQueue ? 'queue' : 'schedule',
        'scheduledDate': _selectedDate.toIso8601String(),
        if (!isQueue) 'scheduledTime': _selectedTimeSlot,
        'notes': _notesController.text.trim(),
        'status': 'pending',
      };
      final response = await api.post('/api/bookings/create', body: body);
      if (mounted) {
        setState(() => _isSubmitting = false);
        final createdBooking = response is Map ? response['booking'] : null;
        _showSuccessSheet(createdBooking);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError(t('حدث خطأ أثناء الحجز. حاول مرة أخرى.', 'An error occurred during booking. Please try again.'));
      }
    }
  }

  void _showSuccessSheet(Map<String, dynamic>? bookingData) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t('تم الحجز بنجاح!', 'Booking Successful!'),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _bookingMode == 'queue'
                      ? t(
                          'تم تسجيلك في طابور ${widget.clinicName} ليوم ${DateFormat('EEE, d MMM').format(_selectedDate)}',
                          'You have been registered in ${widget.clinicName} queue for ${DateFormat('EEE, d MMM').format(_selectedDate)}',
                        )
                      : t(
                          'موعدك في ${widget.clinicName} يوم ${DateFormat('EEE, d MMM').format(_selectedDate)} الساعة $_selectedTimeSlot',
                          'Your appointment at ${widget.clinicName} is on ${DateFormat('EEE, d MMM').format(_selectedDate)} at $_selectedTimeSlot',
                        ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: textMutedColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                if (bookingData != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // pop sheet
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        // Show ticket modal
                        final rootContext = Navigator.of(context).context;
                        showDialog(
                          context: rootContext,
                          builder: (ctx) => BookingTicketModal(
                            serviceName: bookingData['serviceName'] ?? _selectedService?['name'] ?? '',
                            patientName: bookingData['patientName'] ?? _selectedPatientName ?? '',
                            clinicName: widget.clinicName,
                            clinicAddress: _formatAddress(widget.clinicData?['address']),
                            doctorName: widget.doctorName,
                            scheduledTime: _bookingMode == 'queue'
                                ? DateFormat('d MMM').format(_selectedDate)
                                : '${DateFormat('d MMM').format(_selectedDate)} · $_selectedTimeSlot',
                            checkInPin: bookingData['visitPin'] ?? '----',
                            onClose: () => Navigator.pop(ctx),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: Text(
                        t('عرض التذكرة / رمز PIN', 'View Ticket / PIN'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: textPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      t('حسناً', 'OK'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: surfaceColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1Services(),
                _buildStep2DateTime(),
                _buildStep3Patient(),
                _buildStep4Review(),
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
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryDark],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(50)),
              ),
              child: Icon(
                isAr ? Icons.arrow_forward : Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinicName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.doctorName}${widget.doctorSpecialization != null ? ' · ${widget.doctorSpecialization}' : ''}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final labels = [
      t('الخدمة', 'Service'),
      _bookingMode == 'queue' ? t('اليوم', 'Day') : t('الوقت', 'Time'),
      t('المريض', 'Patient'),
      t('تأكيد', 'Confirm'),
    ];
    const icons = [
      Icons.medical_services_rounded,
      Icons.calendar_today_rounded,
      Icons.person_rounded,
      Icons.check_circle_rounded,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient:
                      active || done
                          ? const LinearGradient(
                            colors: [_primary, _primaryDark],
                          )
                          : null,
                  color: active || done ? null : cardColor,
                  shape: BoxShape.circle,
                  boxShadow:
                      active
                          ? [
                            BoxShadow(
                              color: _primary.withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : [],
                  border:
                      active || done
                          ? null
                          : Border.all(color: textMutedColor.withAlpha(40)),
                ),
                child: Icon(
                  icons[i],
                  size: 20,
                  color: active || done ? Colors.white : textMutedColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: active ? _primary : textMutedColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1Services() {
    if (_isLoadingServices) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              t('لا توجد خدمات متاحة', 'No services available'),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final s = _services[index];
        final isSelected = _selectedService?['_id'] == s['_id'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedService = s);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _primary : Colors.transparent,
                width: 2,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: _primary.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? _primary.withAlpha(20) : surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: isSelected ? _primary : textMutedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['name'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: textMutedColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${s['durationMinutes'] ?? 30} ${t('دقيقة', 'min')}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: textMutedColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${s['price']} ${t('جنيه', 'EGP')}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _primary : textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep2DateTime() {
    final isQueue = _bookingMode == 'queue';
    final localeStr = isAr ? 'ar' : 'en';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          isQueue ? t('اختر يوم الزيارة', 'Select Visit Day') : t('اختر الموعد', 'Select Appointment'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          t('التاريخ', 'Date'),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) {
              final d = DateTime.now().add(Duration(days: i + 1));
              final selected = DateUtils.isSameDay(d, _selectedDate);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedDate = d;
                    _selectedTimeSlot = null;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  width: 64,
                  decoration: BoxDecoration(
                    gradient:
                        selected
                            ? const LinearGradient(
                              colors: [_primary, _primaryDark],
                            )
                            : null,
                    color: selected ? null : cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: _primary.withAlpha(60),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [
                              BoxShadow(
                                color: Colors.black.withAlpha(5),
                                blurRadius: 8,
                              ),
                            ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE', localeStr).format(d),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color:
                              selected
                                  ? Colors.white.withAlpha(200)
                                  : textMutedColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d', localeStr).format(d),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (isQueue) ...[
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primary.withAlpha(isDark ? 25 : 15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withAlpha(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_rounded, color: _primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('نظام الطابور', 'Queue System'),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t(
                          'سيُخصَّص لك رقم طابور بعد تأكيد الحجز ليوم ${DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate)}',
                          'You will be assigned a queue number after booking confirmation for ${DateFormat('EEEE, d MMMM', 'en').format(_selectedDate)}',
                        ),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: textMutedColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 32),
          Text(
            t('الوقت', 'Time'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _timeSlots.map((tSlot) {
                  final selected = _selectedTimeSlot == tSlot;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTimeSlot = tSlot);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? _primary : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow:
                            selected
                                ? [
                                  BoxShadow(
                                    color: _primary.withAlpha(60),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 8,
                                  ),
                                ],
                      ),
                      child: Text(
                        tSlot,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w600,
                          color: selected ? Colors.white : textPrimaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3Patient() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          t('من المريض؟', 'Who is the patient?'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        if (_userName != null)
          _buildPatientCard(
            id: _userId!,
            name: _userName!,
            subtitle: t('أنت', 'You'),
            icon: Icons.person_rounded,
            isForSelf: true,
          ),
        if (_isLoadingDependents)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: _primary)),
          )
        else
          ..._dependents.map(
            (dep) => _buildPatientCard(
              id: dep['_id'] ?? dep['id'] ?? '',
              name: dep['fullName'] ?? dep['name'] ?? t('مريض', 'Patient'),
              subtitle: dep['relationship'] ?? dep['relation'] ?? '',
              icon: Icons.people_rounded,
              isForSelf: false,
            ),
          ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddDependentPage()),
            );
            _loadUserAndDependents();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _primary.withAlpha(40),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: _primary),
                const SizedBox(width: 8),
                Text(
                  t('إضافة شخص آخر', 'Add someone else'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          t('ملاحظات للطبيب (اختياري)', 'Notes for the doctor (Optional)'),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(fontFamily: 'Inter', color: textPrimaryColor),
            decoration: InputDecoration(
              hintText: t('أكتب أي ملاحظات أو استفسارات...', 'Write any notes or queries...'),
              hintStyle: TextStyle(color: textMutedColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard({
    required String id,
    required String name,
    required String subtitle,
    required IconData icon,
    required bool isForSelf,
  }) {
    final selected = _selectedPatientId == id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPatientId = id;
          _selectedPatientName = name;
          _isForSelf = isForSelf;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primary : Colors.transparent,
            width: 2,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: _primary.withAlpha(40),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
                  ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected ? _primary.withAlpha(20) : surfaceColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: selected ? _primary : textMutedColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textPrimaryColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: textMutedColor,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_primary, _primaryDark]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Review() {
    final localeStr = isAr ? 'ar' : 'en';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          t('مراجعة الحجز', 'Review Booking'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 20),
        _buildReviewCard(
          Icons.local_hospital_rounded,
          t('العيادة', 'Clinic'),
          widget.clinicName,
          _primary,
        ),
        _buildReviewCard(
          Icons.person_rounded,
          t('الطبيب', 'Doctor'),
          widget.doctorName,
          const Color(0xFF8B5CF6),
        ),
        if (_selectedService != null)
          _buildReviewCard(
            Icons.medical_services_rounded,
            t('الخدمة', 'Service'),
            '${_selectedService!['name']} — ${_selectedService!['price']} EGP',
            const Color(0xFF10B981),
          ),
        _buildReviewCard(
          Icons.calendar_today_rounded,
          _bookingMode == 'queue' ? t('يوم الزيارة (طابور)', 'Visit Day (Queue)') : t('التاريخ والوقت', 'Date & Time'),
          _bookingMode == 'queue'
              ? DateFormat('EEEE, d MMMM yyyy', localeStr).format(_selectedDate)
              : '${DateFormat('EEEE, d MMMM yyyy', localeStr).format(_selectedDate)} · $_selectedTimeSlot',
          const Color(0xFFF59E0B),
        ),
        if (_selectedPatientName != null)
          _buildReviewCard(
            Icons.people_rounded,
            t('المريض', 'Patient'),
            _selectedPatientName!,
            const Color(0xFFEF4444),
          ),
        if (_notesController.text.isNotEmpty)
          _buildReviewCard(
            Icons.notes_rounded,
            t('ملاحظات', 'Notes'),
            _notesController.text,
            const Color(0xFF64748B),
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_primary, _primaryDark]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _primary.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('إجمالي الحجز', 'Total Amount'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_selectedService?['price'] ?? 0} EGP',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: textMutedColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _back,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      t('رجوع', 'Back'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: textPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: _canProceed() ? (isLast ? _submitBooking : _next) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  gradient:
                      _canProceed()
                          ? const LinearGradient(
                            colors: [_primary, _primaryDark],
                          )
                          : null,
                  color: _canProceed() ? null : (isDark ? const Color(0xFF2A2831) : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      _canProceed()
                          ? [
                            BoxShadow(
                              color: _primary.withAlpha(60),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                          : [],
                ),
                child: Center(
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            isLast ? t('تأكيد الحجز', 'Confirm Booking') : t('التالي', 'Next'),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _canProceed()
                                  ? Colors.white
                                  : (isDark ? Colors.white.withAlpha(60) : Colors.white.withAlpha(180)),
                            ),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
