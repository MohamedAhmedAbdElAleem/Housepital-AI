import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/network/api_constants.dart';
import '../../../../../core/utils/token_manager.dart';
import '../widgets/recharge_sheet.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_shimmer.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool _isLoading = true;
  double _balance = 0;
  bool _walletBlocked = false;
  String? _walletBlockReason;
  double _threshold = -150;
  List<dynamic> _transactions = [];
  List<dynamic> _receipts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final headers = await _authHeaders();
      final results = await Future.wait([
        http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletBalance}'), headers: headers),
        http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletTransactions}?limit=50'), headers: headers),
        http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletMyReceipts}'), headers: headers),
      ]);

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body)['data'];
        _balance = (data['balance'] ?? 0).toDouble();
        _walletBlocked = data['walletBlocked'] ?? false;
        _walletBlockReason = data['walletBlockReason'];
        _threshold = (data['threshold'] ?? -150).toDouble();
      }
      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body)['data'];
        _transactions = data['transactions'] ?? [];
      }
      if (results[2].statusCode == 200) {
        final data = jsonDecode(results[2].body)['data'];
        _receipts = data['receipts'] ?? [];
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load wallet data. Pull to refresh.';
      });
    }
  }

  void _showRechargeSheet() async {
    HapticFeedback.mediumImpact();
    final headers = await _authHeaders();
    try {
      final resp = await http.get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletPaymentInfo}'), headers: headers);
      if (!mounted) return;
      
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load payment info')));
        return;
      }

      final data = jsonDecode(resp.body)['data'];
      final methods = data['methods'] as List<dynamic>? ?? [];

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => RechargeSheet(
          methods: methods,
          baseUrl: ApiConstants.baseUrl,
          authHeaders: headers,
          onSuccess: _loadWalletData,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const WalletShimmer();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        color: const Color(0xFF1E3A8A),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              title: const Text(
                'My Wallet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1E3A8A), // Deep Blue for high contrast
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              centerTitle: true,
              floating: true,
              pinned: true,
              iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)), // Contrast for back button
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    WalletBalanceCard(
                      balance: _balance,
                      threshold: _threshold,
                      isBlocked: _walletBlocked,
                    ),
                    const SizedBox(height: 32),
                    _buildMainButton(),
                    if (_walletBlocked || (_balance < 0)) ...[
                      const SizedBox(height: 16),
                      _buildAlertBanner(),
                    ],
                  ],
                ),
              ),
            ),
            
            if (_receipts.isNotEmpty) ...[
              _buildSectionHeader('Processing Requests'),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReceiptCard(_receipts[index]),
                    childCount: _receipts.length,
                  ),
                ),
              ),
            ],

            _buildSectionHeader('Transactions'),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: _transactions.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => TransactionTile(tx: _transactions[index]),
                        childCount: _transactions.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showRechargeSheet,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(
          _walletBlocked ? 'Recharge to Unblock' : 'Add Funds',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _walletBlocked ? Colors.red : const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    final bool isCritical = _walletBlocked;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isCritical ? Colors.red : Colors.orange).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(isCritical ? Icons.error_outline : Icons.info_outline, color: isCritical ? Colors.red : Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCritical 
                ? (_walletBlockReason ?? 'Wallet restricted due to negative balance.')
                : 'Your balance is low. Please recharge to avoid restriction.',
              style: TextStyle(
                fontSize: 13, 
                color: isCritical ? Colors.red[900] : Colors.orange[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(dynamic r) {
    final status = r['status'] ?? 'pending';
    final amount = r['amount'] ?? 0;
    final isRejected = status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$amount EGP Top-up', style: const TextStyle(fontWeight: FontWeight.bold)),
              _buildStatusBadge(status),
            ],
          ),
          if (isRejected && r['rejectionReason'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${r['rejectionReason']}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'approved') color = Colors.green;
    if (status == 'rejected') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No transactions yet', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
