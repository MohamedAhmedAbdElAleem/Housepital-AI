import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../../../core/constants/app_colors.dart';

class NurseProfileCompletionPage extends StatefulWidget {
  const NurseProfileCompletionPage({super.key});

  @override
  State<NurseProfileCompletionPage> createState() =>
      _NurseProfileCompletionPageState();
}

class _NurseProfileCompletionPageState
    extends State<NurseProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _licenseNumController = TextEditingController();
  final _yearsController = TextEditingController();
  final _bioController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumController = TextEditingController();
  final _accountHolderController = TextEditingController();

  // State
  String? _gender;
  String? _selectedSpec;
  List<String> _selectedSkills = [];

  // Data
  final List<String> _specializations = [
    'Critical Care',
    'Elderly Care',
    'Pediatrics',
    'General Nursing',
    'Post-Surgery',
    'Wound Care',
  ];

  final List<String> _availableSkills = [
    'wound_care',
    'iv_insertion',
    'injections',
    'blood_draw',
    'elderly_care',
    'patient_monitoring',
    'physiotherapy_support',
    'baby_care',
    'emergency_response',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<NurseProfileCubit>().loadProfile();
  }

  void _populateFields(NurseProfile profile) {
    _licenseNumController.text = profile.licenseNumber ?? '';
    _selectedSpec = profile.specialization;
    if (_selectedSpec != null && !_specializations.contains(_selectedSpec)) {
      _specializations.add(_selectedSpec!);
    }
    _yearsController.text = profile.yearsOfExperience?.toString() ?? '';
    _bioController.text = profile.bio ?? '';
    _gender = profile.gender;
    if (profile.skills.isNotEmpty) {
      _selectedSkills = List.from(profile.skills);
    }

    if (profile.bankAccount != null) {
      _bankNameController.text = profile.bankAccount?.bankName ?? '';
      _accountNumController.text = profile.bankAccount?.accountNumber ?? '';
      _accountHolderController.text =
          profile.bankAccount?.accountHolderName ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _licenseNumController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    _bankNameController.dispose();
    _accountNumController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Uploading ${type.replaceAll('_', ' ')}...'),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: const Duration(milliseconds: 1000),
          ),
        );

        context.read<NurseProfileCubit>().uploadDocument(
          result.files.single.path!,
          type,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Soft blue-grey
      appBar: AppBar(
        title: const Text(
          'Complete Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<NurseProfileCubit, NurseProfileState>(
        listener: (context, state) {
          if (state is NurseProfileLoaded)
            _populateFields(state.profile);
          else if (state is DocumentUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Document Uploaded'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<NurseProfileCubit>().loadProfile();
          } else if (state is NurseProfileSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Submitted!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is NurseProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          bool isLoading =
              state is NurseProfileLoading ||
              state is NurseProfileUpdating ||
              state is DocumentUploading ||
              state is NurseProfileSubmitted;
          NurseProfile? profile;
          if (state is NurseProfileLoaded) profile = state.profile;
          if (state is NurseProfileUpdated) profile = state.profile;
          profile =
              profile ??
              context.read<NurseProfileCubit>().currentProfile ??
              NurseProfile();

          if (profile.id == null && isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Banner Intention
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary500, AppColors.primary400],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary500.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Almost There!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Complete these details to verify your account.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section 1: Professional
                  _buildSectionCard(
                    title: 'Professional Details',
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedSpec,
                        decoration: _inputDecoration(
                          'Primary Specialization',
                          Icons.medical_services_outlined,
                        ),
                        items:
                            _specializations
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => _selectedSpec = val),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licenseNumController,
                        decoration: _inputDecoration(
                          'Nursing License ID',
                          Icons.badge_outlined,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Years of Experience',
                          Icons.history,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),

                  // Section 2: Skills
                  _buildSectionCard(
                    title: 'Approved Services',
                    children: [
                      const Text(
                        'Select services you are certified to perform:',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _availableSkills.map((skill) {
                              bool isSelected = _selectedSkills.contains(skill);
                              return FilterChip(
                                label: Text(
                                  skill.replaceAll('_', ' ').toUpperCase(),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected)
                                      _selectedSkills.add(skill);
                                    else
                                      _selectedSkills.remove(skill);
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: AppColors.primary100,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? AppColors.primary700
                                          : Colors.grey[600],
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  fontSize: 11,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color:
                                        isSelected
                                            ? AppColors.primary500
                                            : Colors.transparent,
                                  ),
                                ),
                                checkmarkColor: AppColors.primary700,
                              );
                            }).toList(),
                      ),
                      if (_selectedSkills.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select at least one skill.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  // Section 3: Personal
                  _buildSectionCard(
                    title: 'Personal Info',
                    children: [
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _inputDecoration(
                          'Gender',
                          Icons.person_outline,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (val) => setState(() => _gender = val),
                        validator: (v) => v == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          'Short Bio',
                          Icons.format_quote,
                        ),
                      ),
                    ],
                  ),

                  // Section 4: Documents
                  _buildSectionCard(
                    title: 'Documents',
                    children: [
                      _buildDocTile(
                        'National ID',
                        profile.nationalIdUrl,
                        () => _pickDocument('national_id'),
                        state is DocumentUploading &&
                            state.documentType == 'national_id',
                      ),
                      _buildDocTile(
                        'Degree Certificate',
                        profile.degreeUrl,
                        () => _pickDocument('degree'),
                        state is DocumentUploading &&
                            state.documentType == 'degree',
                      ),
                      _buildDocTile(
                        'Nursing License',
                        profile.licenseUrl,
                        () => _pickDocument('license'),
                        state is DocumentUploading &&
                            state.documentType == 'license',
                      ),
                    ],
                  ),

                  // Section 5: Payout
                  _buildSectionCard(
                    title: 'Payout Information',
                    children: [
                      TextFormField(
                        controller: _bankNameController,
                        decoration: _inputDecoration(
                          'Bank Name',
                          Icons.account_balance,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _accountNumController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Account Number / IBAN',
                          Icons.numbers,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _accountHolderController,
                        decoration: _inputDecoration(
                          'Account Holder Name',
                          Icons.person,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Submit Area
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      elevation: 5,
                      shadowColor: AppColors.primary200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(
                      isLoading ? 'Processing...' : 'Submit Profile for Review',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : _saveProgress,
                      child: const Text(
                        'Save Draft for Later',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary500),
      labelStyle: TextStyle(color: Colors.grey[600]),
      floatingLabelStyle: const TextStyle(color: AppColors.primary500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  Widget _buildDocTile(
    String label,
    String? url,
    VoidCallback onTap,
    bool uploading,
  ) {
    bool hasFile = url != null && url.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasFile ? AppColors.success200 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasFile ? AppColors.success50.withOpacity(0.5) : Colors.white,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hasFile ? AppColors.success100 : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasFile ? Icons.check : Icons.upload_file_rounded,
            color: hasFile ? AppColors.success600 : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          hasFile ? 'Uploaded Successfully' : 'Tap to upload',
          style: TextStyle(
            color: hasFile ? AppColors.success600 : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing:
            uploading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
      ),
    );
  }

  Future<void> _saveProgress() async {
    final data = {
      'licenseNumber': _licenseNumController.text,
      'specialization': _selectedSpec,
      'yearsOfExperience': int.tryParse(_yearsController.text),
      'bio': _bioController.text,
      'gender': _gender,
      'skills': _selectedSkills,
      'bankAccount': {
        'bankName': _bankNameController.text,
        'accountNumber': _accountNumController.text,
        'accountHolderName': _accountHolderController.text,
      },
    };
    await context.read<NurseProfileCubit>().updateProfile(data);
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate() && _selectedSkills.isNotEmpty) {
      await _saveProgress();
      if (!mounted) return;
      context.read<NurseProfileCubit>().submitForReview();
    } else if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
