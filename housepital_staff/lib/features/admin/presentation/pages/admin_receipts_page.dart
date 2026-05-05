import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';

class AdminReceiptsPage extends StatefulWidget {
  const AdminReceiptsPage({super.key});

  @override
  State<AdminReceiptsPage> createState() => _AdminReceiptsPageState();
}

class _AdminReceiptsPageState extends State<AdminReceiptsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  bool _isLoadingPending = true;
  bool _isLoadingAll = true;
  List<dynamic> _pendingReceipts = [];
  List<dynamic> _allReceipts = [];
  String? _errorPending;
  String? _errorAll;

  // Filter for "All" tab
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index == 0) {
        _fetchPendingReceipts();
      } else {
        _fetchAllReceipts();
      }
    });
    _fetchPendingReceipts();
    _fetchAllReceipts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPendingReceipts() async {
    setState(() {
      _isLoadingPending = true;
      _errorPending = null;
    });
    try {
      final response = await _apiClient.get(ApiConstants.walletPendingReceipts);
      if (mounted) {
        setState(() {
          _pendingReceipts = response['data']?['receipts'] ?? [];
          _isLoadingPending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorPending = e.toString();
          _isLoadingPending = false;
        });
      }
    }
  }

  Future<void> _fetchAllReceipts() async {
    setState(() {
      _isLoadingAll = true;
      _errorAll = null;
    });
    try {
      String path = '${ApiConstants.walletAllReceipts}?limit=50';
      if (_statusFilter != 'all') {
        path += '&status=$_statusFilter';
      }
      final response = await _apiClient.get(path);
      if (mounted) {
        setState(() {
          _allReceipts = response['data']?['receipts'] ?? [];
          _isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAll = e.toString();
          _isLoadingAll = false;
        });
      }
    }
  }

  Future<void> _approveReceipt(String receiptId) async {
    try {
      await _apiClient.put(
        ApiConstants.walletReviewReceipt(receiptId),
        body: {'action': 'approve'},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Receipt approved successfully!'),
            backgroundColor: AppColors.success500,
          ),
        );
        _fetchPendingReceipts();
        _fetchAllReceipts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error500,
          ),
        );
      }
    }
  }

  Future<void> _rejectReceipt(String receiptId, String reason) async {
    try {
      await _apiClient.put(
        ApiConstants.walletReviewReceipt(receiptId),
        body: {'action': 'reject', 'rejectionReason': reason},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Receipt rejected.'),
            backgroundColor: AppColors.warning500,
          ),
        );
        _fetchPendingReceipts();
        _fetchAllReceipts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error500,
          ),
        );
      }
    }
  }

  void _showRejectDialog(String receiptId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.cancel_rounded, color: AppColors.error500),
                SizedBox(width: 10),
                Text('Reject Receipt'),
              ],
            ),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a reason'),
                        backgroundColor: AppColors.warning500,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  _rejectReceipt(receiptId, controller.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showReceiptImage(String url) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder:
                          (ctx, err, st) => const SizedBox(
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Failed to load image'),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Receipt Management',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary500,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary500,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pending'),
                  if (_pendingReceipts.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_pendingReceipts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'All Receipts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPendingTab(), _buildAllTab()],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_isLoadingPending) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary500),
      );
    }
    if (_errorPending != null) {
      return _buildErrorState(_errorPending!, _fetchPendingReceipts);
    }
    if (_pendingReceipts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'All Clear! 🎉',
        subtitle: 'No pending receipts to review.',
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchPendingReceipts,
      color: AppColors.primary500,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingReceipts.length,
        itemBuilder:
            (ctx, i) => _buildReceiptCard(_pendingReceipts[i], isPending: true),
      ),
    );
  }

  Widget _buildAllTab() {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  ['all', 'pending', 'approved', 'rejected']
                      .map(
                        (status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              status == 'all'
                                  ? 'All'
                                  : status[0].toUpperCase() +
                                      status.substring(1),
                            ),
                            selected: _statusFilter == status,
                            selectedColor: AppColors.primary100,
                            labelStyle: TextStyle(
                              color:
                                  _statusFilter == status
                                      ? AppColors.primary500
                                      : Colors.grey[700],
                              fontWeight:
                                  _statusFilter == status
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _statusFilter = status);
                                _fetchAllReceipts();
                              }
                            },
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        Expanded(
          child:
              _isLoadingAll
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary500,
                    ),
                  )
                  : _errorAll != null
                  ? _buildErrorState(_errorAll!, _fetchAllReceipts)
                  : _allReceipts.isEmpty
                  ? _buildEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No Receipts',
                    subtitle: 'No receipts found for this filter.',
                  )
                  : RefreshIndicator(
                    onRefresh: _fetchAllReceipts,
                    color: AppColors.primary500,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _allReceipts.length,
                      itemBuilder:
                          (ctx, i) => _buildReceiptCard(_allReceipts[i]),
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(
    Map<String, dynamic> receipt, {
    bool isPending = false,
  }) {
    final user = receipt['userId'];
    final String userName =
        user is Map ? (user['name'] ?? 'Unknown') : 'Unknown';
    final String userEmail = user is Map ? (user['email'] ?? '') : '';
    final String userRole = user is Map ? (user['role'] ?? '') : '';
    final String? userPicture = user is Map ? user['profilePictureUrl'] : null;

    final double amount = (receipt['amount'] ?? 0).toDouble();
    final String paymentMethod = receipt['paymentMethod'] ?? '';
    final String status = receipt['status'] ?? 'pending';
    final String? receiptUrl = receipt['receiptUrl'];
    final String? rejectionReason = receipt['rejectionReason'];
    final String receiptId = receipt['_id'] ?? '';

    String dateStr = '';
    if (receipt['createdAt'] != null) {
      try {
        final dt = DateTime.parse(receipt['createdAt']);
        dateStr = DateFormat('MMM d, yyyy • HH:mm').format(dt);
      } catch (_) {}
    }

    String reviewDateStr = '';
    if (receipt['reviewedAt'] != null) {
      try {
        final dt = DateTime.parse(receipt['reviewedAt']);
        reviewDateStr = DateFormat('MMM d, yyyy • HH:mm').format(dt);
      } catch (_) {}
    }

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'approved':
        statusColor = AppColors.success500;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = AppColors.error500;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = AppColors.warning500;
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary100,
                  backgroundImage:
                      userPicture != null ? NetworkImage(userPicture) : null,
                  child:
                      userPicture == null
                          ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppColors.primary500,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(userRole).withAlpha(25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              userRole.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _getRoleColor(userRole),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow(
                        Icons.payments_rounded,
                        'Amount',
                        '$amount EGP',
                      ),
                      const SizedBox(height: 6),
                      _detailRow(
                        paymentMethod == 'instapay'
                            ? Icons.account_balance_rounded
                            : Icons.phone_android_rounded,
                        'Method',
                        paymentMethod == 'instapay'
                            ? 'Instapay'
                            : 'Mobile Wallet',
                      ),
                      const SizedBox(height: 6),
                      _detailRow(
                        Icons.access_time_rounded,
                        'Submitted',
                        dateStr,
                      ),
                      if (reviewDateStr.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _detailRow(
                          Icons.verified_rounded,
                          'Reviewed',
                          reviewDateStr,
                        ),
                      ],
                    ],
                  ),
                ),
                // Receipt image thumbnail
                if (receiptUrl != null)
                  GestureDetector(
                    onTap: () => _showReceiptImage(receiptUrl),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          receiptUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder:
                              (ctx, err, st) => const Center(
                                child: Icon(
                                  Icons.receipt_rounded,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Rejection reason
          if (status == 'rejected' && rejectionReason != null) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error500.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error500.withAlpha(30)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.error500,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection: $rejectionReason',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.error500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons for pending
          if (isPending && status == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(receiptId),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error500,
                        side: BorderSide(color: AppColors.error500),
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
                      onPressed:
                          () => _showApproveConfirmation(
                            receiptId,
                            userName,
                            amount,
                          ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'Approve',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success500,
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
            ),
          ],
        ],
      ),
    );
  }

  void _showApproveConfirmation(
    String receiptId,
    String userName,
    double amount,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success500),
                SizedBox(width: 10),
                Text('Confirm Approval'),
              ],
            ),
            content: Text(
              'Are you sure you want to approve this receipt?\n\n'
              'This will credit $amount EGP to $userName\'s wallet.',
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _approveReceipt(receiptId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'nurse':
        return AppColors.primary500;
      case 'doctor':
        return const Color(0xFF6366F1);
      case 'customer':
        return const Color(0xFF10B981);
      case 'admin':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppColors.error500,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
