import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import '../../../profile/presentation/pages/saved_addresses_page.dart';

class LocationHeader extends StatefulWidget {
  const LocationHeader({super.key});

  @override
  State<LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<LocationHeader> {
  String _locationText = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrimaryAddress();
  }

  Future<void> _loadPrimaryAddress() async {
    try {
      final userId = await TokenManager.getUserId();
      if (userId == null || userId.isEmpty) {
        setState(() {
          _locationText = 'Select Location';
          _isLoading = false;
        });
        return;
      }

      final apiService = ApiService();
      final response = await apiService.get('/api/user/addresses/$userId');

      if (mounted) {
        final addresses = response is List ? response : (response['addresses'] ?? []);
        
        // Find primary address or use first one
        final primaryAddress = addresses.firstWhere(
          (addr) => addr['isPrimary'] == true,
          orElse: () => addresses.isNotEmpty ? addresses[0] : null,
        );

        setState(() {
          if (primaryAddress != null) {
            // Format: "Area, City" or just "City"
            final area = primaryAddress['area']?.toString() ?? '';
            final city = primaryAddress['city']?.toString() ?? '';
            
            if (area.isNotEmpty && city.isNotEmpty) {
              _locationText = '$area, $city';
            } else if (city.isNotEmpty) {
              _locationText = city;
            } else {
              _locationText = 'Select Location';
            }
          } else {
            _locationText = 'Add Address';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading location: $e');
      if (mounted) {
        setState(() {
          _locationText = 'Select Location';
          _isLoading = false;
        });
      }
    }
  }

  void _openAddresses() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedAddressesPage(),
      ),
    );
    
    // Reload location if addresses were changed
    if (result == true || result == null) {
      _loadPrimaryAddress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _openAddresses,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLoading ? 'Loading...' : _locationText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 22,
          ),
        ),
      ],
    );
  }
}
