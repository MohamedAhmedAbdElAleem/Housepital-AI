import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
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
  bool _hasPopulated = false;

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

  Future<void> _onProfileSubmitted() async {
    await TokenManager.saveHasProfile(true);
    await TokenManager.saveVerificationStatus('pending');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Profile updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // If they were already approved, just pop back to their profile view.
    // If they were incomplete, send them to pending approval.
    // Assuming if they are here from settings, they probably have a profile, we can pop.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.nursePendingApproval,
        (route) => false,
      );
    }
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _submitProfileForm() {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one approved service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
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
      context.read<NurseProfileCubit>().submitProfile(data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Edit Profile Data',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<NurseProfileCubit, NurseProfileState>(
        listener: (context, state) {
          if (state is NurseProfileLoaded && !_hasPopulated) {
            _populateFields(state.profile);
            _hasPopulated = true;
          } else if (state is DocumentUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Document Uploaded'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NurseProfileSubmitted) {
            _onProfileSubmitted();
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
          bool isLoading = state is NurseProfileLoading ||
              state is NurseProfileUpdating ||
              state is DocumentUploading ||
              state is NurseProfileSubmitted;
          
          NurseProfile? profile;
          if (state is NurseProfileLoaded) profile = state.profile;
          if (state is NurseProfileUpdated) profile = state.profile;
          profile = profile ??
              context.read<NurseProfileCubit>().currentProfile ??
              NurseProfile();

          if (state is NurseProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                  children: [
                    _buildSectionCard(
                      'Personal Info',
                      Icons.person_outline,
                      _buildPersonalInfoForm(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Professional Details',
                      Icons.medical_services_outlined,
                      _buildProfessionalDetailsForm(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Approved Services',
                      Icons.verified_outlined,
                      _buildSkillsForm(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Credentials & Documents',
                      Icons.file_copy_outlined,
                      _buildDocumentsForm(profile, state),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      'Payout Information',
                      Icons.account_balance_wallet_outlined,
                      _buildPayoutForm(),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNavigation(isLoading),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                  color: AppColors.primary50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary500, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedSpec,
          decoration: _inputDecoration(
            'Primary Specialization',
            Icons.medical_services_outlined,
          ),
          items: _specializations
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
    );
  }

  Widget _buildSkillsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the services you are certified to provide:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSkills.map((skill) {
            bool isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(
                skill.replaceAll('_', ' ').toUpperCase(),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
              },
              backgroundColor: Colors.grey[100],
              selectedColor: AppColors.primary100,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary700 : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary500 : Colors.transparent,
                ),
              ),
              checkmarkColor: AppColors.primary700,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoForm() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _gender,
          decoration: _inputDecoration(
            'Gender',
            Icons.person_outline,
          ),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
          ],
          onChanged: (val) => setState(() => _gender = val),
          validator: (v) => v == null ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: _inputDecoration(
            'Short Bio (Optional)',
            Icons.format_quote,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsForm(NurseProfile profile, NurseProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tap to upload clear photos or scans of your documents.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildDocTile(
          'National ID',
          profile.nationalIdUrl,
          () => _pickDocument('national_id'),
          state is DocumentUploading && state.documentType == 'national_id',
        ),
        _buildDocTile(
          'Degree Certificate',
          profile.degreeUrl,
          () => _pickDocument('degree'),
          state is DocumentUploading && state.documentType == 'degree',
        ),
        _buildDocTile(
          'Nursing License',
          profile.licenseUrl,
          () => _pickDocument('license'),
          state is DocumentUploading && state.documentType == 'license',
        ),
      ],
    );
  }

  Widget _buildPayoutForm() {
    return Column(
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
        trailing: uploading
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
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary500, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _buildBottomNavigation(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitProfileForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
