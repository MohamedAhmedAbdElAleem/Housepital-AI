import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/doctor_cubit.dart';
import '../../data/models/doctor_model.dart';

class BookingSettingsPage extends StatefulWidget {
  const BookingSettingsPage({super.key});

  @override
  State<BookingSettingsPage> createState() => _BookingSettingsPageState();
}

class _BookingSettingsPageState extends State<BookingSettingsPage> {
  // Default values
  int _minAdvanceHours = 3;
  bool _rushBookingEnabled = false;
  double _rushBookingPremium = 25.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final state = context.read<DoctorCubit>().state;
    if (state is DoctorProfileLoaded) {
      final doc = state.profile;
      setState(() {
        _minAdvanceHours = doc.minAdvanceBookingHours;
        _rushBookingEnabled = doc.rushBookingEnabled;
        _rushBookingPremium = doc.rushBookingPremiumPercent.toDouble();
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    // Get current profile to preserve other fields
    final cubit = context.read<DoctorCubit>();
    final state = cubit.state;
    
    if (state is DoctorProfileLoaded) {
      final currentDoc = state.profile;
      
      final updatedDoc = DoctorModel(
        id: currentDoc.id,
        userId: currentDoc.userId,
        // Preserve existing fields
        licenseNumber: currentDoc.licenseNumber,
        specialization: currentDoc.specialization,
        yearsOfExperience: currentDoc.yearsOfExperience,
        bio: currentDoc.bio,
        gender: currentDoc.gender,
        qualifications: currentDoc.qualifications,
        profilePictureUrl: currentDoc.profilePictureUrl,
        nationalIdUrl: currentDoc.nationalIdUrl,
        licenseUrl: currentDoc.licenseUrl,
        verificationStatus: currentDoc.verificationStatus,
        rejectionReason: currentDoc.rejectionReason,
        rating: currentDoc.rating,
        totalRatings: currentDoc.totalRatings,
        reliabilityRate: currentDoc.reliabilityRate,
        
        // Update Settings
        bookingMode: currentDoc.bookingMode, // Keep existing mode
        minAdvanceBookingHours: _minAdvanceHours,
        rushBookingEnabled: _rushBookingEnabled,
        rushBookingPremiumPercent: _rushBookingPremium.round(),
      );

      try {
        await cubit.updateProfile(updatedDoc);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save settings: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
      appBar: AppBar(
        title: const Text('Booking Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General Rules'),
            const SizedBox(height: 16),
            _buildCard(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Minimum Advance Booking', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('How much time do you need before an appointment?'),
                  leading: Icon(Icons.timer_outlined, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _minAdvanceHours,
                      isExpanded: true,
                      items: [1, 2, 3, 6, 12, 24, 48].map((hours) {
                        return DropdownMenuItem<int>(
                          value: hours,
                          child: Text('$hours Hours'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _minAdvanceHours = val);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            _buildSectionHeader('Emergency & Rush'),
            const SizedBox(height: 16),
            _buildCard(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Rush Booking', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Allow patients to book last-minute appointments for a higher price.'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50], 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: const Icon(Icons.flash_on, color: Colors.orange),
                  ),
                  value: _rushBookingEnabled,
                  activeColor: Colors.orange,
                  onChanged: (val) => setState(() => _rushBookingEnabled = val),
                ),
                
                if (_rushBookingEnabled) ...[
                  const Divider(height: 32),
                  const Text('Price Increase Percentage', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('+${_rushBookingPremium.round()}%', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)
                      ),
                      Expanded(
                        child: Slider(
                          value: _rushBookingPremium,
                          min: 0,
                          max: 100,
                          divisions: 20,
                          activeColor: Colors.orange,
                          label: '${_rushBookingPremium.round()}%',
                          onChanged: (val) => setState(() => _rushBookingPremium = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Example: A 200 EGP service will cost ${(200 * (1 + _rushBookingPremium/100)).round()} EGP.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
