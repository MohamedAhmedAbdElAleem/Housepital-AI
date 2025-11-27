import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/network/api_service.dart';

class EditDependentPage extends StatefulWidget {
  final Map<String, dynamic> dependent;

  const EditDependentPage({Key? key, required this.dependent})
    : super(key: key);

  @override
  State<EditDependentPage> createState() => _EditDependentPageState();
}

class _EditDependentPageState extends State<EditDependentPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();

  String? _selectedRelationship;
  String _selectedGender = 'male';
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  File? _profileImage;
  List<String> _chronicDiseases = [];
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.dependent['fullName'] ?? '';
    _selectedRelationship = widget.dependent['relationship']?.toString().toLowerCase();
    _selectedGender = widget.dependent['gender'] ?? 'male';

    // Load chronic conditions
    if (widget.dependent['chronicConditions'] != null) {
      if (widget.dependent['chronicConditions'] is List) {
        _chronicDiseases = List<String>.from(widget.dependent['chronicConditions'])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && e != '[]')
          .toList();
      } else {
        final conditions = widget.dependent['chronicConditions'].toString();
        if (conditions.isNotEmpty && conditions != '[]' && conditions != 'null') {
          // Remove brackets if present and split
          final cleaned = conditions.replaceAll('[', '').replaceAll(']', '');
          _chronicDiseases = cleaned.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        }
      }
    }

    // Load allergies
    if (widget.dependent['allergies'] != null) {
      if (widget.dependent['allergies'] is List) {
        _allergies = List<String>.from(widget.dependent['allergies'])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && e != '[]')
          .toList();
      } else {
        final allergies = widget.dependent['allergies'].toString();
        if (allergies.isNotEmpty && allergies != '[]' && allergies != 'null') {
          // Remove brackets if present and split
          final cleaned = allergies.replaceAll('[', '').replaceAll(']', '');
          _allergies = cleaned.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        }
      }
    }

    if (widget.dependent['dateOfBirth'] != null &&
        widget.dependent['dateOfBirth'].isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(widget.dependent['dateOfBirth']);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addChronicDisease() {
    if (_chronicController.text.trim().isNotEmpty) {
      setState(() {
        _chronicDiseases.add(_chronicController.text.trim());
        _chronicController.clear();
      });
    }
  }

  void _removeChronicDisease(int index) {
    setState(() {
      _chronicDiseases.removeAt(index);
    });
  }

  void _addAllergy() {
    if (_allergiesController.text.trim().isNotEmpty) {
      setState(() {
        _allergies.add(_allergiesController.text.trim());
        _allergiesController.clear();
      });
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF17C47F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _updateDependent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select gender'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_selectedRelationship == null || _selectedRelationship!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select relationship'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();
      final dependentId = widget.dependent['_id'] ?? widget.dependent['id'];

      final dependentData = {
        'fullName': _fullNameController.text.trim(),
        'relationship': _selectedRelationship ?? '',
        'gender': _selectedGender,
        'dateOfBirth': _selectedDate!.toIso8601String(),
        'chronicConditions': _chronicDiseases,
        'allergies': _allergies,
      };

      await apiService.put(
        '/api/user/dependent/$dependentId',
        body: dependentData,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dependent updated successfully'),
            backgroundColor: Color(0xFF17C47F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating dependent: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _deleteDependent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Dependent'),
            content: Text(
              'Are you sure you want to delete ${widget.dependent['fullName']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();
      final dependentId = widget.dependent['_id'] ?? widget.dependent['id'];

      await apiService.delete('/api/user/dependent/$dependentId');

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dependent deleted successfully'),
            backgroundColor: Color(0xFF17C47F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting dependent: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C3E50)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: Color(0xFF9CA3AF),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Full Name
                    _buildLabel('Full Name'),
                    _buildTextField(
                      _fullNameController,
                      'E.g., Sarah Ali',
                    ),
                    const SizedBox(height: 20),

                    // Relationship & Gender Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Relation'),
                              DropdownButtonFormField<String>(
                                value: _selectedRelationship,
                                decoration: _buildInputDecoration('Select'),
                                items: [
                                  'Father',
                                  'Mother',
                                  'Son',
                                  'Daughter',
                                  'Brother',
                                  'Sister',
                                  'Grandparent',
                                  'Grandchild',
                                  'Spouse',
                                  'Other',
                                ]
                                    .map(
                                      (rel) => DropdownMenuItem(
                                        value: rel.toLowerCase(),
                                        child: Text(rel),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedRelationship = val),
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Gender'),
                              DropdownButtonFormField<String>(
                                value: _selectedGender,
                                decoration: _buildInputDecoration('Select'),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedGender = val ?? 'male';
                                  });
                                },
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date of Birth
                    _buildLabel('Date of Birth'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: _buildInputDecoration(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Select date',
                          ),
                          validator: (v) => _selectedDate == null ? 'Required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Chronic Diseases
                    _buildLabel('Chronic Diseases'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chronicController,
                            decoration: _buildInputDecoration('E.g., Diabetes'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addChronicDisease,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_chronicDiseases.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _chronicDiseases
                            .asMap()
                            .entries
                            .map(
                              (entry) => Chip(
                                label: Text(entry.value),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () =>
                                    _removeChronicDisease(entry.key),
                                backgroundColor: const Color(0xFFFEF2F2),
                                labelStyle: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                deleteIconColor: const Color(0xFFEF4444),
                                side: const BorderSide(
                                  color: Color(0xFFFECACA),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (_chronicDiseases.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'No chronic diseases listed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Known Allergies
                    _buildLabel('Known Allergies'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _allergiesController,
                            decoration: _buildInputDecoration('E.g., Penicillin, Peanuts...'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addAllergy,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_allergies.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allergies
                            .asMap()
                            .entries
                            .map(
                              (entry) => Chip(
                                label: Text(entry.value),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _removeAllergy(entry.key),
                                backgroundColor: const Color(0xFFFEF2F2),
                                labelStyle: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                deleteIconColor: const Color(0xFFEF4444),
                                side: const BorderSide(
                                  color: Color(0xFFFECACA),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (_allergies.isEmpty) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'No allergies listed.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            
            // Bottom Button Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _updateDependent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: const Color(0xFFE5E7EB),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Save Profile',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSubmitting ? null : _deleteDependent,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 16, color: Color(0xFFEF4444)),
                        SizedBox(width: 8),
                        Text(
                          'Remove Member',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 16,
      ),
      filled: true,
      fillColor: const Color(0xFFE5E7EB),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFF2ECC71),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFEF4444),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(hint),
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
    );
  }
}
