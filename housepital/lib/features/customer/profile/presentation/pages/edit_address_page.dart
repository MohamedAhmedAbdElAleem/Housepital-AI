import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../../core/widgets/custom_popup.dart';

class _AddressDesign {
  static const primaryGreen = Color(0xFF00C853);
  static const surface = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const cardBg = Colors.white;
  static const inputBorder = Color(0xFFE2E8F0);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00E676), Color(0xFF69F0AE)],
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow get softShadow => BoxShadow(
    color: primaryGreen.withOpacity(0.15),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

class EditAddressPage extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressPage({super.key, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage>
    with TickerProviderStateMixin {
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
  bool _hasChanges = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupListeners();
  }

  void _initializeControllers() {
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

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  void _setupListeners() {
    _labelController.addListener(_onFieldChanged);
    _streetController.addListener(_onFieldChanged);
    _areaController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _stateController.addListener(_onFieldChanged);
    _zipCodeController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _labelController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _updateAddress() async {
    HapticFeedback.mediumImpact();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
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
          HapticFeedback.heavyImpact();
          _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _AddressDesign.headerGradient,
                    shape: BoxShape.circle,
                    boxShadow: [_AddressDesign.softShadow],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Address Updated!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _AddressDesign.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your address has been updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _AddressDesign.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showDiscardDialog() {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Discard Changes?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _AddressDesign.textPrimary,
                  ),
                ),
              ],
            ),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave without saving?',
              style: TextStyle(
                fontSize: 15,
                color: _AddressDesign.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Editing',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('Discard'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AddressDesign.surface,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeCard(),
                        const SizedBox(height: 20),
                        _buildDetailsCard(),
                        const SizedBox(height: 20),
                        _buildPreferencesCard(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    IconData typeIcon;
    switch (_selectedType.toLowerCase()) {
      case 'work':
        typeIcon = Icons.work_rounded;
        break;
      case 'other':
        typeIcon = Icons.place_rounded;
        break;
      default:
        typeIcon = Icons.home_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: _AddressDesign.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [_AddressDesign.softShadow],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _showDiscardDialog,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(typeIcon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _labelController.text.isNotEmpty
                                ? _labelController.text
                                : _capitalize(_selectedType),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _selectedType.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_hasChanges) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Modified',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
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
    );
  }

  Widget _buildTypeCard() {
    return _buildCard(
      title: 'Address Type',
      icon: Icons.category_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                'Home',
                'home',
                Icons.home_rounded,
                _AddressDesign.primaryGreen,
                [const Color(0xFF00C853), const Color(0xFF00E676)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                'Work',
                'work',
                Icons.work_rounded,
                Colors.blue,
                [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                'Other',
                'other',
                Icons.place_rounded,
                Colors.purple,
                [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return _buildCard(
      title: 'Address Details',
      icon: Icons.location_on_outlined,
      children: [
        _buildTextField(
          controller: _labelController,
          label: 'Label (Optional)',
          hint: 'e.g., Home, Office, Mom\'s Place',
          icon: Icons.label_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _streetController,
          label: 'Street Address',
          hint: 'Enter street address',
          icon: Icons.signpost_outlined,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _areaController,
          label: 'Area / District',
          hint: 'Enter area or district',
          icon: Icons.map_outlined,
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
          label: 'Zip / Postal Code',
          hint: 'Enter zip code',
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    return _buildCard(
      title: 'Preferences',
      icon: Icons.settings_outlined,
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _isDefault = !_isDefault;
              _hasChanges = true;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _isDefault
                      ? _AddressDesign.primaryGreen.withOpacity(0.1)
                      : _AddressDesign.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _isDefault
                        ? _AddressDesign.primaryGreen
                        : _AddressDesign.inputBorder,
                width: _isDefault ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isDefault ? _AddressDesign.headerGradient : null,
                    color: _isDefault ? null : _AddressDesign.surface,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        _isDefault
                            ? null
                            : Border.all(color: _AddressDesign.inputBorder),
                  ),
                  child: Icon(
                    _isDefault
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: _isDefault ? Colors.white : Colors.grey,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set as default address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              _isDefault
                                  ? _AddressDesign.primaryGreen
                                  : _AddressDesign.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use this address by default for bookings',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        _isDefault
                            ? _AddressDesign.primaryGreen
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _isDefault
                              ? _AddressDesign.primaryGreen
                              : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child:
                      _isDefault
                          ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                          : null,
                ),
              ],
            ),
          ),
        ),
      ],
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
        color: _AddressDesign.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [_AddressDesign.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: _AddressDesign.headerGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _AddressDesign.textPrimary,
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
      style: const TextStyle(fontSize: 16, color: _AddressDesign.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _AddressDesign.textSecondary),
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: _AddressDesign.primaryGreen),
        filled: true,
        fillColor: _AddressDesign.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AddressDesign.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _AddressDesign.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _AddressDesign.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeOption(
    String label,
    String value,
    IconData icon,
    Color color,
    List<Color> gradientColors,
  ) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedType = value;
          _hasChanges = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradientColors) : null,
          color: isSelected ? null : _AddressDesign.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : _AddressDesign.inputBorder,
            width: isSelected ? 0 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading || !_hasChanges ? null : _updateAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasChanges ? _AddressDesign.primaryGreen : Colors.grey[400],
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
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _hasChanges
                              ? Icons.save_rounded
                              : Icons.check_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _hasChanges ? 'Save Changes' : 'No Changes',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
