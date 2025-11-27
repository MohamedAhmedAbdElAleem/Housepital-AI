import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'booking_matching_screen.dart';
import '../../../profile/presentation/pages/add_address_page.dart';

class BookingStep3VisitDetails extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final double servicePrice;
  final String patientId;
  final String patientName;
  final bool isForSelf;
  final bool hasMedicalTools;

  const BookingStep3VisitDetails({
    Key? key,
    required this.serviceName,
    required this.serviceId,
    required this.servicePrice,
    required this.patientId,
    required this.patientName,
    required this.isForSelf,
    required this.hasMedicalTools,
  }) : super(key: key);

  @override
  State<BookingStep3VisitDetails> createState() =>
      _BookingStep3VisitDetailsState();
}

class _BookingStep3VisitDetailsState extends State<BookingStep3VisitDetails> {
  String _selectedTimeOption = 'asap'; // 'asap' or 'schedule'
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _nurseGenderPreference; // 'male', 'female', or null for no preference
  String? _selectedAddressId;
  List<dynamic> _addresses = [];
  List<dynamic> _filteredAddresses = [];
  bool _isLoadingAddresses = false;
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  File? _prescriptionImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAddresses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAddresses = List.from(_addresses);
      } else {
        _filteredAddresses =
            _addresses.where((address) {
              final label = (address['label'] ?? '').toString().toLowerCase();
              final type = (address['type'] ?? '').toString().toLowerCase();
              final street = (address['street'] ?? '').toString().toLowerCase();
              final city = (address['city'] ?? '').toString().toLowerCase();
              final searchLower = query.toLowerCase();

              return label.contains(searchLower) ||
                  type.contains(searchLower) ||
                  street.contains(searchLower) ||
                  city.contains(searchLower);
            }).toList();
      }
    });
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoadingAddresses = false;
          });
        }
        return;
      }

      final apiService = ApiService();
      final response = await apiService.get('/api/user/addresses/$userId');

      if (mounted) {
        final addressList =
            response is List ? response : (response['addresses'] ?? []);
        setState(() {
          _addresses = addressList;
          _filteredAddresses = List.from(addressList);
          _isLoadingAddresses = false;
          // Auto-select default address or first address
          if (_addresses.isNotEmpty) {
            final defaultAddress = _addresses.firstWhere(
              (addr) => addr['isDefault'] == true,
              orElse: () => _addresses.first,
            );
            _selectedAddressId = defaultAddress['_id'] ?? defaultAddress['id'];
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading addresses: $e');
      if (mounted) {
        setState(() {
          _isLoadingAddresses = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickPrescription() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _prescriptionImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _takePrescriptionPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _prescriptionImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  void _showPrescriptionOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upload Prescription',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF17C47F),
                  ),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPrescription();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF17C47F),
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _takePrescriptionPhoto();
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmBooking() async {
    // Validation - Service Location
    if (_selectedAddressId == null || _selectedAddressId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service location'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validation - Time
    if (_selectedTimeOption == 'schedule') {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select date and time for your visit'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();

      // Prepare booking data
      final bookingData = {
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'patientId': widget.patientId,
        'patientName': widget.patientName,
        'isForSelf': widget.isForSelf,
        'hasMedicalTools': widget.hasMedicalTools,
        'servicePrice': widget.servicePrice,
        'addressId': _selectedAddressId,
        'timeOption': _selectedTimeOption,
        'scheduledDate': _selectedDate?.toIso8601String(),
        'scheduledTime':
            _selectedTime != null
                ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                : null,
        'nurseGenderPreference': _nurseGenderPreference,
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // TODO: Upload prescription image if available
      // This would typically be done with multipart/form-data

      // Make API call to create booking
      await apiService.post('/api/bookings/create', body: bookingData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Navigate to matching screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BookingMatchingScreen(
                  serviceName: widget.serviceName,
                  patientName: widget.patientName,
                ),
          ),
        );

        // After matching screen, navigate back to home
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Service',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStepIndicator(1, true),
                Expanded(child: _buildStepLine(true)),
                _buildStepIndicator(2, true),
                Expanded(child: _buildStepLine(true)),
                _buildStepIndicator(3, true),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'When would you like the nurse to visit?',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Service Location
                  const Text(
                    'Service Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoadingAddresses)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF17C47F),
                        ),
                      ),
                    )
                  else if (_addresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        border: Border.all(color: const Color(0xFFEF4444)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.warning_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No Saved Addresses',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Please add at least one address to continue',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddAddressPage(),
                                ),
                              );
                              if (result == true) {
                                _loadAddresses();
                              }
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Add Address'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        // Search bar
                        if (_addresses.length > 3)
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _filterAddresses,
                              decoration: InputDecoration(
                                hintText: 'Search addresses...',
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF17C47F),
                                ),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            _filterAddresses('');
                                          },
                                        )
                                        : null,
                                filled: true,
                                fillColor: const Color(0xFFF8F9FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF17C47F),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                        // Address list with max height and scroll
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                _addresses.length > 3 ? 400 : double.infinity,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics:
                                _addresses.length > 3
                                    ? const AlwaysScrollableScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                            itemCount: _filteredAddresses.length,
                            itemBuilder: (context, index) {
                              final address = _filteredAddresses[index];
                              final addressId = address['_id'] ?? address['id'];
                              final isSelected =
                                  _selectedAddressId == addressId;
                              final type = address['type'] ?? 'Other';
                              final label = address['label'] ?? '';
                              final fullName = address['fullName'] ?? '';
                              final street = address['street'] ?? '';
                              final city = address['city'] ?? '';
                              final state = address['state'] ?? '';
                              final isDefault = address['isDefault'] ?? false;

                              IconData typeIcon;
                              Color typeColor;
                              switch (type.toLowerCase()) {
                                case 'home':
                                  typeIcon = Icons.home;
                                  typeColor = const Color(0xFF3B82F6);
                                  break;
                                case 'work':
                                  typeIcon = Icons.business;
                                  typeColor = const Color(0xFFF59E0B);
                                  break;
                                default:
                                  typeIcon = Icons.location_on;
                                  typeColor = const Color(0xFF8B5CF6);
                              }

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAddressId = addressId;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? const Color(
                                              0xFF17C47F,
                                            ).withOpacity(0.1)
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFF17C47F)
                                              : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          typeIcon,
                                          color: typeColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    label.isNotEmpty
                                                        ? label
                                                        : (fullName.isNotEmpty
                                                            ? fullName
                                                            : type),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          isSelected
                                                              ? const Color(
                                                                0xFF17C47F,
                                                              )
                                                              : const Color(
                                                                0xFF1E293B,
                                                              ),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isDefault) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF17C47F,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Default',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              [street, city, state]
                                                  .where((s) => s.isNotEmpty)
                                                  .join(', '),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF17C47F),
                                          size: 28,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Show "No results" message if filtered list is empty
                        if (_filteredAddresses.isEmpty &&
                            _searchController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No addresses found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try a different search term',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 32),

                  // Time Options
                  const Text(
                    'Preferred Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ASAP Option
                  _buildTimeOptionCard(
                    value: 'asap',
                    title: 'ASAP (As Soon As Possible)',
                    description: 'Get service as soon as a nurse is available',
                    icon: Icons.flash_on,
                  ),

                  const SizedBox(height: 12),

                  // Schedule Option
                  _buildTimeOptionCard(
                    value: 'schedule',
                    title: 'Schedule for Later',
                    description: 'Choose a specific date and time',
                    icon: Icons.calendar_today,
                  ),

                  const SizedBox(height: 24),

                  // Date & Time Selection (if schedule selected)
                  if (_selectedTimeOption == 'schedule') ...[
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Color(0xFF17C47F),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : 'Select Date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              _selectedDate != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                          color:
                                              _selectedDate != null
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 20,
                                        color: Color(0xFF17C47F),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime != null
                                            ? _selectedTime!.format(context)
                                            : 'Select Time',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              _selectedTime != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                          color:
                                              _selectedTime != null
                                                  ? const Color(0xFF1E293B)
                                                  : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Nurse Gender Preference
                  const Text(
                    'Nurse Gender Preference (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderPreferenceCard(
                          'male',
                          'Male Nurse',
                          Icons.man,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenderPreferenceCard(
                          'female',
                          'Female Nurse',
                          Icons.woman,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notes Section
                  const Text(
                    'Additional Notes (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Add any special instructions or requirements...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF17C47F),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Prescription Upload
                  const Text(
                    'Upload Prescription (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_prescriptionImage == null)
                    GestureDetector(
                      onTap: _showPrescriptionOptions,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to upload prescription',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _prescriptionImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _prescriptionImage = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Payment Method Section
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF17C47F).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17C47F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF17C47F),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Wallet',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Balance: 350 EGP',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF17C47F),
                          size: 24,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Booking Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Service', widget.serviceName),
                        _buildSummaryRow('Patient', widget.patientName),
                        _buildSummaryRow(
                          'Medical Tools',
                          widget.hasMedicalTools
                              ? 'Patient has tools'
                              : 'Nurse brings tools',
                        ),
                        _buildSummaryRow(
                          'Time',
                          _selectedTimeOption == 'asap' ? 'ASAP' : 'Scheduled',
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Price',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'EGP ${widget.servicePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF17C47F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17C47F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF17C47F).withOpacity(0.3),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
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

  Widget _buildStepIndicator(int step, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF17C47F) : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? const Color(0xFF17C47F) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildTimeOptionCard({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _selectedTimeOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeOption = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF17C47F).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF17C47F) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFF17C47F)
                        : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? const Color(0xFF17C47F)
                              : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF17C47F),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPreferenceCard(String value, String label, IconData icon) {
    final isSelected = _nurseGenderPreference == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _nurseGenderPreference = isSelected ? null : value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF17C47F).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF17C47F) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? const Color(0xFF17C47F)
                      : const Color(0xFF64748B),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected
                        ? const Color(0xFF17C47F)
                        : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
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
}
