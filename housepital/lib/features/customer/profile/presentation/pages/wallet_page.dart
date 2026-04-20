import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/api_constants.dart';
import '../../../../../core/utils/token_manager.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  double _balance = 0;
  bool _walletBlocked = false;
  String? _walletBlockReason;
  double _threshold = -150;
  List<dynamic> _transactions = [];
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _loadWalletData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await TokenManager.getToken();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final results = await Future.wait([
        http.get(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.walletBalance}'),
          headers: headers,
        ),
        http.get(
          Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.walletTransactions}?limit=50',
          ),
          headers: headers,
        ),
      ]);

      final balanceResponse = results[0];
      final transactionsResponse = results[1];

      if (balanceResponse.statusCode == 200) {
        final data = jsonDecode(balanceResponse.body)['data'];
        _balance = (data['balance'] ?? 0).toDouble();
        _walletBlocked = data['walletBlocked'] ?? false;
        _walletBlockReason = data['walletBlockReason'];
        _threshold = (data['threshold'] ?? -150).toDouble();
      }

      if (transactionsResponse.statusCode == 200) {
        final data = jsonDecode(transactionsResponse.body)['data'];
        _transactions = data['transactions'] ?? [];
      }

      setState(() => _isLoading = false);
      _animController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load wallet data. Please try again.';
      });
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'booking_payment':
        return Icons.medical_services_rounded;
      case 'commission_deduction':
        return Icons.percent_rounded;
      case 'wallet_recharge':
        return Icons.add_circle_rounded;
      case 'refund':
        return Icons.replay_rounded;
      case 'cancellation_fee':
        return Icons.cancel_rounded;
      case 'no_show_fee':
        return Icons.person_off_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  Color _getTransactionColor(String direction) {
    return direction == 'credit' ? AppColors.success : AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading wallet...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWalletData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _loadWalletData,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildBalanceCard(),
            if (_walletBlocked) ...[
              const SizedBox(height: 16),
              _buildBlockedBanner(),
            ],
            if (!_walletBlocked && _balance < 0 && _balance >= _threshold) ...[
              const SizedBox(height: 16),
              _buildWarningBanner(),
            ],
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildTransactionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              _walletBlocked
                  ? [
                    const Color(0xFF8B1A1A),
                    const Color(0xFFB71C1C),
                    const Color(0xFFC62828),
                  ]
                  : [
                    const Color(0xFF1B5E20),
                    const Color(0xFF2E7D32),
                    const Color(0xFF43A047),
                  ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (_walletBlocked ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _walletBlocked
                      ? Icons.lock_rounded
                      : Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_walletBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'BLOCKED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${_balance >= 0 ? "" : "-"}${_balance.abs().toStringAsFixed(2)} EGP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum allowed: ${_threshold.toStringAsFixed(0)} EGP',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Account Restricted',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _walletBlockReason ??
                'Your wallet balance has exceeded the minimum threshold. You cannot request new services until resolved.',
            style: const TextStyle(
              color: AppColors.error700,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please contact support at housepitalai@gmail.com',
                    ),
                    backgroundColor: AppColors.info500,
                  ),
                );
              },
              icon: const Icon(Icons.support_agent_rounded, size: 18),
              label: const Text('Contact Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning600,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your balance is negative. If it drops below ${_threshold.toStringAsFixed(0)} EGP, your account will be restricted.',
              style: const TextStyle(
                color: AppColors.warning700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.info100),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.info600, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'As a patient, your wallet is used for change and debts from cash payments. Pay the exact amount to your nurse or doctor to maintain a zero balance.',
              style: TextStyle(
                color: AppColors.info700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (_transactions.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: AppColors.light600,
                ),
                SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_transactions.length, (index) {
            final tx = _transactions[index];
            return _buildTransactionTile(tx);
          }),
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    final type = tx['type'] ?? '';
    final direction = tx['direction'] ?? '';
    final amount = (tx['amount'] ?? 0).toDouble();
    final description = tx['description'] ?? type;
    final createdAt = tx['createdAt'] ?? '';
    final status = tx['status'] ?? 'completed';

    String dateStr = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        dateStr =
            '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getTransactionColor(direction).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTransactionIcon(type),
              color: _getTransactionColor(direction),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                    if (status != 'completed') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${direction == 'credit' ? '+' : '-'}${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: _getTransactionColor(direction),
            ),
          ),
        ],
      ),
    );
  }
}
