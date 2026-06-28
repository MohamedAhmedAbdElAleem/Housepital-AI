import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:housepital/generated/l10n/app_localizations.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../../../core/widgets/custom_popup.dart';
import 'location_picker_page.dart';

class _AddressDesign {
  final BuildContext context;
  _AddressDesign(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get primaryGreen => const Color(0xFF00C853);
  Color get surface => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1E293B);
  Color get textSecondary => isDark ? Colors.white70 : const Color(0xFF64748B);
  Color get cardBg => isDark ? const Color(0xFF16151A) : Colors.white;
  Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  LinearGradient get headerGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16151A), Color(0xFF0D0C10)],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C853), Color(0xFF00E676), Color(0xFF69F0AE)],
        );

  BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withAlpha(isDark ? 100 : 15),
        blurRadius: 16,
        offset: const Offset(0, 4),
      );

  BoxShadow get softShadow => BoxShadow(
        color: primaryGreen.withOpacity(isDark ? 0.05 : 0.15),
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
  double? _latitude;
  double? _longitude;
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

    // Parse coordinates if they exist
    if (widget.address['coordinates'] != null &&
        widget.address['coordinates']['coordinates'] is List) {
      final coords = widget.address['coordinates']['coordinates'] as List;
      if (coords.length >= 2) {
        _longitude = (coords[0] as num).toDouble();
        _latitude = (coords[1] as num).toDouble();
      }
    }
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      CustomPopup.error(context, l10n.pinLocationFirst);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          CustomPopup.error(context, l10n.errLoadUserId);
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
          if (_latitude != null && _longitude != null)
            'coordinates': [_longitude, _latitude],
          'isDefault': _isDefault,
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['message'] != null) {
          HapticFeedback.heavyImpact();
          _showSuccessDialog();
        } else {
          CustomPopup.error(context, l10n.errUpdateAddress);
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
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: design.cardBg,
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
                    gradient: design.headerGradient,
                    shape: BoxShape.circle,
                    boxShadow: [design.softShadow],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.addressUpdated,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addressUpdatedDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: design.textSecondary),
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
                    backgroundColor: design.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.done,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: design.cardBg,
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
                Text(
                  l10n.discardChangesTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: design.textPrimary,
                  ),
                ),
              ],
            ),
            content: Text(
              l10n.discardChangesDesc,
              style: TextStyle(
                fontSize: 15,
                color: design.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.keepEditing,
                  style: TextStyle(color: design.textSecondary),
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
                child: Text(l10n.discard),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final design = _AddressDesign(context);
    return Scaffold(
      backgroundColor: design.surface,
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
                        _buildLocationCard(),
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
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
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
        gradient: design.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [design.softShadow],
      ),
      child: SafeArea(
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
                  Expanded(
                    child: Text(
                      l10n.editAddress,
                      style: const TextStyle(
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
                                : _getLocalAddressType(context, _selectedType),
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
                                  _getLocalAddressType(context, _selectedType).toUpperCase(),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.modified,
                                        style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;
    final design = _AddressDesign(context);
    return _buildCard(
      title: l10n.addressType,
      icon: Icons.category_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                l10n.addressTypeHome,
                'home',
                Icons.home_rounded,
                design.primaryGreen,
                [const Color(0xFF00C853), const Color(0xFF00E676)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                l10n.addressTypeWork,
                'work',
                Icons.work_rounded,
                Colors.blue,
                [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(
                l10n.addressTypeOther,
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

  Widget _buildLocationCard() {
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.mapLocation,
      icon: Icons.map_outlined,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _latitude == null
                      ? Colors.red.withOpacity(0.1)
                      : design.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pin_drop_outlined,
              color:
                  _latitude == null ? Colors.red : design.primaryGreen,
            ),
          ),
          title: Text(
            _latitude == null ? l10n.locationNotSelected : l10n.locationSelected,
            style: TextStyle(fontWeight: FontWeight.w600, color: design.textPrimary),
          ),
          subtitle: Text(
            _latitude == null
                ? l10n.requiredForTracking
                : 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
            style: TextStyle(
              color:
                  _latitude == null
                      ? Colors.red[300]
                      : design.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: TextButton.icon(
            onPressed: () async {
              final LatLng? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => LocationPickerPage(
                        initialLocation:
                            _latitude != null
                                ? LatLng(_latitude!, _longitude!)
                                : null,
                      ),
                ),
              );
              if (result != null && mounted) {
                setState(() {
                  _latitude = result.latitude;
                  _longitude = result.longitude;
                  _hasChanges = true;
                });
              }
            },
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: Text(_latitude == null ? l10n.pick : l10n.change),
            style: TextButton.styleFrom(
              foregroundColor: design.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.addressDetails,
      icon: Icons.location_on_outlined,
      children: [
        _buildTextField(
          controller: _labelController,
          label: l10n.labelOptional,
          hint: l10n.labelHint,
          icon: Icons.label_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _streetController,
          label: l10n.streetAddress,
          hint: l10n.enterStreet,
          icon: Icons.signpost_outlined,
          validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _areaController,
          label: l10n.areaDistrict,
          hint: l10n.enterArea,
          icon: Icons.map_outlined,
          validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cityController,
                label: l10n.city,
                hint: l10n.enterCity,
                icon: Icons.location_city_outlined,
                validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _stateController,
                label: l10n.state,
                hint: l10n.enterState,
                icon: Icons.public_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _zipCodeController,
          label: l10n.zipCode,
          hint: l10n.enterZip,
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildPreferencesCard() {
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return _buildCard(
      title: l10n.preferences,
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
                      ? design.primaryGreen.withOpacity(0.1)
                      : design.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _isDefault
                        ? design.primaryGreen
                        : design.inputBorder,
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
                    gradient: _isDefault ? design.headerGradient : null,
                    color: _isDefault ? null : design.surface,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        _isDefault
                            ? null
                            : Border.all(color: design.inputBorder),
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
                        l10n.setDefaultAddress,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              _isDefault
                                  ? design.primaryGreen
                                  : design.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.setDefaultAddressDesc,
                        style: TextStyle(fontSize: 13, color: design.textSecondary.withOpacity(0.8)),
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
                            ? design.primaryGreen
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _isDefault
                              ? design.primaryGreen
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
    final design = _AddressDesign(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: design.cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [design.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: design.headerGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: design.textPrimary,
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
    final design = _AddressDesign(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 16, color: design.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: design.textSecondary),
        hintStyle: TextStyle(color: design.textSecondary.withOpacity(0.5)),
        prefixIcon: Icon(icon, color: design.primaryGreen),
        filled: true,
        fillColor: design.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: design.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: design.primaryGreen,
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
    final design = _AddressDesign(context);
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
          color: isSelected ? null : design.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : design.inputBorder,
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
                color: isSelected ? Colors.white : design.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    final design = _AddressDesign(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: design.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(design.isDark ? 0.2 : 0.05),
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
                  _hasChanges ? design.primaryGreen : Colors.grey[400],
              foregroundColor: Colors.white,
              disabledBackgroundColor: design.isDark ? Colors.grey[800] : Colors.grey[300],
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
                          _hasChanges ? l10n.saveChanges : l10n.noChanges,
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

  String _getLocalAddressType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type.toLowerCase()) {
      case 'home':
        return l10n.addressTypeHome;
      case 'work':
        return l10n.addressTypeWork;
      default:
        return l10n.addressTypeOther;
    }
  }
}
