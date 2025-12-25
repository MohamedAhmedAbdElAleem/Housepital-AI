import 'package:flutter/material.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'add_dependent_page.dart';
import 'edit_dependent_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({Key? key}) : super(key: key);

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<dynamic> _dependents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDependents();
  }

  Future<void> _fetchDependents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = await TokenManager.getUserId();
      debugPrint('🔍 Family Page: User ID: $userId');

      if (userId == null || userId.isEmpty) {
        debugPrint('❌ Family Page: No user ID found');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load dependents. Please log in again.'),
            ),
          );
        }
        return;
      }

      final apiService = ApiService();
      // Send user ID in the request body using POST
      final response = await apiService.post(
        '/api/user/getAllDependents',
        body: {'id': userId},
      );

      debugPrint('🔍 Family Page: Response: $response');
      debugPrint('🔍 Family Page: Response type: ${response.runtimeType}');

      if (mounted) {
        setState(() {
          _dependents = response is List ? response : [];
          _isLoading = false;
        });
        debugPrint('✅ Family Page: Loaded ${_dependents.length} dependents');
      }
    } catch (e) {
      debugPrint('❌ Family Page: Error loading dependents: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dependents: ${e.toString()}')),
        );
      }
    }
  }

  void _goToAddDependent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDependentPage()),
    );
    if (result == true) {
      _fetchDependents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Family',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF17C47F)),
              )
              : Column(
                children: [
                  // Header Info
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF17C47F), Color(0xFF15B673)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF17C47F).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Family Members',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_dependents.length} member${_dependents.length != 1 ? 's' : ''} registered',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Family Members List
                  Expanded(
                    child:
                        _dependents.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No family members yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first family member',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: _dependents.length,
                              itemBuilder: (context, index) {
                                final dep = _dependents[index];
                                return _buildFamilyMemberCard(dep);
                              },
                            ),
                  ),

                  // Add Member Button
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Material(
                        color: const Color(0xFF17C47F),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _goToAddDependent,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Add Family Member',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFamilyMemberCard(dynamic dep) {
    final String fullName = dep['fullName'] ?? 'Unknown';
    final String relationship = dep['relationship'] ?? 'Unknown';
    final String gender = dep['gender'] ?? 'other';
    final String? dateOfBirth = dep['dateOfBirth'];

    // Calculate age if DOB is available
    String ageText = '';
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      try {
        final dob = DateTime.parse(dateOfBirth);
        final age = DateTime.now().year - dob.year;
        ageText = '$age years old';
      } catch (e) {
        ageText = '';
      }
    }

    // Gender icon and color
    IconData genderIcon;
    Color genderColor;
    if (gender.toLowerCase() == 'male') {
      genderIcon = Icons.male;
      genderColor = const Color(0xFF3B82F6);
    } else if (gender.toLowerCase() == 'female') {
      genderIcon = Icons.female;
      genderColor = const Color(0xFFEC4899);
    } else {
      genderIcon = Icons.person;
      genderColor = const Color(0xFF8B5CF6);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditDependentPage(dependent: dep),
              ),
            );
            if (result == true) {
              _fetchDependents();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: genderColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(genderIcon, color: genderColor, size: 28),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF17C47F).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              relationship,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF17C47F),
                              ),
                            ),
                          ),
                          if (ageText.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              ageText,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
