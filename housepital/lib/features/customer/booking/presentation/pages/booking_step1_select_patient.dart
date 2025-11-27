import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../customer/profile/presentation/pages/add_dependent_page.dart';
import 'booking_step2_medical_tools.dart';

class BookingStep1SelectPatient extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final double servicePrice;

  const BookingStep1SelectPatient({
    Key? key,
    required this.serviceName,
    required this.serviceId,
    required this.servicePrice,
  }) : super(key: key);

  @override
  State<BookingStep1SelectPatient> createState() =>
      _BookingStep1SelectPatientState();
}

class _BookingStep1SelectPatientState extends State<BookingStep1SelectPatient> {
  List<dynamic> _dependents = [];
  String? _selectedPatientId;
  String? _selectedPatientName;
  bool _isLoadingDependents = true;
  bool _isLoadingUser = true;
  String? _userId;
  String? _userName;
  bool _isForSelf = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDependents();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await TokenManager.getUserId();
      debugPrint('🔍 Booking: Loading user data, userId from storage: $userId');

      final apiService = ApiService();
      final response = await apiService.get('/api/auth/me');

      debugPrint('🔍 Booking: API response: $response');

      if (mounted) {
        if (response is Map && response['user'] != null) {
          final user = response['user'];
          setState(() {
            _userId = user['_id'] ?? userId;
            _userName = user['name'] ?? 'User';
            _isLoadingUser = false;
          });
          debugPrint('✅ Booking: User loaded - ID: $_userId, Name: $_userName');
        } else {
          // Fallback: use userId from storage
          setState(() {
            _userId = userId;
            _userName = 'Me';
            _isLoadingUser = false;
          });
          debugPrint('⚠️ Booking: Using fallback user data');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      // Fallback to stored userId
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
        if (mounted) {
          setState(() {
            _isLoadingDependents = false;
          });
        }
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
      debugPrint('Error loading dependents: $e');
      if (mounted) {
        setState(() {
          _isLoadingDependents = false;
        });
      }
    }
  }

  void _selectPatient(String id, String name, bool isForSelf) {
    setState(() {
      _selectedPatientId = id;
      _selectedPatientName = name;
      _isForSelf = isForSelf;
    });
  }

  void _continueToNextStep() {
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who this service is for')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingStep2MedicalTools(
              serviceName: widget.serviceName,
              serviceId: widget.serviceId,
              servicePrice: widget.servicePrice,
              patientId: _selectedPatientId!,
              patientName: _selectedPatientName!,
              isForSelf: _isForSelf,
            ),
      ),
    );
  }

  Future<void> _addNewMember() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDependentPage()),
    );
    if (result == true) {
      _loadDependents();
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
                Expanded(child: _buildStepLine(false)),
                _buildStepIndicator(2, false),
                Expanded(child: _buildStepLine(false)),
                _buildStepIndicator(3, false),
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
                    'Who is this service for?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the person who will receive ${widget.serviceName}',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // For Myself Option
                  if (!_isLoadingUser && _userId != null) ...[
                    _buildPatientCard(
                      name: _userName ?? 'Me',
                      subtitle: 'Book for myself',
                      icon: Icons.person,
                      isSelected: _isForSelf && _selectedPatientId == _userId,
                      onTap:
                          () =>
                              _selectPatient(_userId!, _userName ?? 'Me', true),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dependents Section
                  const Text(
                    'Family Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingDependents)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF17C47F),
                        ),
                      ),
                    )
                  else if (_dependents.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.family_restroom,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No family members added yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...(_dependents.map((dependent) {
                      final id = dependent['_id'] ?? '';
                      final name = dependent['fullName'] ?? 'Unknown';
                      final relationship = dependent['relationship'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPatientCard(
                          name: name,
                          subtitle: relationship,
                          icon: Icons.person_outline,
                          isSelected: _selectedPatientId == id && !_isForSelf,
                          onTap: () => _selectPatient(id, name, false),
                        ),
                      );
                    }).toList()),

                  const SizedBox(height: 16),

                  // Add New Member Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _addNewMember,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFF17C47F),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Add New Family Member',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Continue Button
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
              onPressed: _continueToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17C47F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF17C47F).withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, size: 22),
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

  Widget _buildPatientCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF17C47F) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF17C47F).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
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
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected
                              ? const Color(0xFF17C47F)
                              : const Color(0xFF1E293B),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF17C47F),
                size: 26,
              ),
          ],
        ),
      ),
    );
  }
}
