import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';

class AddAddressPage extends StatefulWidget {
  final Map<String, dynamic>? existingAddress;

  const AddAddressPage({Key? key, this.existingAddress}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  String _selectedType = 'home';
  bool _isDefault = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      _labelController.text = widget.existingAddress!['label'] ?? '';
      _streetController.text = widget.existingAddress!['street'] ?? '';
      _areaController.text = widget.existingAddress!['area'] ?? '';
      _cityController.text = widget.existingAddress!['city'] ?? '';
      _stateController.text = widget.existingAddress!['state'] ?? '';
      _zipCodeController.text = widget.existingAddress!['zipCode'] ?? '';
      _selectedType = widget.existingAddress!['type'] ?? 'home';
      _isDefault = widget.existingAddress!['isDefault'] ?? false;
    }
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

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception('User not logged in');
      }

      final apiService = ApiService();
      final addressData = {
        'userId': userId,
        'label': _labelController.text.trim(),
        'type': _selectedType,
        'street': _streetController.text.trim(),
        'area': _areaController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipCodeController.text.trim(),
        'isDefault': _isDefault,
      };

      if (widget.existingAddress != null) {
        // Update existing address
        final addressId =
            widget.existingAddress!['_id'] ?? widget.existingAddress!['id'];
        await apiService.put(
          '/api/user/addresses/$addressId',
          body: addressData,
        );
      } else {
        // Add new address
        await apiService.post('/api/user/addresses', body: addressData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingAddress != null
                  ? 'Address updated successfully'
                  : 'Address added successfully',
            ),
            backgroundColor: const Color(0xFF17C47F),
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
            content: Text('Error saving address: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAddress != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Address' : 'Add New Address',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Address Type Selection
            const Text(
              'Address Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTypeCard('home', 'Home', Icons.home)),
                const SizedBox(width: 12),
                Expanded(child: _buildTypeCard('work', 'Work', Icons.business)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeCard('other', 'Other', Icons.location_on),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Label (e.g., "Mom's House", "Office")
            const Text(
              'Label (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                hintText: 'e.g., "Mom\'s House", "Main Office"',
                prefixIcon: const Icon(Icons.label, color: Color(0xFF17C47F)),
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
                helperText: 'Give this address a memorable name',
                helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),

            const SizedBox(height: 20),

            // Street Address
            const Text(
              'Street Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _streetController,
              decoration: InputDecoration(
                hintText: 'Enter street address',
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color(0xFF17C47F),
                ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter street address';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Area/District
            const Text(
              'Area/District',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                hintText: 'Enter area or district',
                prefixIcon: const Icon(
                  Icons.place,
                  color: Color(0xFF17C47F),
                ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter area or district';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // City
            const Text(
              'City',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter city',
                prefixIcon: const Icon(
                  Icons.location_city,
                  color: Color(0xFF17C47F),
                ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter city';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // State
            const Text(
              'State/Province',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(
                hintText: 'Enter state or province',
                prefixIcon: const Icon(Icons.map, color: Color(0xFF17C47F)),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter state or province';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Zip Code
            const Text(
              'Zip Code (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _zipCodeController,
              decoration: InputDecoration(
                hintText: 'Enter zip code',
                prefixIcon: const Icon(Icons.mail, color: Color(0xFF17C47F)),
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

            // Set as Default
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: CheckboxListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                title: const Text(
                  'Set as default address',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                subtitle: Text(
                  'This address will be selected automatically',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                activeColor: const Color(0xFF17C47F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF17C47F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: const Color(0xFF17C47F).withOpacity(0.3),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        isEditing ? 'Update Address' : 'Save Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;

    Color typeColor;
    switch (value) {
      case 'home':
        typeColor = const Color(0xFF3B82F6);
        break;
      case 'work':
        typeColor = const Color(0xFFF59E0B);
        break;
      default:
        typeColor = const Color(0xFF8B5CF6);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? typeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? typeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? typeColor : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? typeColor : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
