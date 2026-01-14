import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/token_manager.dart';
import '../../data/models/doctor_model.dart';
import '../cubit/doctor_cubit.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  // Dropdown Values
  String? _selectedSpecialization;
  String? _selectedGender;

  // Constants
  final List<String> _specializations = [
    'General Practice',
    'Pediatrics',
    'Internal Medicine',
    'Cardiology',
    'Dermatology',
    'Orthopedics',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Psychiatry',
    'Neurology',
    'Physiotherapy',
    'Home Nursing',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch existing profile if any
    context.read<DoctorCubit>().fetchProfile();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = await TokenManager.getUserId();

      final doctor = DoctorModel(
        userId: userId ?? '',
        licenseNumber: _licenseController.text,
        specialization: _selectedSpecialization!,
        yearsOfExperience: int.parse(_experienceController.text),
        bio: _bioController.text,
        gender: _selectedGender,
        // Default values for now, will be implemented with upload
        qualifications: [],
      );

      // Check if we are updating or creating
      // For now assume create/update handled by same form logic or check state
      // Simplest is to call create, backend handles duplicate error, or update if exists
      // But let's check state in builder

      final state = context.read<DoctorCubit>().state;
      if (state is DoctorProfileLoaded) {
        context.read<DoctorCubit>().updateProfile(doctor);
      } else {
        context.read<DoctorCubit>().createProfile(doctor);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Profile')),
      body: BlocConsumer<DoctorCubit, DoctorState>(
        listener: (context, state) {
          if (state is DoctorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DoctorProfileLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile Saved Successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Pre-fill form if loaded
            if (_licenseController.text.isEmpty) {
              _licenseController.text = state.profile.licenseNumber;
              _experienceController.text = state.profile.yearsOfExperience
                  .toString();
              _bioController.text = state.profile.bio ?? '';
              setState(() {
                _selectedSpecialization =
                    state.profile.specialization.isNotEmpty
                    ? state.profile.specialization
                    : null;
                // Handle case where spec might not be in list
                if (_selectedSpecialization != null &&
                    !_specializations.contains(_selectedSpecialization)) {
                  _specializations.add(_selectedSpecialization!);
                }
                _selectedGender = state.profile.gender;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complete your professional profile to start receiving bookings.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Specialization
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    items: _specializations.map((spec) {
                      return DropdownMenuItem(value: spec, child: Text(spec));
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedSpecialization = val),
                    validator: (val) =>
                        val == null ? 'Please select a specialization' : null,
                  ),
                  const SizedBox(height: 16),

                  // License Number
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: 'Medical License Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (val.length < 5)
                        return 'Must be at least 5 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Years of Experience
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.history),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      if (int.tryParse(val) == null) return 'Must be a number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val),
                    validator: (val) =>
                        val == null ? 'Please select gender' : null,
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Professional Bio',
                      hintText: 'Tell patients about your expertise...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) =>
                        val != null && val.length > 500 ? 'Too long' : null,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
