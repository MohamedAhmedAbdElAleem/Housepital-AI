import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_popup.dart';

class EditAddressPage extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _streetController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;

  late String _selectedType;
  late bool _isDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(
      text: widget.address['label'] ?? '',
    );
    _streetController = TextEditingController(
      text: widget.address['street'] ?? '',
    );
    _areaController = TextEditingController(text: widget.address['area'] ?? '');
    _cityController = TextEditingController(text: widget.address['city'] ?? '');
    _stateController = TextEditingController(
      text: widget.address['state'] ?? '',
    );
    _zipCodeController = TextEditingController(
      text: widget.address['zipCode'] ?? '',
    );
    _selectedType = widget.address['type'] ?? 'home';
    _isDefault = widget.address['isDefault'] ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          CustomPopup.error(context, 'User ID not found. Please log in again.');
        }
        return;
      }

      final apiService = ApiService();
      final response = await apiService.put(
        '/api/user/addresses/${widget.address['_id']}',
        body: {
          'userId': userId,
          'label': _labelController.text.trim(),
          'type': _selectedType,
          'street': _streetController.text.trim(),
          'area': _areaController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim(),
          'isDefault': _isDefault,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['message'] != null) {
          CustomPopup.success(context, 'Address updated successfully!');
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context, true);
        } else {
          CustomPopup.error(context, 'Failed to update address');
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
          'Edit Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    // Address Type Selection
                    _buildCard(
                      title: 'Address Type',
                      icon: Icons.category_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTypeOption(
                                'Home',
                                'home',
                                Icons.home_outlined,
                                AppColors.primary500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeOption(
                                'Work',
                                'work',
                                Icons.work_outline,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTypeOption(
                                'Other',
                                'other',
                                Icons.location_on_outlined,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Address Details
                    _buildCard(
                      title: 'Address Details',
                      icon: Icons.location_on_outlined,
                      children: [
                        _buildTextField(
                          controller: _labelController,
                          label: 'Label (Optional)',
                          hint: 'e.g., Home, Office',
                          icon: Icons.label_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _streetController,
                          label: 'Street Address',
                          hint: 'Enter street address',
                          icon: Icons.signpost_outlined,
                          validator:
                              (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _areaController,
                          label: 'Area',
                          hint: 'Enter area',
                          icon: Icons.map_outlined,
                          validator:
                              (v) => v?.isEmpty ?? true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'Enter city',
                                icon: Icons.location_city_outlined,
                                validator:
                                    (v) =>
                                        v?.isEmpty ?? true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'Enter state',
                                icon: Icons.public_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _zipCodeController,
                          label: 'Zip Code',
                          hint: 'Enter zip code',
                          icon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Default Address
                    _buildCard(
                      title: 'Preferences',
                      icon: Icons.settings_outlined,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: CheckboxListTile(
                            value: _isDefault,
                            onChanged:
                                (value) =>
                                    setState(() => _isDefault = value ?? false),
                            title: const Text(
                              'Set as default address',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Use this address by default for bookings',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            activeColor: AppColors.primary500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                    onPressed: _isLoading ? null : _updateAddress,
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
                              'Update Address',
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
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary500),
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
    );
  }

  Widget _buildTypeOption(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
