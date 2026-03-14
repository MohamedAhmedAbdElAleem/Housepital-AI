import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../profile/presentation/pages/add_dependent_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 📱  CLINIC BOOKING PAGE
// Multi-step clinic appointment booking with service selection
// Steps: 1-Select Service  2-Date & Time  3-Patient  4-Confirm
// ─────────────────────────────────────────────────────────────────────────────

class ClinicBookingPage extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialization;
  final Map<String, dynamic>? clinicData; // full clinic object (optional)

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
  // Design
  static const _primary = Color(0xFF3B82F6);
  static const _surface = Color(0xFFF8FAFC);

  late PageController _pageController;
  late AnimationController _animationController;
  int _currentStep = 0;
  static const _totalSteps = 4;

  // ── Step 1: Services ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _services = [];
  bool _isLoadingServices = true;
  Map<String, dynamic>? _selectedService;

  // ── Step 2: Date & Time ───────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;

  // ── Step 3: Patient ────────────────────────────────────────────────────
  String? _userId;
  String? _userName;
  List<dynamic> _dependents = [];
  bool _isLoadingDependents = true;
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isForSelf = false;
  final TextEditingController _notesController = TextEditingController();

  // ── Submit ─────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  // ── Clinic working hours (parsed from clinicData) ──────────────────────
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
    // Default slots
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

  // ── Data Loading ────────────────────────────────────────────────────────

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

  // ── Navigation ──────────────────────────────────────────────────────────

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
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

  // ── Submit ──────────────────────────────────────────────────────────────

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: _primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 40,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'تم الحجز بنجاح!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _bookingMode == 'queue'
                      ? 'تم تسجيلك في طابور ${widget.clinicName} ليوم ${DateFormat('EEE, d MMM').format(_selectedDate)}'
                      : 'موعدك في ${widget.clinicName} يوم ${DateFormat('EEE, d MMM').format(_selectedDate)} الساعة $_selectedTimeSlot',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close sheet
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('حسناً', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

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
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                _buildStep1Services(),
                _buildStep2DateTime(),
                _buildStep3Patient(),
                _buildStep4Review(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

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
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinicName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${widget.doctorName}${widget.doctorSpecialization != null ? ' · ${widget.doctorSpecialization}' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step Indicator ────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final labels = [
      'الخدمة',
      _bookingMode == 'queue' ? 'اليوم' : 'الوقت',
      'المريض',
      'تأكيد',
    ];
    const icons = [
      Icons.medical_services_outlined,
      Icons.calendar_today_rounded,
      Icons.person_rounded,
      Icons.check_circle_outline_rounded,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i == _currentStep;
          final done = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: done ? () => _goToStep(i) : null,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient:
                              active || done
                                  ? const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1D4ED8),
                                    ],
                                  )
                                  : null,
                          color:
                              active || done ? null : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icons[i],
                          size: 18,
                          color:
                              active || done
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                          color: active ? _primary : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: done ? _primary : const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1 : Service Selection ────────────────────────────────────────────

  Widget _buildStep1Services() {
    if (_isLoadingServices) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 72,
                color: Colors.blue.shade100,
              ),
              const SizedBox(height: 16),
              const Text(
                'لا توجد خدمات متاحة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'لم يضف الدكتور خدمات لهذه العيادة بعد.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'اختر الخدمة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'حدد الخدمة التي تريد حجزها',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),
        ..._services.map((s) => _buildServiceCard(s)),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isSelected =
        _selectedService != null && _selectedService!['_id'] == service['_id'];
    final price = service['price'] ?? 0;
    final duration = service['durationMinutes'] ?? 30;
    final category = service['category'] ?? '';
    final name = service['name'] ?? '';

    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.medical_services_rounded,
                color: isSelected ? _primary : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$duration دقيقة',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$price',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _primary : const Color(0xFF1E293B),
                  ),
                ),
                const Text(
                  'جنيه',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'مختارة',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

  // ── Step 2 : Date & Time ──────────────────────────────────────────────────

  Widget _buildStep2DateTime() {
    final isQueue = _bookingMode == 'queue';
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          isQueue ? 'اختر يوم الزيارة' : 'اختر الموعد',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          isQueue
              ? 'ستحجز مقعدًا في الطابور لهذا اليوم'
              : 'حدد الوقت المناسب لك',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 16),

        _buildSectionTitle('التاريخ'),
        const SizedBox(height: 10),
        _buildDateSelector(),

        if (isQueue) ...[
          const SizedBox(height: 24),
          _buildQueueInfoCard(),
        ] else ...[
          const SizedBox(height: 20),
          _buildSectionTitle('الوقت'),
          const SizedBox(height: 10),
          _buildTimeSlots(),
        ],
      ],
    );
  }

  Widget _buildQueueInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_rounded, color: _primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نظام الطابور',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ستحجز مقعدًا في طابور العيادة ليوم الزيارة. سيُخصَّص لك رقم طابور بعد تأكيد الحجز.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: _primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('EEEE, d MMMM y').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _primary,
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

  Widget _buildSectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF475569),
    ),
  );

  Widget _buildDateSelector() {
    final slots = List.generate(14, (i) {
      return DateTime.now().add(Duration(days: i + 1));
    });
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        itemBuilder: (_, i) {
          final d = slots[i];
          final selected = DateUtils.isSameDay(d, _selectedDate);
          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedDate = d;
                  _selectedTimeSlot = null;
                }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: 58,
              decoration: BoxDecoration(
                color: selected ? _primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? _primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(d),
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          selected ? Colors.white70 : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(d),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM').format(d),
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          selected ? Colors.white70 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots() {
    final slots = _timeSlots;
    if (slots.isEmpty) {
      return const Text(
        'لا توجد مواعيد متاحة في هذا اليوم.',
        style: TextStyle(color: Color(0xFF64748B)),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          slots.map((t) {
            final selected = _selectedTimeSlot == t;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _primary : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ── Step 3 : Patient ──────────────────────────────────────────────────────

  Widget _buildStep3Patient() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'من المريض؟',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'اختر من سيحضر الموعد',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Self
        if (_userName != null)
          _buildPatientCard(
            id: _userId!,
            name: _userName!,
            subtitle: 'أنت',
            icon: Icons.person_rounded,
            color: _primary,
            isForSelf: true,
          ),
        if (_isLoadingDependents)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: _primary)),
          )
        else
          ..._dependents.map<Widget>((dep) {
            final name = dep['name'] ?? 'Dependent';
            final id = dep['_id'] ?? dep['id'] ?? '';
            final relation = dep['relation'] ?? dep['relationship'] ?? '';
            return _buildPatientCard(
              id: id,
              name: name,
              subtitle: relation,
              icon: Icons.people_rounded,
              color: const Color(0xFF8B5CF6),
              isForSelf: false,
            );
          }),

        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddDependentPage()),
            );
            _loadUserAndDependents();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة شخص آخر'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionTitle('ملاحظات للطبيب (اختياري)'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'أكتب أي ملاحظات أو استفسارات...',
              hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14),
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
    required Color color,
    required bool isForSelf,
  }) {
    final selected = _selectedPatientId == id;
    return GestureDetector(
      onTap:
          () => setState(() {
            _selectedPatientId = id;
            _selectedPatientName = name;
            _isForSelf = isForSelf;
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: _primary.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 4 : Review & Confirm ─────────────────────────────────────────────

  Widget _buildStep4Review() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'مراجعة الحجز',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'تأكد من تفاصيل الحجز قبل التأكيد',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
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
            '${_selectedService!['name']}  —  ${_selectedService!['price']} جنيه',
            const Color(0xFF10B981),
          ),
        _buildReviewCard(
          Icons.calendar_today_rounded,
          _bookingMode == 'queue' ? 'يوم الزيارة (طابور)' : 'التاريخ والوقت',
          _bookingMode == 'queue'
              ? DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)
              : '${DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)}  ·  $_selectedTimeSlot',
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

        // Price summary
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إجمالي الحجز',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_selectedService?['price'] ?? 0} جنيه',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'رجوع',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed:
                  _canProceed() ? (isLast ? _submitBooking : _next) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFCBD5E1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : Text(
                        isLast ? 'تأكيد الحجز' : 'التالي',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
