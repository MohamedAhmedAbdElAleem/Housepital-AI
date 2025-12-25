import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';

class AddDependentPage extends StatefulWidget {
  const AddDependentPage({Key? key}) : super(key: key);

  @override
  State<AddDependentPage> createState() => _AddDependentPageState();
}

class _AddDependentPageState extends State<AddDependentPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _mobileController = TextEditingController();
  final _chronicController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _birthCertificateIdController = TextEditingController();

  bool _isLoading = false;
  String? _selectedRelationship;
  DateTime? _selectedDate;
  String? _userId;
  File? _profileImage;
  List<String> _chronicDiseases = [];
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await TokenManager.getUserId();
    if (_userId == null || _userId!.isEmpty) {
      // Log an error and handle missing user ID
      debugPrint('Error: User ID is missing or invalid.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve user ID. Please try again.'),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _relationshipController.dispose();
    _dateOfBirthController.dispose();
    _genderController.dispose();
    _mobileController.dispose();
    _chronicController.dispose();
    _allergiesController.dispose();
    _nationalIdController.dispose();
    _birthCertificateIdController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID is missing. Cannot submit the form.'),
        ),
      );
      return;
    }

    // Validate relationship
    if (_selectedRelationship == null || _selectedRelationship!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a relationship'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validate gender
    if (_genderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select gender'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validate date of birth
    if (_dateOfBirthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Validate that at least one ID is provided
    if (_nationalIdController.text.trim().isEmpty &&
        _birthCertificateIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please provide either National ID or Birth Certificate ID',
          ),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/api/user/addDependent',
        body: {
          'fullName': _fullNameController.text.trim(),
          'relationship': _selectedRelationship ?? '',
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'gender': _genderController.text.trim(),
          'mobile': _mobileController.text.trim(),
          'chronicConditions': _chronicDiseases,
          'allergies': _allergies,
          'nationalId': _nationalIdController.text.trim(),
          'birthCertificateId': _birthCertificateIdController.text.trim(),
          'responsibleUser': _userId!,
        },
      );
      setState(() {
        _isLoading = false;
      });
      if (response['success'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to add dependent'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          'Add Member',
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
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child:
                                _profileImage != null
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

                    // Full Name (keep original)
                    _buildTextField(
                      _fullNameController,
                      'Full Name',
                      Icons.person,
                    ),

                    // Relationship (keep original)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        decoration: InputDecoration(
                          labelText: 'Relationship',
                          prefixIcon: const Icon(
                            Icons.group,
                            color: Color(0xFF2ECC71),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF2ECC71),
                            ),
                          ),
                        ),
                        items:
                            [
                                  'father',
                                  'mother',
                                  'son',
                                  'daughter',
                                  'brother',
                                  'sister',
                                  'grandparent',
                                  'grandchild',
                                  'spouse',
                                  'other',
                                ]
                                .map(
                                  (rel) => DropdownMenuItem(
                                    value: rel,
                                    child: Text(rel),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) =>
                                setState(() => _selectedRelationship = val),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),

                    // Gender Selection (keep original)
                    Row(
                      children: [
                        const Text(
                          'Gender:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _genderController.text = 'male',
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _genderController.text == 'male'
                                            ? const Color(0xFF2ECC71)
                                            : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          _genderController.text == 'male'
                                              ? const Color(0xFF2ECC71)
                                              : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    'Male',
                                    style: TextStyle(
                                      color:
                                          _genderController.text == 'male'
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap:
                                    () => setState(
                                      () => _genderController.text = 'female',
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _genderController.text == 'female'
                                            ? const Color(0xFF2ECC71)
                                            : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          _genderController.text == 'female'
                                              ? const Color(0xFF2ECC71)
                                              : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Text(
                                    'Female',
                                    style: TextStyle(
                                      color:
                                          _genderController.text == 'female'
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth (keep original)
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _buildTextField(
                          _dateOfBirthController,
                          'Date of Birth (YYYY-MM-DD)',
                          Icons.cake,
                        ),
                      ),
                    ),

                    // Mobile (keep original)
                    _buildTextField(_mobileController, 'Mobile', Icons.phone),

                    // Chronic Diseases - New wireframe style
                    const Text(
                      'Chronic Diseases',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _chronicController,
                            decoration: InputDecoration(
                              hintText: 'E.g., Diabetes',
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2ECC71),
                                  width: 2,
                                ),
                              ),
                            ),
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
                        children:
                            _chronicDiseases
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Chip(
                                    label: Text(entry.value),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onDeleted:
                                        () => _removeChronicDisease(entry.key),
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

                    // Known Allergies - New wireframe style
                    const Text(
                      'Known Allergies',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _allergiesController,
                            decoration: InputDecoration(
                              hintText: 'E.g., Penicillin, Peanuts...',
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
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2ECC71),
                                  width: 2,
                                ),
                              ),
                            ),
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
                        children:
                            _allergies
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Chip(
                                    label: Text(entry.value),
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
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
                    const SizedBox(height: 24),

                    // National ID or Birth Certificate ID Section
                    const Text(
                      'Identification (One Required)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Please provide either National ID or Birth Certificate ID',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 12),

                    // National ID
                    TextFormField(
                      controller: _nationalIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                      decoration: InputDecoration(
                        labelText: 'National ID',
                        hintText: '14 digits',
                        prefixIcon: const Icon(
                          Icons.badge,
                          color: Color(0xFF2ECC71),
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
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Birth Certificate ID
                    TextFormField(
                      controller: _birthCertificateIdController,
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      decoration: InputDecoration(
                        labelText: 'Birth Certificate ID',
                        hintText: '9-20 digits',
                        prefixIcon: const Icon(
                          Icons.description,
                          color: Color(0xFF2ECC71),
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
                        counterText: '',
                      ),
                    ),
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
                  top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2ECC71)),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2ECC71)),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }
}
