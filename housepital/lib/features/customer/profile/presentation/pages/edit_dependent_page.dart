import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_popup.dart';

class EditDependentPage extends StatefulWidget {
  final Map<String, dynamic> dependent;

  const EditDependentPage({super.key, required this.dependent});

  @override
  State<EditDependentPage> createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _mobileController;
  late TextEditingController _nationalIdController;
  late TextEditingController _birthCertificateIdController;

  bool _isLoading = false;
  String? _selectedRelationship;
  String _selectedGender = 'male';
  DateTime? _selectedDate;
  List<String> _chronicDiseases = [];
  List<String> _allergies = [];

  final List<String> _relationships = [
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Spouse',
    'Grandparent',
    'Grandchild',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.dependent['fullName'] ?? '',
    );
    _mobileController = TextEditingController(
      text: widget.dependent['mobile'] ?? '',
    );
    _nationalIdController = TextEditingController(
      text: widget.dependent['nationalId'] ?? '',
    );
    _birthCertificateIdController = TextEditingController(
      text: widget.dependent['birthCertificateId'] ?? '',
    );

    _selectedRelationship =
        widget.dependent['relationship'] != null
            ? _capitalizeFirst(widget.dependent['relationship'])
            : null;
    _selectedGender = widget.dependent['gender'] ?? 'male';

    if (widget.dependent['dateOfBirth'] != null) {
      try {
        _selectedDate = DateTime.parse(widget.dependent['dateOfBirth']);
      } catch (e) {
        _selectedDate = null;
      }
    }

    _chronicDiseases = List<String>.from(
      widget.dependent['chronicConditions'] ?? [],
    );
    _allergies = List<String>.from(widget.dependent['allergies'] ?? []);
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _nationalIdController.dispose();
    _birthCertificateIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary500,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addChronicDisease() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Chronic Disease'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., Diabetes',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() => _chronicDiseases.add(controller.text.trim()));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addAllergy() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Add Allergy'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., Penicillin',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() => _allergies.add(controller.text.trim()));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDependent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRelationship == null) {
      CustomPopup.warning(context, 'Please select a relationship');
      return;
    }

    if (_selectedDate == null) {
      CustomPopup.warning(context, 'Please select date of birth');
      return;
    }

    if (_nationalIdController.text.trim().isEmpty &&
        _birthCertificateIdController.text.trim().isEmpty) {
      CustomPopup.warning(
        context,
        'Please provide either National ID or Birth Certificate ID',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/updateDependent',
        body: {
          'id': widget.dependent['_id'],
          'fullName': _fullNameController.text.trim(),
          'relationship': _selectedRelationship!.toLowerCase(),
          'dateOfBirth': _selectedDate!.toIso8601String().substring(0, 10),
          'gender': _selectedGender,
          'mobile': _mobileController.text.trim(),
          'chronicConditions': _chronicDiseases,
          'allergies': _allergies,
          'nationalId': _nationalIdController.text.trim(),
          'birthCertificateId': _birthCertificateIdController.text.trim(),
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['success'] == true) {
          CustomPopup.success(context, 'Family member updated successfully!');
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true);
        } else {
          CustomPopup.error(
            context,
            response['message'] ?? 'Failed to update member',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomPopup.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _deleteDependent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Delete Family Member'),
            content: const Text(
              'Are you sure you want to delete this family member? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final response = await apiService.delete(
        '/api/user/deleteDependent?id=${widget.dependent['_id']}',
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['success'] == true) {
          CustomPopup.success(context, 'Family member deleted successfully');
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true);
        } else {
          CustomPopup.error(
            context,
            response['message'] ?? 'Failed to delete member',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        CustomPopup.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary500,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.white,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Edit Family Member',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 22),
              color: Colors.white,
              onPressed: _deleteDependent,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Card
                    _buildCard(
                      title: 'Basic Information',
                      icon: Icons.person_outline,
                      children: [
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          icon: Icons.badge_outlined,
                          validator:
                              (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(),
                        const SizedBox(height: 16),
                        _buildGenderSelector(),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _mobileController,
                          label: 'Mobile Number (Optional)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Identification Card
                    _buildCard(
                      title: 'Identification',
                      icon: Icons.credit_card_outlined,
                      children: [
                        Text(
                          'Provide at least one ID',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nationalIdController,
                          label: 'National ID',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 14,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _birthCertificateIdController,
                          label: 'Birth Certificate ID',
                          icon: Icons.description_outlined,
                          keyboardType: TextInputType.number,
                          maxLength: 20,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Medical Information Card
                    _buildCard(
                      title: 'Medical Information',
                      icon: Icons.medical_information_outlined,
                      children: [
                        _buildChipSection(
                          title: 'Chronic Diseases',
                          items: _chronicDiseases,
                          onAdd: _addChronicDisease,
                          onRemove:
                              (i) =>
                                  setState(() => _chronicDiseases.removeAt(i)),
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        _buildChipSection(
                          title: 'Allergies',
                          items: _allergies,
                          onAdd: _addAllergy,
                          onRemove:
                              (i) => setState(() => _allergies.removeAt(i)),
                          color: Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Update Button
            Container(
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
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateDependent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                            : const Text(
                              'Update Family Member',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary500, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary500),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        counterText: '',
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
          borderSide: BorderSide(color: AppColors.primary500, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRelationship,
      decoration: InputDecoration(
        labelText: 'Relationship',
        prefixIcon: Icon(Icons.family_restroom, color: AppColors.primary500),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
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
          borderSide: BorderSide(color: AppColors.primary500, width: 2),
        ),
      ),
      items:
          _relationships
              .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
              .toList(),
      onChanged: (val) => setState(() => _selectedRelationship = val),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                'Male',
                'male',
                Icons.male,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderOption(
                'Female',
                'female',
                Icons.female,
                Colors.pink,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, color: AppColors.primary500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Select Date of Birth'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      _selectedDate == null ? Colors.grey[600] : Colors.black,
                ),
              ),
            ),
            Icon(Icons.calendar_today, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        items.isEmpty
            ? Text(
              'No $title added',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            )
            : Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  items.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => onRemove(entry.key),
                      backgroundColor: color.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: color.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIconColor: color,
                      side: BorderSide(color: color.withOpacity(0.3)),
                    );
                  }).toList(),
            ),
      ],
    );
  }
}
