import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/utils/token_manager.dart';
import '../widgets/medical_record_card.dart';
import '../widgets/medical_record_details_sheet.dart';
import '../widgets/medical_record_header.dart';
import '../widgets/medical_record_shimmer.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  bool _isLoading = true;
  List<dynamic> _records = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicalRecords();
  }

  Future<void> _fetchMedicalRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenManager.getToken();
      final user = await TokenManager.getUserFromToken();
      
      if (user == null || user['id'] == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User session expired. Please login again.';
        });
        return;
      }

      final patientId = user['id'];
      final url = '${ApiConstants.baseUrl}${ApiConstants.visitReports}/$patientId/visit-reports';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _records = data['reports'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _errorMessage = errorData['message'] ?? 'Failed to fetch medical records';
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching records: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Connection error. Please check your internet.';
        });
      }
    }
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => MedicalRecordDetailsSheet(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          MedicalRecordHeader(
            title: 'Medical Records',
            onBack: () => Navigator.pop(context),
            onSearch: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          Expanded(
            child: _isLoading
                ? const MedicalRecordShimmer()
                : RefreshIndicator(
                    onRefresh: _fetchMedicalRecords,
                    color: const Color(0xFF0D9488),
                    child: _errorMessage != null
                        ? _buildErrorState()
                        : _records.isEmpty
                            ? _buildEmptyState()
                            : _buildRecordsList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRecordsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        return MedicalRecordCard(
          record: _records[index],
          onTap: () => _showRecordDetails(_records[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_open_rounded, size: 64, color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Records Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your medical visit reports will appear here automatically after each visit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchMedicalRecords,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
