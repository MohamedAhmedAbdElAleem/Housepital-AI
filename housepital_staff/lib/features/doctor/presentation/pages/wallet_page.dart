import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/doctor_theme.dart';
import '../widgets/background_blobs.dart';
import '../widgets/glass_header.dart';
import '../cubit/wallet_cubit.dart';

class DoctorWalletPage extends StatefulWidget {
  const DoctorWalletPage({super.key});
  @override
  State<DoctorWalletPage> createState() => _DoctorWalletPageState();
}

class _DoctorWalletPageState extends State<DoctorWalletPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    context.read<DoctorWalletCubit>().loadWallet();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  void _showRechargeSheet() async {
    final cubit = context.read<DoctorWalletCubit>();
    final paymentInfo = await cubit.fetchPaymentInfo();
    if (!mounted) return;
    if (paymentInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load payment info'), backgroundColor: DoctorTheme.danger));
      return;
    }
    final methods = paymentInfo['methods'] as List<dynamic>? ?? [];
    if (!mounted) return;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => _RechargeSheet(methods: methods, cubit: cubit, parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DoctorTheme.background(context),
      body: BackgroundBlobs(
        child: SafeArea(
          child: Column(
            children: [
              GlassHeader(
                title: 'My Wallet',
                subtitle: 'Manage your balances and receipts',
                onBack: () => Navigator.pop(context),
                actionIcon: Icons.refresh_rounded,
                onAction: () => context.read<DoctorWalletCubit>().loadWallet(),
                actionTooltip: 'Refresh Wallet',
              ),
              Expanded(
                child: BlocConsumer<DoctorWalletCubit, DoctorWalletState>(
                  listener: (context, state) {
                    if (state is DoctorWalletLoaded) _animController.forward(from: 0);
                    if (state is DoctorWalletReceiptSubmitted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: DoctorTheme.success));
                    }
                    if (state is DoctorWalletError) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: DoctorTheme.danger));
                      context.read<DoctorWalletCubit>().loadWallet();
                    }
                  },
                  builder: (context, state) {
                    if (state is DoctorWalletLoading || state is DoctorWalletInitial || state is DoctorWalletReceiptSubmitting) {
                      return Center(child: CircularProgressIndicator(color: DoctorTheme.primary));
                    }
                    if (state is DoctorWalletLoaded) return _buildContent(state);
                    return Center(child: Text('Something went wrong'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DoctorWalletLoaded state) {
    return FadeTransition(opacity: _fadeAnim, child: RefreshIndicator(
      onRefresh: () => context.read<DoctorWalletCubit>().loadWallet(),
      child: ListView(padding: EdgeInsets.all(20), children: [
        _buildBalanceCard(state),
        if (state.walletBlocked) ...[SizedBox(height: 16), _buildBlockedBanner(state)],
        SizedBox(height: 16), _buildRechargeButton(state),
        SizedBox(height: 16), _buildCommissionInfoCard(state),
        SizedBox(height: 24),
        if (state.receipts.isNotEmpty) ...[
          _buildReceiptsSection(state),
          SizedBox(height: 24),
        ],
        _buildTransactionsSection(state),
      ])));
  }

  Widget _buildBalanceCard(DoctorWalletLoaded state) {
    return Container(padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: state.walletBlocked ? LinearGradient(colors: DoctorTheme.blockedGradient) : LinearGradient(colors: DoctorTheme.walletGradient),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: (state.walletBlocked ? DoctorTheme.danger : DoctorTheme.primary).withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(state.walletBlocked ? Icons.lock_rounded : Icons.account_balance_wallet_rounded, color: DoctorTheme.surface(context), size: 24)),
          SizedBox(width: 12),
          Text('Doctor Wallet', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (state.walletBlocked) Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.lock_rounded, color: DoctorTheme.surface(context), size: 14), SizedBox(width: 4),
              Text('BLOCKED', style: TextStyle(color: DoctorTheme.surface(context), fontSize: 11, fontWeight: FontWeight.w700))])),
        ]),
        SizedBox(height: 20),
        Text('${state.balance >= 0 ? "" : "-"}${state.balance.abs().toStringAsFixed(2)} EGP', style: TextStyle(color: DoctorTheme.surface(context), fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1)),
        SizedBox(height: 8),
        Text('Min: ${state.threshold.toStringAsFixed(0)} EGP • Commission: ${(state.commissionRate * 100).toStringAsFixed(0)}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
      ]));
  }

  Widget _buildBlockedBanner(DoctorWalletLoaded state) {
    return Container(padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: DoctorTheme.dangerLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: DoctorTheme.danger.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.warning_amber_rounded, color: DoctorTheme.danger, size: 22), SizedBox(width: 8),
          Text('Account Restricted', style: TextStyle(color: DoctorTheme.danger, fontWeight: FontWeight.w700, fontSize: 15))]),
        SizedBox(height: 8),
        Text(state.walletBlockReason ?? 'Your wallet balance has exceeded the minimum threshold.', style: TextStyle(color: DoctorTheme.danger, fontSize: 13, height: 1.4)),
        SizedBox(height: 8),
        Text('Recharge your wallet to unblock your account.', style: TextStyle(color: DoctorTheme.danger, fontSize: 13, fontWeight: FontWeight.w600)),
      ]));
  }

  Widget _buildRechargeButton(DoctorWalletLoaded state) {
    return SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: _showRechargeSheet,
      icon: Icon(Icons.add_circle_outline_rounded, size: 22),
      label: Text(state.walletBlocked ? 'Recharge to Unblock Account' : 'Recharge Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(backgroundColor: state.walletBlocked ? DoctorTheme.danger : DoctorTheme.primary, foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2)));
  }

  Widget _buildCommissionInfoCard(DoctorWalletLoaded state) {
    return Container(padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: DoctorTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: DoctorTheme.border(context))),
      child: Row(children: [Icon(Icons.info_outline_rounded, color: DoctorTheme.primaryDark, size: 22), SizedBox(width: 12),
        Expanded(child: Text('A ${(state.commissionRate * 100).toStringAsFixed(0)}% platform commission is deducted for each completed appointment.',
          style: TextStyle(color: DoctorTheme.primaryDark, fontSize: 13, height: 1.4)))]));
  }

  Widget _buildReceiptsSection(DoctorWalletLoaded state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('My Receipts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DoctorTheme.textPrimary(context))),
      SizedBox(height: 4),
      Text('Track the status of your recharge requests', style: TextStyle(fontSize: 13, color: DoctorTheme.textSecondary(context))),
      SizedBox(height: 16),
      ...state.receipts.map((r) => _buildReceiptTile(r)),
    ]);
  }

  Widget _buildReceiptTile(dynamic r) {
    final status = r['status'] ?? 'pending';
    final amount = (r['amount'] ?? 0).toDouble();
    final method = r['paymentMethod'] ?? '';
    final createdAt = r['createdAt'] ?? '';
    final rejectionReason = r['rejectionReason'];

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (status) {
      case 'approved': statusColor = DoctorTheme.success; statusIcon = Icons.check_circle_rounded; statusLabel = 'APPROVED'; break;
      case 'rejected': statusColor = DoctorTheme.danger; statusIcon = Icons.cancel_rounded; statusLabel = 'REJECTED'; break;
      default: statusColor = DoctorTheme.warning; statusIcon = Icons.schedule_rounded; statusLabel = 'PENDING';
    }

    String dateStr = '';
    if (createdAt.toString().isNotEmpty) {
      try { final dt = DateTime.parse(createdAt); dateStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'; } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: DoctorTheme.surface(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: statusColor.withValues(alpha: 0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(statusIcon, color: statusColor, size: 22)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${amount.toStringAsFixed(0)} EGP via ${method == 'instapay' ? 'Instapay' : 'Mobile Wallet'}',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: DoctorTheme.textPrimary(context))),
            SizedBox(height: 3),
            Text(dateStr, style: TextStyle(fontSize: 12, color: DoctorTheme.textHint(context))),
          ])),
          Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor))),
        ]),
        if (status == 'rejected' && rejectionReason != null) ...[
          SizedBox(height: 8),
          Container(padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: DoctorTheme.danger.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.info_outline_rounded, size: 16, color: DoctorTheme.danger), SizedBox(width: 6),
              Expanded(child: Text('Reason: $rejectionReason', style: TextStyle(fontSize: 12, color: DoctorTheme.danger, height: 1.3))),
            ])),
        ],
      ]),
    );
  }

  Widget _buildTransactionsSection(DoctorWalletLoaded state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Transaction History (${state.totalTransactions})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: DoctorTheme.textPrimary(context))),
      SizedBox(height: 16),
      if (state.transactions.isEmpty)
        Container(padding: EdgeInsets.symmetric(vertical: 40), width: double.infinity,
          decoration: BoxDecoration(color: DoctorTheme.surface(context), borderRadius: BorderRadius.circular(16)),
          child: Column(children: [Icon(Icons.receipt_long_rounded, size: 48, color: DoctorTheme.textHint(context)), SizedBox(height: 12),
            Text('No transactions yet', style: TextStyle(color: DoctorTheme.textSecondary(context), fontSize: 14))]))
      else ...state.transactions.map((tx) => _buildTransactionTile(tx)),
    ]);
  }

  Widget _buildTransactionTile(dynamic tx) {
    final type = tx['type'] ?? ''; final direction = tx['direction'] ?? '';
    final amount = (tx['amount'] ?? 0).toDouble(); final description = tx['description'] ?? type;
    final createdAt = tx['createdAt'] ?? ''; final status = tx['status'] ?? 'completed';
    String dateStr = '';
    if (createdAt.toString().isNotEmpty) { try { final dt = DateTime.parse(createdAt); dateStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'; } catch (_) {} }
    final color = direction == 'credit' ? DoctorTheme.success : DoctorTheme.danger;
    IconData icon;
    switch (type) { case 'commission_deduction': icon = Icons.percent_rounded; break; case 'wallet_recharge': case 'receipt_recharge': icon = Icons.add_circle_rounded; break;
      case 'doctor_earning': icon = Icons.local_hospital_rounded; break; case 'refund': icon = Icons.replay_rounded; break; default: icon = Icons.swap_horiz_rounded; }
    return Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: DoctorTheme.surface(context), borderRadius: BorderRadius.circular(14), border: Border.all(color: DoctorTheme.border(context))),
      child: Row(children: [
        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(description, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: DoctorTheme.textPrimary(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
          SizedBox(height: 3),
          Row(children: [Text(dateStr, style: TextStyle(fontSize: 12, color: DoctorTheme.textHint(context))),
            if (status != 'completed') ...[SizedBox(width: 8), Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: DoctorTheme.warningLight, borderRadius: BorderRadius.circular(6)),
              child: Text(status.toString().toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: DoctorTheme.warning)))]])])),
        Text('${direction == 'credit' ? '+' : '-'}${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
      ]));
  }
}

