import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/token_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../cubit/nurse_profile_cubit.dart';
import '../../data/models/nurse_profile_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

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

  final _licenseNumController = TextEditingController();
  final _yearsController = TextEditingController();
  final _bioController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumController = TextEditingController();
  final _accountHolderController = TextEditingController();

  String? _gender;
  String? _selectedSpec;
  List<String> _selectedSkills = [];

  final List<String> _specializations = [
    'العناية المركزة',
    'رعاية المسنين',
    'طب الأطفال',
    'التمريض العام',
    'رعاية ما بعد الجراحة',
    'العناية بالجروح',
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
      _accountHolderController.text = profile.bankAccount?.accountHolderName ?? '';
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_licenseNumController, _yearsController, _bioController, _bankNameController, _accountNumController, _accountHolderController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _onProfileSubmitted() async {
    await TokenManager.saveHasProfile(true);
    await TokenManager.saveVerificationStatus('pending');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile updated successfully!'), backgroundColor: Colors.green));
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.nursePendingApproval, (route) => false);
    }
  }

  Future<void> _pickDocument(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 10),
            Text('Uploading ${type.replaceAll('_', ' ')}...'),
          ]),
          backgroundColor: AppColors.primary500,
          duration: const Duration(milliseconds: 1000),
        ));
        context.read<NurseProfileCubit>().uploadDocument(result.files.single.path!, type);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _submitProfileForm() {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one approved service'), backgroundColor: Colors.red));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.editProfileData, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true, elevation: 0, backgroundColor: Colors.transparent, foregroundColor: theme.colorScheme.onSurface,
      ),
      body: BlocConsumer<NurseProfileCubit, NurseProfileState>(
        listener: (context, state) {
          if (state is NurseProfileLoaded && !_hasPopulated) { _populateFields(state.profile); _hasPopulated = true; }
          else if (state is DocumentUploaded) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Document Uploaded'), backgroundColor: Colors.green)); }
          else if (state is NurseProfileSubmitted) { _onProfileSubmitted(); }
          else if (state is NurseProfileError) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red)); }
        },
        builder: (context, state) {
          bool isLoading = state is NurseProfileLoading || state is NurseProfileUpdating || state is DocumentUploading || state is NurseProfileSubmitted;
          NurseProfile? profile = state is NurseProfileLoaded ? state.profile : (state is NurseProfileUpdated ? state.profile : context.read<NurseProfileCubit>().currentProfile);
          if (state is NurseProfileLoading && profile == null) return const Center(child: CircularProgressIndicator());

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
                  children: [
                    _buildSectionCard(context, 'Personal Info', Icons.person_outline, _buildPersonalInfoForm(context)),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, 'Professional Details', Icons.medical_services_outlined, _buildProfessionalDetailsForm(context)),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, 'Approved Services', Icons.verified_outlined, _buildSkillsForm(context)),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, 'Credentials & Documents', Icons.file_copy_outlined, _buildDocumentsForm(context, profile ?? NurseProfile(), state)),
                    const SizedBox(height: 16),
                    _buildSectionCard(context, 'Payout Information', Icons.account_balance_wallet_outlined, _buildPayoutForm(context)),
                  ],
                ),
              ),
              Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomNavigation(context, isLoading)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, IconData icon, Widget child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary50.withAlpha(isDark ? 30 : 25), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsForm(BuildContext context) {
    return Column(children: [
      DropdownButtonFormField<String>(
        value: _selectedSpec,
        dropdownColor: Theme.of(context).colorScheme.surface,
        decoration: _inputDecoration(context, 'Primary Specialization', Icons.medical_services_outlined),
        items: _specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (val) => setState(() => _selectedSpec = val),
        validator: (v) => v == null ? 'Required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(controller: _licenseNumController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Nursing License ID', Icons.badge_outlined), validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _yearsController, keyboardType: TextInputType.number, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Years of Experience', Icons.history), validator: (v) => v!.isEmpty ? 'Required' : null),
    ]);
  }

  Widget _buildSkillsForm(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select the services you are certified to provide:', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _availableSkills.map((skill) {
        bool isSelected = _selectedSkills.contains(skill);
        return FilterChip(
          label: Text(_translateSkill(skill)),
          selected: isSelected,
          onSelected: (selected) => setState(() => selected ? _selectedSkills.add(skill) : _selectedSkills.remove(skill)),
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
          selectedColor: AppColors.primary500.withAlpha(isDark ? 80 : 50),
          labelStyle: TextStyle(color: isSelected ? AppColors.primary500 : theme.colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.primary500 : Colors.transparent)),
          checkmarkColor: isSelected ? AppColors.primary500 : null,
        );
      }).toList()),
    ]);
  }

  Widget _buildPersonalInfoForm(BuildContext context) {
    return Column(children: [
      DropdownButtonFormField<String>(
        value: _gender,
        dropdownColor: Theme.of(context).colorScheme.surface,
        decoration: _inputDecoration(context, 'Gender', Icons.person_outline),
        items: const [DropdownMenuItem(value: 'male', child: Text('Male')), DropdownMenuItem(value: 'female', child: Text('Female'))],
        onChanged: (val) => setState(() => _gender = val),
        validator: (v) => v == null ? 'Required' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(controller: _bioController, maxLines: 3, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Short Bio (Optional)', Icons.format_quote)),
    ]);
  }

  Widget _buildDocumentsForm(BuildContext context, NurseProfile profile, NurseProfileState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tap to upload clear photos or scans of your documents.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(150), fontSize: 14)),
      const SizedBox(height: 16),
      _buildDocTile(context, 'National ID', profile.nationalIdUrl, () => _pickDocument('national_id'), state is DocumentUploading && state.documentType == 'national_id'),
      _buildDocTile(context, 'Degree Certificate', profile.degreeUrl, () => _pickDocument('degree'), state is DocumentUploading && state.documentType == 'degree'),
      _buildDocTile(context, 'Nursing License', profile.licenseUrl, () => _pickDocument('license'), state is DocumentUploading && state.documentType == 'license'),
    ]);
  }

  Widget _buildPayoutForm(BuildContext context) {
    return Column(children: [
      TextFormField(controller: _bankNameController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Bank Name', Icons.account_balance), validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _accountNumController, keyboardType: TextInputType.number, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Account Number / IBAN', Icons.numbers), validator: (v) => v!.isEmpty ? 'Required' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _accountHolderController, style: TextStyle(color: Theme.of(context).colorScheme.onSurface), decoration: _inputDecoration(context, 'Account Holder Name', Icons.person), validator: (v) => v!.isEmpty ? 'Required' : null),
    ]);
  }

  Widget _buildDocTile(BuildContext context, String label, String? url, VoidCallback onTap, bool uploading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool hasFile = url != null && url.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: hasFile ? Colors.green.withAlpha(100) : theme.colorScheme.outline.withAlpha(50)),
        borderRadius: BorderRadius.circular(12),
        color: hasFile ? Colors.green.withAlpha(isDark ? 40 : 15) : theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 60 : 255),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: hasFile ? Colors.green.withAlpha(isDark ? 60 : 25) : theme.colorScheme.onSurface.withAlpha(20), shape: BoxShape.circle),
          child: Icon(hasFile ? Icons.check : Icons.upload_file_rounded, color: hasFile ? Colors.green : theme.colorScheme.onSurface.withAlpha(100), size: 20),
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
        subtitle: Text(hasFile ? 'Uploaded Successfully' : 'Tap to upload', style: TextStyle(color: hasFile ? Colors.green : theme.colorScheme.onSurface.withAlpha(150), fontSize: 12)),
        trailing: uploading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withAlpha(50)),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary500, size: 20),
      labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
      floatingLabelStyle: const TextStyle(color: AppColors.primary500),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary500, width: 2)),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, bool isLoading) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withAlpha(50))),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(isDark ? 40 : 10), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitProfileForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.editProfileData, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  String _translateSkill(String skill) {
    switch (skill) {
      case 'wound_care': return 'العناية بالجروح';
      case 'iv_insertion': return 'تركيب الكانيولا';
      case 'injections': return 'الحقن';
      case 'blood_draw': return 'سحب الدم';
      case 'elderly_care': return 'رعاية المسنين';
      case 'patient_monitoring': return 'مراقبة المريض';
      case 'physiotherapy_support': return 'دعم العلاج الطبيعي';
      case 'baby_care': return 'رعاية الأطفال';
      case 'emergency_response': return 'الاستجابة للطوارئ';
      default: return skill.replaceAll('_', ' ').toUpperCase();
    }
  }
}
