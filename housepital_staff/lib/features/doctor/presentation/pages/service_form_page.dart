import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/service_cubit.dart';
import '../cubit/doctor_cubit.dart';
import '../../data/models/service_model.dart';
import '../../data/models/clinic_model.dart';
import '../../../../core/utils/token_manager.dart';

class ServiceFormPage extends StatefulWidget {
  final ServiceModel? serviceToEdit;

  const ServiceFormPage({super.key, this.serviceToEdit});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _selectedClinicIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch clinics to allow assignment
    context.read<DoctorCubit>().fetchClinics();

    if (widget.serviceToEdit != null) {
      _populateFields(widget.serviceToEdit!);
    }
  }

  void _populateFields(ServiceModel service) {
    _nameController.text = service.name;
    _priceController.text = service.price.toString();
    _durationController.text = service.durationMinutes.toString();
    _descriptionController.text = service.description ?? '';
    _selectedClinicIds.addAll(service.clinics);
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinicIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one clinic')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userId = await TokenManager.getUserId();
    // In a real app we might get doctor ID from profile, but backend handles it via req.user
    // We just need to construct the object.

    final newService = ServiceModel(
      id: widget.serviceToEdit?.id,
      name: _nameController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      price: double.parse(_priceController.text),
      durationMinutes: int.parse(_durationController.text),
      clinics: _selectedClinicIds,
      category: 'General', // Could be a dropdown
      providerId: userId ?? '', // Backend will override this usually
      providerModel: 'Doctor',
      isActive: widget.serviceToEdit?.isActive ?? true,
    );

    try {
      if (widget.serviceToEdit != null) {
        await context.read<ServiceCubit>().updateService(newService);
      } else {
        await context.read<ServiceCubit>().addService(newService);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Error handled by listener in parent page usually, or we can listen here if we used BlocListener
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.serviceToEdit != null ? 'Edit Service' : 'Add Service',
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                label: 'Service Name',
                hint: 'e.g. Consultation',
                icon: Icons.medical_services,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _priceController,
                      label: 'Price (EGP)',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _durationController,
                      label: 'Duration (Min)',
                      hint: '30',
                      icon: Icons.timer,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Describe the service...',
                icon: Icons.description,
                maxLines: 3,
                isRequired: false,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Assign to Clinics'),
              const SizedBox(height: 8),
              BlocBuilder<DoctorCubit, DoctorState>(
                builder: (context, state) {
                  if (state is DoctorLoading &&
                      (state is! DoctorClinicsLoaded)) {
                    // Simple check
                    // Warning: if strictly Loading, we might not have clinics yet.
                    // But DoctorCubit could be in loaded state from previous calls.
                    // Let's rely on standard BlocBuilder behavior.
                    // Ideally we check if state has clinics.
                  }

                  // We need to access the clinics list.
                  // If we are in Loaded state or ClinicsLoaded state.
                  List<ClinicModel> clinics = [];
                  if (state is DoctorClinicsLoaded) {
                    clinics = state.clinics;
                  }

                  if (clinics.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No clinics found. Please add a clinic first.",
                      ),
                    );
                  }

                  return Column(
                    children: clinics.map((clinic) {
                      final isSelected = _selectedClinicIds.contains(clinic.id);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(clinic.name),
                        subtitle: Text(clinic.address.area ?? ''),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            image: (clinic.images.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(clinic.images.first),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: clinic.images.isEmpty
                              ? const Icon(
                                  Icons.location_city,
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                        activeColor: const Color(0xFF1565C0),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (clinic.id != null)
                                _selectedClinicIds.add(clinic.id!);
                            } else {
                              _selectedClinicIds.remove(clinic.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.serviceToEdit != null
                              ? 'Update Service'
                              : 'Create Service',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3436),
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
          ? (val) => (val == null || val.isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
