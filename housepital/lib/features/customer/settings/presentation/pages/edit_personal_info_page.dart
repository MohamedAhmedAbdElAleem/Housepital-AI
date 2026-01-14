import 'package:flutter/material.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/widgets/custom_popup.dart';

class EditPersonalInfoPage extends StatefulWidget {
  final UserModel user;

  const EditPersonalInfoPage({super.key, required this.user});

  @override
  State<EditPersonalInfoPage> createState() => _EditPersonalInfoPageState();
}

class _EditPersonalInfoPageState extends State<EditPersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _mobileController = TextEditingController(text: widget.user.mobile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();

      // Make API call to update user info
      await apiService.put(
        '/api/user/update-profile',
        body: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim().toLowerCase(),
          'mobile': _mobileController.text.trim(),
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        CustomPopup.success(context, 'Profile updated successfully');

        // Wait a bit to show the popup, then go back and refresh the previous page
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomPopup.error(context, 'Failed to update profile: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: const Color(0xFF1E293B),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Edit Personal Info',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2ECC71),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[600],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              Text(
                'FULL NAME',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline,
                iconColor: const Color(0xFF3B82F6),
                hintText: 'Enter your full name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Email Field
              Text(
                'EMAIL ADDRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                iconColor: const Color(0xFF8B5CF6),
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Mobile Field
              Text(
                'MOBILE NUMBER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _mobileController,
                icon: Icons.phone_outlined,
                iconColor: const Color(0xFF10B981),
                hintText: 'Enter your mobile number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Enter a valid mobile number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Changes will be reflected across all your account settings',
                        style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
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
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
