import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/admin_cubit.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF2664EC);
  static const _bg = Color(0xFFF4F8FF);

  late final TabController _tabController;
  final _rejectionController = TextEditingController();
  int _selectedType = 0; // 0: Doctors, 1: Clinics

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<AdminCubit>().fetchDoctors(status: 'pending');
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _fetchData();
    }
  }

  void _fetchData() {
    final statuses = ['pending', 'approved', 'rejected'];
    final status = statuses[_tabController.index];

    if (_selectedType == 0) {
      context.read<AdminCubit>().fetchDoctors(status: status);
    } else {
      context.read<AdminCubit>().fetchClinics(status: status);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _rejectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh the current tab
            _onTabChanged();
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildTypeSelector(),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _typeButton(0, 'Doctors', Icons.medical_services_rounded),
            _typeButton(1, 'Clinics', Icons.local_hospital_rounded),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(int index, String label, IconData icon) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedType != index) {
            setState(() => _selectedType = index);
            _fetchData();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? _primary : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? _primary : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AdminState state) {
    if (state is AdminLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primary),
      );
    }

    if (state is AdminDoctorsLoaded) {
      if (state.doctors.isEmpty) return _buildEmptyState('No doctors found');
      return _buildDoctorList(state.doctors);
    }

    if (state is AdminClinicsLoaded) {
      if (state.clinics.isEmpty) return _buildEmptyState('No clinics found');
      return _buildClinicList(state.clinics);
    }

    return _buildEmptyState('Loading...');
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no registrations in this category.',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<Map<String, dynamic>> doctors) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doc = doctors[index];
        return _buildDoctorCard(doc);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc) {
    final user = doc['user'] is Map ? doc['user'] as Map : {};
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '--';
    final mobile = user['mobile'] ?? '--';
    final specialization = doc['specialization'] ?? '--';
    final licenseNumber = doc['licenseNumber'] ?? '--';
    final status = doc['verificationStatus'] ?? 'pending';
    final doctorId = doc['_id'] ?? '';
    final rejectionReason = doc['rejectionReason'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: _primary.withAlpha(25),
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Dr. $name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          specialization,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: _buildStatusBadge(status),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _detailRow(Icons.email_outlined, 'Email', email),
          _detailRow(Icons.phone_outlined, 'Mobile', mobile),
          _detailRow(Icons.badge_outlined, 'License', licenseNumber),
          _detailRow(
            Icons.work_history_outlined,
            'Experience',
            '${doc['yearsOfExperience'] ?? '--'} years',
          ),
          // Document links
          const SizedBox(height: 12),
          const Text(
            'Documents',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _docLink('National ID', doc['nationalIdUrl']),
          _docLink('Medical License', doc['licenseUrl']),
          _docLink('Degree Certificate', doc['degreeCertificateUrl']),
          _docLink('Syndicate Card', doc['syndicateCardUrl']),
          if (rejectionReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection: $rejectionReason',
                      style: TextStyle(color: Colors.red[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Action buttons (only for pending)
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(doctorId),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDoctor(doctorId),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _docLink(String label, String? url) {
    final hasDoc = url != null && url.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            hasDoc ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: hasDoc ? Colors.green : Colors.red[300],
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          if (hasDoc)
            GestureDetector(
              onTap: () => _showDocumentPreview(label, url),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 12,
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'approved':
        bg = Colors.green[100]!;
        fg = Colors.green[800]!;
        break;
      case 'rejected':
        bg = Colors.red[100]!;
        fg = Colors.red[800]!;
        break;
      default:
        bg = Colors.orange[100]!;
        fg = Colors.orange[800]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _approveDoctor(String doctorId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Approve Doctor'),
            content: const Text(
              'Are you sure you want to approve this doctor account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AdminCubit>().approveDoctor(doctorId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  void _showRejectDialog(String doctorId) {
    _rejectionController.clear();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Reject Doctor'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 16),
                TextField(
                  controller: _rejectionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g. Document unclear, license expired...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reason = _rejectionController.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rejection reason is required'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  context.read<AdminCubit>().rejectDoctor(doctorId, reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showDocumentPreview(String title, String url) {
    String previewUrl = url;
    bool isPdf = false;
    final lowerUrl = url.toLowerCase();
    
    if (lowerUrl.endsWith('.pdf') || lowerUrl.contains('.pdf?')) {
      isPdf = true;
      final pdfIndex = previewUrl.lastIndexOf('.pdf');
      if (pdfIndex != -1) {
        previewUrl = '${previewUrl.substring(0, pdfIndex)}.jpg${previewUrl.substring(pdfIndex + 4)}';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: Text(title, style: const TextStyle(color: Colors.white)),
              actions: [
                if (isPdf)
                  IconButton(
                    icon: const Icon(Icons.open_in_browser, color: Colors.blueAccent),
                    tooltip: 'Open PDF',
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
              elevation: 0,
            ),
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    previewUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loading) {
                      if (loading == null) return child;
                      return const CircularProgressIndicator(color: Colors.white);
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.white54),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Pinch to zoom • Drag to pan${isPdf ? '\nTap browser icon above to open full PDF' : ''}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicList(List<Map<String, dynamic>> clinics) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clinics.length,
      itemBuilder: (context, index) {
        final clinic = clinics[index];
        return _buildClinicCard(clinic);
      },
    );
  }

  Widget _buildClinicCard(Map<String, dynamic> clinic) {
    final name = clinic['name'] ?? 'Unknown Clinic';
    final doctor = clinic['doctor'] is Map ? clinic['doctor'] as Map : {};
    final doctorUser = doctor['user'] is Map ? doctor['user'] as Map : {};
    final doctorName = doctorUser['name'] ?? 'Unknown Doctor';
    final status = clinic['verificationStatus'] ?? 'pending';
    final clinicId = clinic['_id'] ?? '';
    final address = clinic['address'] is Map ? clinic['address'] as Map : {};
    final fullAddress = '${address['street'] ?? ''}, ${address['area'] ?? ''}, ${address['city'] ?? ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withAlpha(25),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.orange),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Dr. $doctorName',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: _buildStatusBadge(status),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _detailRow(Icons.location_on_outlined, 'Address', fullAddress),
          _detailRow(Icons.phone_outlined, 'Phone', clinic['phone'] ?? doctorUser['mobile'] ?? '--'),
          _detailRow(Icons.access_time_outlined, 'Mode', clinic['bookingMode'] ?? 'slots'),
          
          const SizedBox(height: 12),
          const Text(
            'Verification Documents',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...?((clinic['verificationDocuments'] as List?)?.asMap().entries.map((entry) {
            return _docLink('Document ${entry.key + 1}', entry.value);
          })),
          if (clinic['verificationDocuments'] == null || (clinic['verificationDocuments'] as List).isEmpty)
             Text('No documents uploaded', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic)),

          if (clinic['rejectionReason'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection: ${clinic['rejectionReason']}',
                      style: TextStyle(color: Colors.red[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectClinicDialog(clinicId),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: _actionButtonStyle(Colors.red, outline: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveClinic(clinicId),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: _actionButtonStyle(Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  ButtonStyle _actionButtonStyle(Color color, {bool outline = false}) {
    return outline 
      ? OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        )
      : ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
  }

  void _approveClinic(String clinicId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Approve Clinic'),
        content: const Text('Are you sure you want to approve this clinic?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().approveClinic(clinicId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectClinicDialog(String clinicId) {
    _rejectionController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Clinic'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Incomplete address, invalid documentation...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final reason = _rejectionController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason required'), backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(ctx);
              context.read<AdminCubit>().rejectClinic(clinicId, reason);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