// ── Recharge Bottom Sheet ──────────────────────────────────────

class _RechargeSheet extends StatefulWidget {
  final List<dynamic> methods;
  final DoctorWalletCubit cubit;
  final BuildContext parentContext;
  const _RechargeSheet({required this.methods, required this.cubit, required this.parentContext});
  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'instapay';
  File? _receiptFile;
  bool _isSubmitting = false;

  @override
  void dispose() { _amountController.dispose(); super.dispose(); }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(context: context, builder: (ctx) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: Icon(Icons.camera_alt_rounded), title: Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(leading: Icon(Icons.photo_library_rounded), title: Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
      ])));
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _receiptFile = File(picked.path));
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 10 || amount > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount (10 - 50,000 EGP)'), backgroundColor: DoctorTheme.warning));
      return;
    }
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload your transfer receipt'), backgroundColor: DoctorTheme.warning));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final bytes = await _receiptFile!.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (!mounted) return;
      Navigator.pop(context);
      widget.cubit.submitReceipt(amount: amount, paymentMethod: _selectedMethod, receiptBase64: base64Str);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DoctorTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final instapay = widget.methods.firstWhere((m) => m['method'] == 'instapay', orElse: () => null);
    final mobileWallet = widget.methods.firstWhere((m) => m['method'] == 'mobile_wallet', orElse: () => null);

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(color: DoctorTheme.surface(context), borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: DoctorTheme.border(context), borderRadius: BorderRadius.circular(2)))),
        SizedBox(height: 20),
        Text('Recharge Wallet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: DoctorTheme.textPrimary(context))),
        SizedBox(height: 6),
        Text('Transfer the amount then upload your receipt.', style: TextStyle(color: DoctorTheme.textSecondary(context), fontSize: 14)),
        SizedBox(height: 20),

        Text('Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        Row(children: [
          Expanded(child: _MethodCard(icon: Icons.account_balance_rounded, label: 'Instapay', isSelected: _selectedMethod == 'instapay', onTap: () => setState(() => _selectedMethod = 'instapay'))),
          SizedBox(width: 12),
          Expanded(child: _MethodCard(icon: Icons.phone_android_rounded, label: 'Mobile Wallet', isSelected: _selectedMethod == 'mobile_wallet', onTap: () => setState(() => _selectedMethod = 'mobile_wallet'))),
        ]),
        SizedBox(height: 16),

        Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: DoctorTheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: DoctorTheme.primaryDark)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedMethod == 'instapay' ? '📱 Instapay Details' : '📱 Mobile Wallet Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            SizedBox(height: 8),
            if (_selectedMethod == 'instapay' && instapay != null) ...[
              _infoRow('Phone', instapay['phoneNumber'] ?? ''), _infoRow('Name', instapay['receiverName'] ?? ''),
              if (instapay['link'] != null) _infoRow('Link', instapay['link']),
            ] else if (mobileWallet != null) ...[
              _infoRow('Phone', mobileWallet['phoneNumber'] ?? ''), _infoRow('Name', mobileWallet['receiverName'] ?? ''),
            ],
          ])),
        SizedBox(height: 16),

        Row(children: [50, 100, 200, 500].map((a) => Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(onPressed: () => setState(() => _amountController.text = a.toString()),
            style: OutlinedButton.styleFrom(foregroundColor: DoctorTheme.primary, side: BorderSide(color: DoctorTheme.primaryDark),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(vertical: 10)),
            child: Text('$a', style: TextStyle(fontWeight: FontWeight.w600)))))).toList()),
        SizedBox(height: 12),

        TextField(controller: _amountController, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount (EGP)', hintText: 'Min 10', prefixIcon: Icon(Icons.payments_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: DoctorTheme.border(context))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: DoctorTheme.primary, width: 2)))),
        SizedBox(height: 16),

        GestureDetector(onTap: _pickReceipt, child: Container(width: double.infinity, padding: EdgeInsets.all(20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _receiptFile != null ? DoctorTheme.success : DoctorTheme.border(context), width: _receiptFile != null ? 2 : 1),
            color: _receiptFile != null ? DoctorTheme.success.withValues(alpha: 0.05) : null),
          child: Column(children: [
            Icon(_receiptFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, size: 40, color: _receiptFile != null ? DoctorTheme.success : DoctorTheme.textSecondary(context)),
            SizedBox(height: 8),
            Text(_receiptFile != null ? 'Receipt uploaded ✓' : 'Tap to upload receipt photo', style: TextStyle(color: _receiptFile != null ? DoctorTheme.success : DoctorTheme.textSecondary(context), fontWeight: FontWeight.w600)),
            if (_receiptFile != null) TextButton(onPressed: _pickReceipt, child: Text('Change photo')),
          ]))),
        SizedBox(height: 20),

        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: DoctorTheme.surface(context))) : Icon(Icons.send_rounded),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Receipt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(backgroundColor: DoctorTheme.primary, foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
      ])),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: EdgeInsets.only(bottom: 4), child: Row(children: [
      Text('$label: ', style: TextStyle(color: DoctorTheme.textSecondary(context), fontSize: 13)),
      Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
    ]));
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final VoidCallback onTap;
  const _MethodCard({required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: isSelected ? DoctorTheme.primary.withValues(alpha: 0.08) : DoctorTheme.surfaceDim(context),
        borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? DoctorTheme.primary : DoctorTheme.border(context), width: isSelected ? 2 : 1)),
      child: Column(children: [
        Icon(icon, size: 28, color: isSelected ? DoctorTheme.primary : DoctorTheme.textSecondary(context)), SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? DoctorTheme.primary : DoctorTheme.textSecondary(context)), textAlign: TextAlign.center),
      ])));
  }
}
