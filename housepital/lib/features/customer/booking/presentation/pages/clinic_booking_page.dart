import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
  // Glass & Grid Theme (Medical Blue)
  static const _primary = Color(0xFF3B82F6);
  static const _primaryDark = Color(0xFF1D4ED8);
  static const _surface = Color(0xFFF0F4F8);
  static const _textPrimary = Color(0xFF1A202C);
  static const _textMuted = Color(0xFFA0AEC0);

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
      await api.post('/api/bookings/create', body: body);
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessSheet();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('حدث خطأ أثناء الحجز. حاول مرة أخرى.');
      }
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'تم الحجز بنجاح!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _bookingMode == 'queue'
                      ? 'تم تسجيلك في طابور ${widget.clinicName} ليوم ${DateFormat('EEE, d MMM').format(_selectedDate)}'
                      : 'موعدك في ${widget.clinicName} يوم ${DateFormat('EEE, d MMM').format(_selectedDate)} الساعة $_selectedTimeSlot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: isDark ? const Color(0xFFA19EAB) : const Color(0xFF64748B),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).popUntil((route) => route.isFirst);
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
                      'حسناً',
                      style: TextStyle(
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
          style: TextStyle(
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
      backgroundColor: _surface,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
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
                Icons.arrow_back,
                color: isDark ? const Color(0xFF16151A) : Colors.white,
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF16151A) : Colors.white,
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
            child: Icon(
              Icons.local_hospital_rounded,
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = [
      'الخدمة',
      _bookingMode == 'queue' ? 'اليوم' : 'الوقت',
      'المريض',
      'تأكيد',
    ];
    const icons = [
      Icons.medical_services_rounded,
      Icons.calendar_today_rounded,
      Icons.person_rounded,
      Icons.check_circle_rounded,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      color: _surface,
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
                          ? LinearGradient(
                            colors: [_primary, _primaryDark],
                          )
                          : null,
                  color: active || done ? null : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow:
                      active
                          ? [
                            BoxShadow(
                              color: _primary.withAlpha(60),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                          : [],
                  border:
                      active || done
                          ? null
                          : Border.all(color: _textMuted.withAlpha(40)),
                ),
                child: Icon(
                  icons[i],
                  size: 20,
                  color: active || done ? Colors.white : _textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: active ? _primary : _textMuted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1Services() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              'لا توجد خدمات متاحة',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
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
              color: isDark ? const Color(0xFF16151A) : Colors.white,
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
                          offset: Offset(0, 6),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected ? _primary.withAlpha(20) : _surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: isSelected ? _primary : _textMuted,
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
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${s['durationMinutes'] ?? 30} دقيقة',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${s['price']} جنيه',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _primary : _textPrimary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isQueue = _bookingMode == 'queue';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          isQueue ? 'اختر يوم الزيارة' : 'اختر الموعد',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'التاريخ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
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
                            ? LinearGradient(
                              colors: [_primary, _primaryDark],
                            )
                            : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:
                        selected
                            ? [
                              BoxShadow(
                                color: _primary.withAlpha(60),
                                blurRadius: 10,
                                offset: Offset(0, 4),
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
                        DateFormat('EEE').format(d),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color:
                              selected
                                  ? Colors.white.withAlpha(200)
                                  : _textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(d),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: selected ? Colors.white : _textPrimary,
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
              color: _primary.withAlpha(15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withAlpha(30)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16151A) : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.people_rounded, color: _primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نظام الطابور',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سيُخصَّص لك رقم طابور بعد تأكيد الحجز ليوم ${DateFormat('EEEE, d MMMM').format(_selectedDate)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: _textMuted,
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
            'الوقت',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _timeSlots.map((t) {
                  final selected = _selectedTimeSlot == t;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTimeSlot = t);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? _primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow:
                            selected
                                ? [
                                  BoxShadow(
                                    color: _primary.withAlpha(60),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
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
                        t,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w600,
                          color: selected ? Colors.white : _textPrimary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'من المريض؟',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        if (_userName != null)
          _buildPatientCard(
            id: _userId!,
            name: _userName!,
            subtitle: 'أنت',
            icon: Icons.person_rounded,
            isForSelf: true,
          ),
        if (_isLoadingDependents)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: _primary)),
          )
        else
          ..._dependents.map(
            (dep) => _buildPatientCard(
              id: dep['_id'] ?? dep['id'] ?? '',
              name: dep['name'] ?? 'مريض',
              subtitle: dep['relation'] ?? '',
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
              color: isDark ? const Color(0xFF16151A) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _primary.withAlpha(40),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: _primary),
                SizedBox(width: 8),
                Text(
                  'إضافة شخص آخر',
                  style: TextStyle(
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
          'ملاحظات للطبيب (اختياري)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16151A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
            ],
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(fontFamily: 'Inter'),
            decoration: InputDecoration(
              hintText: 'أكتب أي ملاحظات أو استفسارات...',
              hintStyle: TextStyle(color: _textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          color: isDark ? const Color(0xFF16151A) : Colors.white,
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
                      offset: Offset(0, 4),
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
                color: selected ? _primary.withAlpha(20) : _surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: selected ? _primary : _textMuted),
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
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: _textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_primary, _primaryDark]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isDark ? const Color(0xFF16151A) : Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Review() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        Text(
          'مراجعة الحجز',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        _buildReviewCard(
          Icons.local_hospital_rounded,
          'العيادة',
          widget.clinicName,
          _primary,
        ),
        _buildReviewCard(
          Icons.person_rounded,
          'الطبيب',
          widget.doctorName,
          const Color(0xFF8B5CF6),
        ),
        if (_selectedService != null)
          _buildReviewCard(
            Icons.medical_services_rounded,
            'الخدمة',
            '${_selectedService!['name']} — ${_selectedService!['price']} EGP',
            const Color(0xFF10B981),
          ),
        _buildReviewCard(
          Icons.calendar_today_rounded,
          _bookingMode == 'queue' ? 'يوم الزيارة (طابور)' : 'التاريخ والوقت',
          _bookingMode == 'queue'
              ? DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)
              : '${DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)} · $_selectedTimeSlot',
          const Color(0xFFF59E0B),
        ),
        if (_selectedPatientName != null)
          _buildReviewCard(
            Icons.people_rounded,
            'المريض',
            _selectedPatientName!,
            const Color(0xFFEF4444),
          ),
        if (_notesController.text.isNotEmpty)
          _buildReviewCard(
            Icons.notes_rounded,
            'ملاحظات',
            _notesController.text,
            const Color(0xFF64748B),
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_primary, _primaryDark]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _primary.withAlpha(60),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي الحجز',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: isDark ? const Color(0xFF16151A) : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_selectedService?['price'] ?? 0} EGP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: isDark ? const Color(0xFF16151A) : Colors.white,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16151A) : Colors.white,
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
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16151A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 24,
            offset: Offset(0, -8),
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
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'رجوع',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
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
                          ? LinearGradient(
                            colors: [_primary, _primaryDark],
                          )
                          : null,
                  color: _canProceed() ? null : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      _canProceed()
                          ? [
                            BoxShadow(
                              color: _primary.withAlpha(60),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ]
                          : [],
                ),
                child: Center(
                  child:
                      _isSubmitting
                          ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: isDark ? const Color(0xFF16151A) : Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            isLast ? 'تأكيد الحجز' : 'التالي',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF16151A) : Colors.white,
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
