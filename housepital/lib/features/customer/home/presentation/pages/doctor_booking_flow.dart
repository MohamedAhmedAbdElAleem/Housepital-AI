import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:housepital/shared/models/doctor_model.dart';
import 'package:housepital/shared/models/service_model.dart';
import 'package:housepital/shared/models/clinic_model.dart';
import '../../../../../../core/utils/token_manager.dart';
import '../../../../../../core/constants/api_constants.dart';

class DoctorBookingFlow extends StatefulWidget {
  final DoctorModel doctor;
  final ServiceModel service;
  final ClinicModel clinic;

  const DoctorBookingFlow({
    super.key,
    required this.doctor,
    required this.service,
    required this.clinic,
  });

  @override
  State<DoctorBookingFlow> createState() => _DoctorBookingFlowState();
}

class _DoctorBookingFlowState extends State<DoctorBookingFlow> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  bool _isLoading = false;
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _updateTimeSlots();
  }

  Future<void> _updateTimeSlots() async {
    // 1. Get Day of Week (e.g., "monday")
    final dayName = DateFormat('EEEE').format(_selectedDate).toLowerCase();
    
    // 2. Find working hours for this day
    final workingHour = widget.clinic.workingHours.firstWhere(
      (w) => w.day.toLowerCase() == dayName && w.isOpen,
      orElse: () => WorkingHour(day: dayName, isOpen: false),
    );

    if (!workingHour.isOpen || workingHour.openTime == null || workingHour.closeTime == null) {
      setState(() {
        _availableTimeSlots = [];
        _selectedTime = null;
      });
      return;
    }

    // 3. Generate Slots
    final open = _parseTime(workingHour.openTime!);
    final close = _parseTime(workingHour.closeTime!);
    final duration = widget.clinic.slotDurationMinutes;

    List<String> slots = [];
    var current = open;
    
    while (current.hour < close.hour || (current.hour == close.hour && current.minute < close.minute)) {
      final timeStr = DateFormat('hh:mm a').format(current);
      slots.add(timeStr);
      current = current.add(Duration(minutes: duration));
    }

    // 4. Fetch booked slots and filter them out
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await dio.get('/bookings/slots', queryParameters: {
        'clinicId': widget.clinic.id,
        'date': dateStr,
      });
      
      if (response.statusCode == 200) {
        final bookedSlots = List<String>.from(response.data['bookedSlots'] ?? []);
        slots = slots.where((s) => !bookedSlots.contains(s)).toList();
      }
    } catch (e) {
      debugPrint('Could not fetch booked slots: $e');
    }

    if (mounted) {
      setState(() {
        _availableTimeSlots = slots;
        _selectedTime = null;
      });
    }
  }

  DateTime _parseTime(String timeStr) {
    // Format "HH:mm" expected
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  Future<void> _processBooking() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      
      // Get Auth Token
      final token = await TokenManager.getToken();
      final userId = await TokenManager.getUserId();
      
      dio.options.headers['Authorization'] = 'Bearer $token';

      // Create Booking
      await dio.post('/bookings/create', data: {
        'serviceId': widget.service.id,
        'serviceName': widget.service.name,
        'servicePrice': widget.service.price,
        'patientId': userId,
        'type': 'clinic_appointment',
        'doctorId': widget.doctor.id,
        'clinicId': widget.clinic.id,
        'timeOption': 'schedule',
        'scheduledDate': _selectedDate.toIso8601String(),
        'scheduledTime': _selectedTime,
        'isForSelf': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment Booked Successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                   Row(children: [
                     const Icon(Icons.medical_services, size: 16, color: Colors.blue),
                     const SizedBox(width: 8),
                     Expanded(child: Text("Service: ${widget.service.name}", style: const TextStyle(fontWeight: FontWeight.bold))),
                     Text("${widget.service.price} EGP", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                   ]),
                   const SizedBox(height: 8),
                   Row(children: [
                     const Icon(Icons.location_on, size: 16, color: Colors.red),
                     const SizedBox(width: 8),
                     Expanded(child: Text("Clinic: ${widget.clinic.name}")),
                   ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text('Select Date', style: Theme.of(context).textTheme.titleLarge),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
                _updateTimeSlots();
              },
            ),
            const SizedBox(height: 20),
            
            Text('Select Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            
            if (_availableTimeSlots.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Clinic is closed on this day.", style: TextStyle(color: Colors.red)),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableTimeSlots.map((time) {
                      final isSelected = _selectedTime == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedTime = selected ? time : null);
                        },
                        selectedColor: const Color(0xFF00D47F),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                ),
              ),
            
            if (_availableTimeSlots.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: const Color(0xFF00D47F),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Confirm Booking (${widget.service.price} EGP)',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
