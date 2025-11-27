import 'package:flutter/material.dart';
import 'booking_step3_visit_details.dart';

class BookingStep2MedicalTools extends StatefulWidget {
  final String serviceName;
  final String serviceId;
  final double servicePrice;
  final String patientId;
  final String patientName;
  final bool isForSelf;

  const BookingStep2MedicalTools({
    Key? key,
    required this.serviceName,
    required this.serviceId,
    required this.servicePrice,
    required this.patientId,
    required this.patientName,
    required this.isForSelf,
  }) : super(key: key);

  @override
  State<BookingStep2MedicalTools> createState() =>
      _BookingStep2MedicalToolsState();
}

class _BookingStep2MedicalToolsState extends State<BookingStep2MedicalTools> {
  String _selectedOption = 'nurse_brings'; // 'nurse_brings' or 'i_have_tools'

  void _continueToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => BookingStep3VisitDetails(
              serviceName: widget.serviceName,
              serviceId: widget.serviceId,
              servicePrice: widget.servicePrice,
              patientId: widget.patientId,
              patientName: widget.patientName,
              isForSelf: widget.isForSelf,
              hasMedicalTools: _selectedOption == 'i_have_tools',
            ),
      ),
    );
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
                    'Medical Tools & Equipment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Do you have the required medical tools, or should the nurse bring them?',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Option 1: Nurse Brings Tools
                  _buildOptionCard(
                    value: 'nurse_brings',
                    title: 'Nurse Will Bring Equipment',
                    description:
                        'The nurse will bring all necessary medical tools and equipment',
                    icon: Icons.medical_services,
                    iconColor: const Color(0xFF17C47F),
                    recommended: true,
                  ),

                  const SizedBox(height: 16),

                  // Option 2: I Have Tools
                  _buildOptionCard(
                    value: 'i_have_tools',
                    title: 'I Have the Equipment',
                    description:
                        'I already have the required medical tools at home',
                    icon: Icons.home_repair_service_outlined,
                    iconColor: const Color(0xFF3B82F6),
                  ),

                  const SizedBox(height: 24),

                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF3B82F6),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Important Note',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3B82F6),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'If specific medical equipment is required for this service, the nurse will contact you before the visit to confirm.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildOptionCard({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    bool recommended = false,
  }) {
    final isSelected = _selectedOption == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? iconColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? iconColor : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? iconColor
                                        : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (recommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF17C47F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Recommended',
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
                        description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: iconColor, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
