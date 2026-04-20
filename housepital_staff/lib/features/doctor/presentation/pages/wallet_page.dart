import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/paymob_webview_page.dart';
import '../cubit/wallet_cubit.dart';

class DoctorWalletPage extends StatefulWidget {
  const DoctorWalletPage({super.key});

  @override
  State<DoctorWalletPage> createState() => _DoctorWalletPageState();
}

class _DoctorWalletPageState extends State<DoctorWalletPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final _rechargeAmountController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedPaymentMethod = 'card';

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
    context.read<DoctorWalletCubit>().loadWallet();
  }

  @override
  void dispose() {
    _animController.dispose();
    _rechargeAmountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showRechargeDialog() {
    _rechargeAmountController.clear();
    _phoneController.clear();
    _selectedPaymentMethod = 'card';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.light500, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Recharge Wallet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Choose your payment method and amount.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),

                // ── Payment Method Selector ──
                const Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _PaymentMethodCard(
                        icon: Icons.credit_card_rounded,
                        label: 'Visa / Card',
                        isSelected: _selectedPaymentMethod == 'card',
                        onTap: () => setSheetState(() => _selectedPaymentMethod = 'card'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PaymentMethodCard(
                        icon: Icons.phone_android_rounded,
                        label: 'Mobile Wallet',
                        isSelected: _selectedPaymentMethod == 'wallet',
                        onTap: () => setSheetState(() => _selectedPaymentMethod = 'wallet'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Quick Amount Buttons ──
                Row(
                  children: [50, 100, 200, 500].map((amount) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: OutlinedButton(
                          onPressed: () => setSheetState(() => _rechargeAmountController.text = amount.toString()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text('$amount', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Amount Field ──
                TextField(
                  controller: _rechargeAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (EGP)',
                    hintText: 'Min 10, Max 10,000',
                    prefixIcon: const Icon(Icons.payments_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.light500)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                  ),
                ),

                // ── Phone Number (for wallet only) ──
                if (_selectedPaymentMethod == 'wallet') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 11,
                    decoration: InputDecoration(
                      labelText: 'Wallet Phone Number',
                      hintText: '01xxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone_rounded),
                      helperText: 'Vodafone Cash / Etisalat Cash / Orange Cash',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.light500)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final amount = double.tryParse(_rechargeAmountController.text);
                      if (amount == null || amount < 10 || amount > 10000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid amount (10 - 10,000 EGP)'), backgroundColor: AppColors.warning),
                        );
                        return;
                      }
                      if (_selectedPaymentMethod == 'wallet') {
                        final phone = _phoneController.text.trim();
                        final phoneRegex = RegExp(r'^01[0125][0-9]{8}$');
                        if (!phoneRegex.hasMatch(phone)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid Egyptian mobile number'), backgroundColor: AppColors.warning),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        context.read<DoctorWalletCubit>().initiateWalletRecharge(amount, phone);
                      } else {
                        Navigator.pop(ctx);
                        context.read<DoctorWalletCubit>().initiateCardRecharge(amount);
                      }
                    },
                    icon: Icon(_selectedPaymentMethod == 'wallet' ? Icons.phone_android_rounded : Icons.payment_rounded),
                    label: Text(
                      _selectedPaymentMethod == 'wallet' ? 'Pay with Mobile Wallet' : 'Pay with Card',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Wallet', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<DoctorWalletCubit>().loadWallet(),
          ),
        ],
      ),
      body: BlocConsumer<DoctorWalletCubit, DoctorWalletState>(
        listener: (context, state) {
          if (state is DoctorWalletLoaded) _animController.forward(from: 0);

          if (state is DoctorWalletRechargeCard) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PaymobWebViewPage(iframeUrl: state.iframeUrl, amount: state.amount)),
            ).then((success) {
              if (success == true) {
                context.read<DoctorWalletCubit>().refreshAfterRecharge();
              } else {
                context.read<DoctorWalletCubit>().loadWallet();
              }
            });
          }

          if (state is DoctorWalletRechargeWallet) {
            _openWalletRedirect(state.redirectUrl, state.amount);
          }

          if (state is DoctorWalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
            context.read<DoctorWalletCubit>().loadWallet();
          }
        },
        builder: (context, state) {
          if (state is DoctorWalletLoading || state is DoctorWalletInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is DoctorWalletLoaded) return _buildContent(state);
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Future<void> _openWalletRedirect(String url, double amount) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (!mounted) return;
        final success = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PaymobWebViewPage(iframeUrl: url, amount: amount)),
        );
        if (success == true) {
          if (!mounted) return;
          context.read<DoctorWalletCubit>().refreshAfterRecharge();
        } else {
          if (!mounted) return;
          context.read<DoctorWalletCubit>().loadWallet();
        }
      } else {
        if (!mounted) return;
        _showWalletReturnDialog();
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymobWebViewPage(iframeUrl: url, amount: amount)),
      ).then((success) {
        if (success == true) {
          context.read<DoctorWalletCubit>().refreshAfterRecharge();
        } else {
          context.read<DoctorWalletCubit>().loadWallet();
        }
      });
    }
  }

  void _showWalletReturnDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Payment Completed?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'If you completed the payment in your wallet app, tap "Done" to refresh your balance.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DoctorWalletCubit>().loadWallet();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DoctorWalletCubit>().refreshAfterRecharge();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(DoctorWalletLoaded state) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: () => context.read<DoctorWalletCubit>().loadWallet(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildBalanceCard(state),
            if (state.walletBlocked) ...[const SizedBox(height: 16), _buildBlockedBanner(state)],
            if (!state.walletBlocked && state.balance < 0 && state.balance >= state.threshold) ...[
              const SizedBox(height: 16), _buildWarningBanner(state),
            ],
            const SizedBox(height: 16),
            _buildRechargeButton(state),
            const SizedBox(height: 16),
            _buildCommissionInfoCard(state),
            const SizedBox(height: 24),
            _buildTransactionsSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(DoctorWalletLoaded state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: state.walletBlocked
              ? [const Color(0xFF8B1A1A), const Color(0xFFB71C1C), const Color(0xFFC62828)]
              : [const Color(0xFF1746C0), const Color(0xFF1E56D8), const Color(0xFF2664EC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (state.walletBlocked ? AppColors.error : AppColors.primary).withValues(alpha: 0.35),
            blurRadius: 20, offset: const Offset(0, 8),
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
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(state.walletBlocked ? Icons.lock_rounded : Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Doctor Wallet', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
              const Spacer(),
              if (state.walletBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('BLOCKED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${state.balance >= 0 ? "" : "-"}${state.balance.abs().toStringAsFixed(2)} EGP',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          const SizedBox(height: 8),
          Text(
            'Min: ${state.threshold.toStringAsFixed(0)} EGP • Commission: ${(state.commissionRate * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner(DoctorWalletLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.error50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
              SizedBox(width: 8),
              Text('Account Restricted', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.walletBlockReason ?? 'Your wallet balance has exceeded the minimum threshold. You cannot toggle availability.',
            style: const TextStyle(color: AppColors.error700, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text('Recharge your wallet to unblock your account.', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(DoctorWalletLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.warning50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.warning200)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your balance is negative. If it drops below ${state.threshold.toStringAsFixed(0)} EGP, you will not be able to toggle availability.',
              style: const TextStyle(color: AppColors.warning700, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeButton(DoctorWalletLoaded state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showRechargeDialog,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
        label: Text(
          state.walletBlocked ? 'Recharge to Unblock Account' : 'Recharge Wallet',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.walletBlocked ? AppColors.error : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildCommissionInfoCard(DoctorWalletLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.info50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.info100)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'A ${(state.commissionRate * 100).toStringAsFixed(0)}% platform commission is deducted from your wallet for each completed clinic appointment. You collect the full payment from patients.',
              style: const TextStyle(color: AppColors.info700, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(DoctorWalletLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaction History (${state.totalTransactions})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        if (state.transactions.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.light600),
                SizedBox(height: 12),
                Text('No transactions yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          )
        else
          ...state.transactions.map((tx) => _buildTransactionTile(tx)),
      ],
    );
  }

  Widget _buildTransactionTile(dynamic tx) {
    final type = tx['type'] ?? '';
    final direction = tx['direction'] ?? '';
    final amount = (tx['amount'] ?? 0).toDouble();
    final description = tx['description'] ?? type;
    final createdAt = tx['createdAt'] ?? '';
    final status = tx['status'] ?? 'completed';

    String dateStr = '';
    if (createdAt.toString().isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        dateStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final color = direction == 'credit' ? AppColors.success : AppColors.error;
    IconData icon;
    switch (type) {
      case 'commission_deduction': icon = Icons.percent_rounded; break;
      case 'wallet_recharge': icon = Icons.add_circle_rounded; break;
      case 'doctor_earning': icon = Icons.local_hospital_rounded; break;
      case 'refund': icon = Icons.replay_rounded; break;
      default: icon = Icons.swap_horiz_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.light300)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                    if (status != 'completed') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.warning50, borderRadius: BorderRadius.circular(6)),
                        child: Text(status.toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.warning600)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text('${direction == 'credit' ? '+' : '-'}${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}

// ── Payment Method Selection Card Widget ──

class _PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.light100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.light400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
