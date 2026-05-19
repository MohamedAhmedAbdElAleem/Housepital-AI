import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/token_manager.dart';
import '../../data/models/service_model.dart';
import '../cubit/clinic_cubit.dart';
import '../cubit/service_cubit.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';

class ServiceFormPage extends StatefulWidget {
  final ServiceModel? serviceToEdit;

  const ServiceFormPage({super.key, this.serviceToEdit});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  // Colors now from DoctorTheme

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
        SnackBar(content: Text('please_select_at_least_one_clinic'.tr())),
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
                ? 'service_updated_successfully'.tr()
                : 'service_created_successfully'.tr(),
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
      backgroundColor: DoctorTheme.background(context),
      body: Stack(
        children: [

          BackgroundBlobs(
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GlassHeader(
                    title: _isEditing ? 'edit_service'.tr() : 'add_service'.tr(),
                    subtitle: _isEditing ? 'fine_tune_your_existing_offering'.tr() : 'set_pricing_and_assign_clinics'.tr(),
                    onBack: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionCard(
                            title: 'basic_details'.tr(),
                            subtitle: _isEditing
                                ? 'update_your_service_details'.tr()
                                : 'create_a_new_service_for_patients'.tr(),
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                label: 'service_name'.tr(),
                                hint: 'e_g_consultation'.tr(),
                                icon: Icons.medical_services_outlined,
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _priceController,
                                      label: 'price_egp'.tr(),
                                      hint: '0_00'.tr(),
                                      icon: Icons.attach_money_rounded,
                                      isNumber: true,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _durationController,
                                      label: 'duration_min'.tr(),
                                      hint: '30'.tr(),
                                      icon: Icons.timer_outlined,
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              _buildTextField(
                                controller: _descriptionController,
                                label: 'description_optional'.tr(),
                                hint: 'describe_the_service'.tr(),
                                icon: Icons.description_outlined,
                                maxLines: 3,
                                isRequired: false,
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          _buildClinicsSection(),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DoctorTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: DoctorTheme.surface(context),
                                      ),
                                    )
                                  : Icon(Icons.save_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Saving...'
                                    : (_isEditing
                                        ? 'update_service'.tr()
                                        : 'create_service'.tr()),
                                style: TextStyle(
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
         ),
        ],
      ),
    );
  }





  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: DoctorTheme.titleMedium(context)),
          SizedBox(height: 4),
          Text(subtitle, style: DoctorTheme.bodySmall(context)),
          SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildClinicsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: DoctorTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('assign_to_clinics'.tr(), style: DoctorTheme.titleMedium(context)),
          SizedBox(height: 4),
          Text('select_where_this_service_will_be_available'.tr(), style: DoctorTheme.bodySmall(context)),
          SizedBox(height: 12),
          BlocBuilder<ClinicCubit, ClinicState>(
            builder: (context, state) {
              if (state is ClinicLoading) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(color: DoctorTheme.primary),
                  ),
                );
              }

              if (state is! ClinicLoaded || state.clinics.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'no_clinics_found_please_add_a_clinic_first'.tr(),
                    style: TextStyle(color: DoctorTheme.textSecondary(context)),
                  ),
                );
              }

              return Column(
                children: state.clinics.map((clinic) {
                  final clinicId = clinic.id;
                  final isSelected =
                      clinicId != null && _selectedClinicIds.contains(clinicId);

                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
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
                      activeColor: DoctorTheme.primary,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10),
                      title: Text(
                        clinic.name,
                        style: DoctorTheme.titleMedium(context),
                      ),
                      subtitle: Text(
                        clinic.address.area ?? '',
                        style: DoctorTheme.bodySmall(context),
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
                            ? Icon(
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
        prefixIcon: Icon(icon, color: DoctorTheme.primaryDark),
        filled: true,
        fillColor: DoctorTheme.surfaceDim(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DoctorTheme.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DoctorTheme.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DoctorTheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
