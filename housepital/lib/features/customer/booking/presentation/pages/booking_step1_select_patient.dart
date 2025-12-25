import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'booking_matching_screen.dart';
import '../../../profile/presentation/pages/add_dependent_page.dart';
import '../../../profile/presentation/pages/add_address_page.dart';

class BookingStep1SelectPatient extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final double servicePrice;

  const BookingStep1SelectPatient({
    super.key,
    required this.serviceName,
    required this.serviceId,
    required this.servicePrice,
  });

  @override
  State<BookingStep1SelectPatient> createState() =>
      _BookingStep1SelectPatientState();
}

class _BookingStep1SelectPatientState extends State<BookingStep1SelectPatient>
    with TickerProviderStateMixin {
  // Page controller for swipe navigation
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Animation
  late AnimationController _animationController;

  // Data
  List<dynamic> _dependents = [];
  List<dynamic> _addresses = [];
  String? _userId;
  String? _userName;

  // Selections
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isForSelf = false;
  String? _selectedAddressId;
  Map<String, dynamic>? _selectedAddress;
  String _selectedTimeOption = 'asap';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  bool _nurseHasSupplies = true;
  String? _nurseGenderPreference;
  final TextEditingController _notesController = TextEditingController();

  // Loading states
  bool _isLoadingUser = true;
  bool _isLoadingDependents = true;
  bool _isLoadingAddresses = true;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
    _loadAllData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadUserData(), _loadDependents(), _loadAddresses()]);
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await TokenManager.getUserId();
      final apiService = ApiService();
      final response = await apiService.get('/api/auth/me');

      if (mounted) {
        if (response is Map && response['user'] != null) {
          final user = response['user'];
          setState(() {
            _userId = user['_id'] ?? userId;
            _userName = user['name'] ?? 'User';
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _userId = userId;
            _userName = 'Me';
            _isLoadingUser = false;
          });
        }
      }
    } catch (e) {
      final userId = await TokenManager.getUserId();
      if (mounted) {
        setState(() {
          _userId = userId;
          _userName = 'Me';
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadDependents() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _isLoadingDependents = false);
        return;
      }

      final apiService = ApiService();
      final response = await apiService.post(
        '/api/user/getAllDependents',
        body: {'id': userId},
      );

      if (mounted) {
        setState(() {
          _dependents = response is List ? response : [];
          _isLoadingDependents = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDependents = false);
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _isLoadingAddresses = false);
        return;
      }

      final apiService = ApiService();
      final response = await apiService.get('/api/user/addresses/$userId');

      if (mounted) {
        final addressList =
            response is List ? response : (response['addresses'] ?? []);
        setState(() {
          _addresses = addressList;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep = step);
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.pop(context);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedPatientId != null;
      case 1:
        return _selectedAddressId != null;
      case 2:
        return _selectedTimeOption == 'asap' || _selectedTimeSlot != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  double get _totalPrice {
    double total = widget.servicePrice;
    if (_nurseHasSupplies) total += 50;
    return total;
  }

  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);

    try {
      final apiService = ApiService();
      final bookingData = {
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'patientId': _selectedPatientId,
        'patientName': _selectedPatientName,
        'isForSelf': _isForSelf,
        'hasMedicalTools': !_nurseHasSupplies,
        'servicePrice': _totalPrice,
        'addressId': _selectedAddressId,
        'timeOption': _selectedTimeOption,
        'scheduledDate': _selectedDate.toIso8601String(),
        'scheduledTime': _selectedTimeSlot,
        'nurseGenderPreference': _nurseGenderPreference,
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await apiService.post('/api/bookings/create', body: bookingData);

      if (mounted) {
        setState(() => _isSubmitting = false);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookingMatchingScreen(
                  serviceName: widget.serviceName,
                  patientName: _selectedPatientName ?? 'Patient',
                ),
          ),
        );
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showError('Error creating booking');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildPatientStep(),
                _buildLocationStep(),
                _buildTimeStep(),
                _buildConfirmStep(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
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
          colors: [Color(0xFF00D47F), Color(0xFF00B870)],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
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
                  widget.serviceName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.servicePrice.toStringAsFixed(0)} EGP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      {'icon': Icons.person_rounded, 'label': 'Patient'},
      {'icon': Icons.location_on_rounded, 'label': 'Location'},
      {'icon': Icons.schedule_rounded, 'label': 'Time'},
      {'icon': Icons.check_circle_rounded, 'label': 'Confirm'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step circle
                GestureDetector(
                  onTap: index <= _currentStep ? () => _goToStep(index) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient:
                          isActive || isCompleted
                              ? const LinearGradient(
                                colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                              )
                              : null,
                      color:
                          isActive || isCompleted
                              ? null
                              : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      boxShadow:
                          isActive
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00B870,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : step['icon'] as IconData,
                      color:
                          isActive || isCompleted
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ),
                ),
                // Connector line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? const Color(0xFF00B870)
                                : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ====================================================================
  // STEP 1: PATIENT SELECTION
  // ====================================================================
  Widget _buildPatientStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            'Who needs this service?',
            'Select the patient for this booking',
          ),
          const SizedBox(height: 24),

          // Myself card
          if (!_isLoadingUser && _userId != null)
            _buildPatientCard(
              name: _userName ?? 'Me',
              subtitle: 'Myself',
              avatar: _userName?[0].toUpperCase() ?? 'M',
              avatarGradient: const [Color(0xFF00D47F), Color(0xFF00B870)],
              isSelected: _isForSelf && _selectedPatientId == _userId,
              isSelf: true,
              onTap: () {
                setState(() {
                  _selectedPatientId = _userId;
                  _selectedPatientName = _userName;
                  _isForSelf = true;
                });
              },
            ),

          // Family members section
          if (_dependents.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.group_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Family Members',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(_dependents.length, (index) {
              final dependent = _dependents[index];
              final colors = [
                [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                [const Color(0xFFEC4899), const Color(0xFFDB2777)],
                [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
              ];
              return _buildPatientCard(
                name: dependent['fullName'] ?? 'Unknown',
                subtitle: dependent['relationship'] ?? 'Family',
                avatar: (dependent['fullName'] ?? 'U')[0].toUpperCase(),
                avatarGradient: colors[index % colors.length].cast<Color>(),
                isSelected:
                    _selectedPatientId == dependent['_id'] && !_isForSelf,
                onTap: () {
                  setState(() {
                    _selectedPatientId = dependent['_id'];
                    _selectedPatientName = dependent['fullName'];
                    _isForSelf = false;
                  });
                },
              );
            }),
          ],

          const SizedBox(height: 20),

          // Add family member button
          _buildAddButton(
            icon: Icons.person_add_rounded,
            label: 'Add Family Member',
            color: const Color(0xFF00B870),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDependentPage()),
              );
              if (result == true) _loadDependents();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard({
    required String name,
    required String subtitle,
    required String avatar,
    required List<Color> avatarGradient,
    required bool isSelected,
    bool isSelf = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00B870) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF00B870).withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: avatarGradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? const Color(0xFF00B870)
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      if (isSelf) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B870),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                        )
                        : null,
                color: isSelected ? null : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.circle_outlined,
                color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // STEP 2: LOCATION SELECTION
  // ====================================================================
  Widget _buildLocationStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            'Where should we come?',
            'Select your service location',
          ),
          const SizedBox(height: 24),

          if (_isLoadingAddresses)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: Color(0xFF00B870)),
              ),
            )
          else if (_addresses.isEmpty)
            _buildEmptyAddressState()
          else
            ...List.generate(_addresses.length, (index) {
              final address = _addresses[index];
              return _buildAddressCard(address, index);
            }),

          const SizedBox(height: 16),

          _buildAddButton(
            icon: Icons.add_location_alt_rounded,
            label: 'Add New Address',
            color: const Color(0xFFEF4444),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAddressPage()),
              );
              if (result == true) _loadAddresses();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: Color(0xFFEF4444),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved addresses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an address to continue',
            style: TextStyle(fontSize: 14, color: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    final addressId = address['_id'] ?? address['id'];
    final isSelected = _selectedAddressId == addressId;
    final type = address['type'] ?? 'Other';
    final label = address['label'] ?? type;
    final street = address['street'] ?? '';
    final city = address['city'] ?? '';

    final typeData = {
      'home': {'icon': Icons.home_rounded, 'color': const Color(0xFF3B82F6)},
      'work': {
        'icon': Icons.business_rounded,
        'color': const Color(0xFFF59E0B),
      },
      'other': {
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFF8B5CF6),
      },
    };

    final data = typeData[type.toLowerCase()] ?? typeData['other']!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressId = addressId;
          _selectedAddress = address;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (data['color'] as Color).withOpacity(0.08)
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected ? data['color'] as Color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: (data['color'] as Color).withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? data['color'] as Color
                        : (data['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                data['icon'] as IconData,
                color: isSelected ? Colors.white : data['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? data['color'] as Color
                              : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [street, city].where((s) => s.isNotEmpty).join(', '),
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  // ====================================================================
  // STEP 3: TIME SELECTION
  // ====================================================================
  Widget _buildTimeStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle('When do you need it?', 'Choose your preferred time'),
          const SizedBox(height: 24),

          // ASAP vs Schedule
          Row(
            children: [
              Expanded(
                child: _buildTimeOptionCard(
                  icon: Icons.flash_on_rounded,
                  label: 'ASAP',
                  subtitle: 'As soon as possible',
                  isSelected: _selectedTimeOption == 'asap',
                  color: const Color(0xFFF59E0B),
                  onTap: () => setState(() => _selectedTimeOption = 'asap'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeOptionCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Schedule',
                  subtitle: 'Pick date & time',
                  isSelected: _selectedTimeOption == 'schedule',
                  color: const Color(0xFF3B82F6),
                  onTap: () => setState(() => _selectedTimeOption = 'schedule'),
                ),
              ),
            ],
          ),

          if (_selectedTimeOption == 'schedule') ...[
            const SizedBox(height: 28),

            // Date picker
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 14),
            _buildDatePicker(),

            const SizedBox(height: 24),

            // Time picker
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 14),
            _buildTimePicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeOptionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                  : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);
          final isToday = index == 0;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        )
                        : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    isSelected
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white24
                                : const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF3B82F6),
                        ),
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

  Widget _buildTimePicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          _timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            final hour = int.parse(slot.split(':')[0]);
            final isPM = hour >= 12;
            final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            final displayTime = '$displayHour:00 ${isPM ? "PM" : "AM"}';

            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          )
                          : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // ====================================================================
  // STEP 4: CONFIRMATION
  // ====================================================================
  Widget _buildConfirmStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(
            'Confirm your booking',
            'Review details and add preferences',
          ),
          const SizedBox(height: 24),

          // Booking Summary
          _buildSummaryCard(),
          const SizedBox(height: 20),

          // Preferences
          _buildPreferencesCard(),
          const SizedBox(height: 20),

          // Notes
          _buildNotesCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B870).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: Color(0xFF00B870),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            Icons.medical_services_rounded,
            'Service',
            widget.serviceName,
          ),
          _buildSummaryRow(
            Icons.person_rounded,
            'Patient',
            _selectedPatientName ?? '-',
          ),
          _buildSummaryRow(
            Icons.location_on_rounded,
            'Location',
            _selectedAddress?['label'] ?? _selectedAddress?['type'] ?? '-',
          ),
          _buildSummaryRow(
            Icons.schedule_rounded,
            'Time',
            _selectedTimeOption == 'asap'
                ? 'ASAP'
                : '${DateFormat('MMM d').format(_selectedDate)}, ${_selectedTimeSlot ?? '-'}',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${_totalPrice.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B870),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Supplies toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services_rounded,
                  color: Color(0xFF00B870),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nurse brings supplies',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '+50 EGP',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _nurseHasSupplies,
                  onChanged: (v) => setState(() => _nurseHasSupplies = v),
                  activeColor: const Color(0xFF00B870),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Gender preference
          const Text(
            'Nurse Preference',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGenderChip(null, 'Any', Icons.people_rounded),
              const SizedBox(width: 10),
              _buildGenderChip('male', 'Male', Icons.man_rounded),
              const SizedBox(width: 10),
              _buildGenderChip('female', 'Female', Icons.woman_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String? value, String label, IconData icon) {
    final isSelected = _nurseGenderPreference == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _nurseGenderPreference = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF8B5CF6).withOpacity(0.1)
                    : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFF8B5CF6)
                      : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF64748B),
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any special instructions for the nurse...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================================
  // HELPER WIDGETS
  // ====================================================================
  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Price (show on last step)
            if (isLastStep) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B870),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
            ],
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (!_canProceed()) {
                    _showError('Please complete this step first');
                    return;
                  }
                  if (isLastStep) {
                    _submitBooking();
                  } else {
                    _nextStep();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient:
                        _canProceed()
                            ? const LinearGradient(
                              colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                            )
                            : null,
                    color: _canProceed() ? null : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        _canProceed()
                            ? [
                              BoxShadow(
                                color: const Color(0xFF00B870).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ]
                            : null,
                  ),
                  child:
                      _isSubmitting
                          ? const Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastStep ? 'Confirm Booking' : 'Continue',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      _canProceed()
                                          ? Colors.white
                                          : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastStep
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_rounded,
                                color:
                                    _canProceed()
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                size: 20,
                              ),
                            ],
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
