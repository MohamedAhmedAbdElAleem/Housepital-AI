import 'package:flutter/material.dart';
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
        const SnackBar(content: Text('Unable to retrieve user ID. Please try again.')),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null || _userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing. Cannot submit the form.')),
      );
      return;
    }

    setState(() { _isLoading = true; });
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
          'chronicConditions': _chronicController.text.trim(),
          'allergies': _allergiesController.text.trim(),
          'nationalId': _nationalIdController.text.trim(),
          'birthCertificateId': _birthCertificateIdController.text.trim(),
          'responsibleUser': _userId!,
        },
      );
      setState(() { _isLoading = false; });
      if (response['success'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add dependent')),
        );
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text('Add Dependent', style: TextStyle(color: Color(0xFF1E293B))),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dependent Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_fullNameController, 'Full Name', Icons.person),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRelationship,
                      decoration: InputDecoration(
                        labelText: 'Relationship',
                        prefixIcon: const Icon(Icons.group, color: Color(0xFF2ECC71)),
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
                      items: [
                        'father', 'mother', 'son', 'daughter', 'brother', 'sister', 'grandparent', 'grandchild', 'spouse', 'other'
                      ].map((rel) => DropdownMenuItem(value: rel, child: Text(rel))).toList(),
                      onChanged: (val) => setState(() => _selectedRelationship = val),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
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
                  _buildTextField(_mobileController, 'Mobile', Icons.phone),
                  _buildTextField(_chronicController, 'Chronic Conditions (comma separated)', Icons.healing),
                  _buildTextField(_allergiesController, 'Allergies (comma separated)', Icons.warning),
                  _buildTextField(_nationalIdController, 'National ID', Icons.badge),
                  _buildTextField(_birthCertificateIdController, 'Birth Certificate ID', Icons.description),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Gender:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _genderController.text = 'male';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _genderController.text == 'male' ? const Color(0xFF2ECC71) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _genderController.text == 'male' ? const Color(0xFF2ECC71) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  'Male',
                                  style: TextStyle(
                                    color: _genderController.text == 'male' ? Colors.white : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _genderController.text = 'female';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _genderController.text == 'female' ? const Color(0xFF2ECC71) : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _genderController.text == 'female' ? const Color(0xFF2ECC71) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Text(
                                  'Female',
                                  style: TextStyle(
                                    color: _genderController.text == 'female' ? Colors.white : const Color(0xFF1E293B),
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
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Dependent', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
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
