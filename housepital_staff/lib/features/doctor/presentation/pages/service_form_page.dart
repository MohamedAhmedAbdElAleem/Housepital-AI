import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/token_manager.dart';
import '../../data/models/service_model.dart';
import '../cubit/clinic_cubit.dart';
import '../cubit/service_cubit.dart';

class ServiceFormPage extends StatefulWidget {
  final ServiceModel? serviceToEdit;

  const ServiceFormPage({super.key, this.serviceToEdit});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  static const Color _bg = Color(0xFFF4F8FF);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primary = Color(0xFF2664EC);
  static const Color _primaryDark = Color(0xFF1136A8);
  static const Color _secondary = Color(0xFF3498BB);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF475569);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _selectedClinicIds = [];
  bool _isLoading = false;

  bool get _isEditing => widget.serviceToEdit != null;

  @override
  void initState() {
    super.initState();
    context.read<ClinicCubit>().fetchClinics();

    if (_isEditing) {
      _populateFields(widget.serviceToEdit!);
    }
  }

  void _populateFields(ServiceModel service) {
    _nameController.text = service.name;
    _priceController.text = service.price.toString();
    _durationController.text = service.durationMinutes.toString();
    _descriptionController.text = service.description ?? '';
    _selectedClinicIds
      ..clear()
      ..addAll(service.clinics);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClinicIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one clinic')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final serviceCubit = context.read<ServiceCubit>();

    final userId = await TokenManager.getUserId();

    final newService = ServiceModel(
      id: widget.serviceToEdit?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      type: widget.serviceToEdit?.type ?? 'clinic',
      price: double.parse(_priceController.text),
      durationMinutes: int.parse(_durationController.text),
      clinics: _selectedClinicIds,
      category: 'General',
      providerId: userId ?? '',
      providerModel: 'Doctor',
      isActive: widget.serviceToEdit?.isActive ?? true,
    );

    try {
      if (_isEditing) {
        await serviceCubit.updateService(newService);
      } else {
        await serviceCubit.addService(newService);
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Service updated successfully'
                : 'Service created successfully',
          ),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (_) {
      // Error feedback is handled by listener in MyServicesPage.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _buildBackgroundBlob(
              size: 280,
              colors: const [Color(0x2A2664EC), Color(0x003498BB)],
            ),
          ),
          Positioned(
            top: 220,
            left: -100,
            child: _buildBackgroundBlob(
              size: 240,
              colors: const [Color(0x1A1136A8), Color(0x002664EC)],
            ),
          ),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionCard(
                            title: 'Basic Details',
                            subtitle: _isEditing
                                ? 'Update your service details'
                                : 'Create a new service for patients',
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'Service Name',
                                hint: 'e.g. Consultation',
                                icon: Icons.medical_services_outlined,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _priceController,
                                      label: 'Price (EGP)',
                                      hint: '0.00',
                                      icon: Icons.attach_money_rounded,
                                      isNumber: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _durationController,
                                      label: 'Duration (Min)',
                                      hint: '30',
                                      icon: Icons.timer_outlined,
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'Description (Optional)',
                                hint: 'Describe the service...',
                                icon: Icons.description_outlined,
                                maxLines: 3,
                                isRequired: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildClinicsSection(),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Saving...'
                                    : (_isEditing
                                        ? 'Update Service'
                                        : 'Create Service'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlob(
      {required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryDark, _primary, _secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _primaryDark.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                fixedSize: const Size(40, 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Service' : 'Add Service',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isEditing
                        ? 'Fine-tune your existing offering'
                        : 'Set pricing and assign clinics',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildClinicsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assign to Clinics',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select where this service will be available',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12.8,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<ClinicCubit, ClinicState>(
            builder: (context, state) {
              if (state is ClinicLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: _primary),
                  ),
                );
              }

              if (state is! ClinicLoaded || state.clinics.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No clinics found. Please add a clinic first.',
                    style: TextStyle(color: _textSecondary),
                  ),
                );
              }

              return Column(
                children: state.clinics.map((clinic) {
                  final clinicId = clinic.id;
                  final isSelected =
                      clinicId != null && _selectedClinicIds.contains(clinicId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      activeColor: _primary,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      title: Text(
                        clinic.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        clinic.address.area ?? '',
                        style: const TextStyle(color: _textSecondary),
                      ),
                      secondary: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                          image: clinic.images.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(clinic.images.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: clinic.images.isEmpty
                            ? const Icon(
                                Icons.location_city_rounded,
                                color: Color(0xFF2563EB),
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          if (clinicId == null) {
                            return;
                          }

                          if (value == true) {
                            _selectedClinicIds.add(clinicId);
                          } else {
                            _selectedClinicIds.remove(clinicId);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryDark),
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E5FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8E5FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.4),
        ),
      ),
    );
  }
}
