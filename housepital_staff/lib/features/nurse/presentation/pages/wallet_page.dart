import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/wallet_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class NurseWalletPage extends StatefulWidget {
  const NurseWalletPage({super.key});
  @override
  State<NurseWalletPage> createState() => _NurseWalletPageState();
}

class _NurseWalletPageState extends State<NurseWalletPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    context.read<NurseWalletCubit>().loadWallet();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  void _showRechargeSheet() async {
    final cubit = context.read<NurseWalletCubit>();
    final paymentInfo = await cubit.fetchPaymentInfo();
    if (!mounted) return;
    if (paymentInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.read<AppLocalizations>().failedToLoadPaymentInfo ?? 'Failed to load payment info'), backgroundColor: AppColors.error));
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.myWallet, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: theme.colorScheme.onSurface, centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => context.read<NurseWalletCubit>().loadWallet())],
      ),
      body: BlocConsumer<NurseWalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletLoaded) _animController.forward(from: 0);
          if (state is WalletReceiptSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt submitted successfully! 🎉'), backgroundColor: Colors.green));
          }
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
            context.read<NurseWalletCubit>().loadWallet();
          }
        },
        builder: (context, state) {
          if (state is WalletLoading || state is WalletInitial || state is WalletReceiptSubmitting) {
            return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
          }
          if (state is WalletLoaded) return _buildContent(state, l10n);
          return Center(child: Text(l10n.somethingWentWrong));
        },
      ),
    );
  }

  Widget _buildContent(WalletLoaded state, AppLocalizations l10n) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: () => context.read<NurseWalletCubit>().loadWallet(),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          _buildBalanceCard(state, l10n),
          if (state.walletBlocked) ...[const SizedBox(height: 16), _buildBlockedBanner(state, l10n)],
          const SizedBox(height: 16),
          _buildRechargeButton(state, l10n),
          const SizedBox(height: 16),
          _buildCommissionInfoCard(state, l10n),
          const SizedBox(height: 24),
          if (state.receipts.isNotEmpty) ...[
            _buildReceiptsSection(state, l10n),
            const SizedBox(height: 24),
          ],
          _buildTransactionsSection(state, l10n),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _buildBalanceCard(WalletLoaded state, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              state.walletBlocked
                  ? [const Color(0xFF8B1A1A), const Color(0xFFC62828)]
                  : [AppColors.primary700, AppColors.primary500, AppColors.primary400],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (state.walletBlocked ? AppColors.error : AppColors.primary500).withAlpha(90),
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
                decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(12)),
                child: Icon(state.walletBlocked ? Icons.lock_rounded : Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(l10n.myWallet, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Inter')),
              const Spacer(),
              if (state.walletBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withAlpha(50), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(l10n.blockedLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                  ]),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${state.balance >= 0 ? "" : "-"}${state.balance.abs().toStringAsFixed(2)} ${l10n.egp}',
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.minThreshold(state.threshold.toStringAsFixed(0))} • ${l10n.commission((state.commissionRate * 100).toStringAsFixed(0))}',
            style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner(WalletLoaded state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error50.withAlpha(isDark ? 40 : 255),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error200.withAlpha(isDark ? 80 : 255)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
          const SizedBox(width: 8),
          Text(l10n.accountRestricted, style: TextStyle(color: isDark ? AppColors.error200 : AppColors.error, fontWeight: FontWeight.w700, fontSize: 15))
        ]),
        const SizedBox(height: 8),
        Text(state.walletBlockReason ?? l10n.walletBlockedDesc, 
          style: TextStyle(color: isDark ? theme.colorScheme.onSurface.withAlpha(200) : AppColors.error700, fontSize: 13, height: 1.4)),
        const SizedBox(height: 8),
        Text(l10n.rechargeToUnblockDesc, 
          style: TextStyle(color: isDark ? AppColors.error200 : AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildRechargeButton(WalletLoaded state, AppLocalizations l10n) {
    return SizedBox(width: double.infinity, child: ElevatedButton.icon(
      onPressed: _showRechargeSheet,
      icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
      label: Text(state.walletBlocked ? l10n.rechargeToUnblockButton : l10n.rechargeWallet, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: state.walletBlocked ? AppColors.error : Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 2),
    ));
  }

  Widget _buildCommissionInfoCard(WalletLoaded state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(isDark ? 50 : 30)),
      ),
      child: Row(children: [
        Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(l10n.confirmCompleteSub,
          style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(200), fontSize: 13, height: 1.4)))
      ]),
    );
  }

  Widget _buildReceiptsSection(WalletLoaded state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.myReceiptsTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
      const SizedBox(height: 4),
      Text(l10n.trackReceiptsDesc, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withAlpha(150))),
      const SizedBox(height: 16),
      ...state.receipts.map((r) => _buildReceiptTile(r)),
    ]);
  }

  Widget _buildReceiptTile(dynamic r) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final status = r['status'] ?? 'pending';
    final amount = (r['amount'] ?? 0).toDouble();
    final method = r['paymentMethod'] ?? '';
    final createdAt = r['createdAt'] ?? '';
    final rejectionReason = r['rejectionReason'];

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = l10n.approvedStatus;
        break;
      case 'rejected':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        statusLabel = l10n.rejectedStatus;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        statusLabel = l10n.pendingStatus;
    }

    String dateStr = '';
    if (createdAt.toString().isNotEmpty) {
      try { final dt = DateTime.parse(createdAt); dateStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'; } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withAlpha(isDark ? 30 : 20), borderRadius: BorderRadius.circular(12)),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${amount.toStringAsFixed(0)} ${l10n.egp} via ${method == 'instapay' ? 'Instapay' : 'Mobile Wallet'}',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 3),
            Text(dateStr, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusColor.withAlpha(isDark ? 30 : 20), borderRadius: BorderRadius.circular(8)),
            child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
          ),
        ]),
        if (status == 'rejected' && rejectionReason != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(8)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(child: Text('${l10n.reasonLabel}: $rejectionReason', style: TextStyle(fontSize: 12, color: isDark ? AppColors.error200 : AppColors.error700, height: 1.3))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildTransactionsSection(WalletLoaded state, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.transactionHistory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
      const SizedBox(height: 16),
      if (state.transactions.isEmpty)
        Container(padding: const EdgeInsets.symmetric(vertical: 40), width: double.infinity,
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outline.withAlpha(50))),
          child: Column(children: [
            Icon(Icons.receipt_long_rounded, size: 48, color: theme.colorScheme.onSurface.withAlpha(50)), 
            const SizedBox(height: 12),
            Text(l10n.noTransactionsYet, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(100), fontSize: 14))
          ]))
      else ...state.transactions.map((tx) => _buildTransactionTile(tx)),
    ]);
  }

  Widget _buildTransactionTile(dynamic tx) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final type = tx['type'] ?? ''; final direction = tx['direction'] ?? '';
    final amount = (tx['amount'] ?? 0).toDouble(); final description = tx['description'] ?? type;
    final createdAt = tx['createdAt'] ?? ''; final status = tx['status'] ?? 'completed';
    String dateStr = '';
    if (createdAt.toString().isNotEmpty) { try { final dt = DateTime.parse(createdAt); dateStr = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'; } catch (_) {} }
    final color = direction == 'credit' ? Colors.green : AppColors.error;
    IconData icon;
    switch (type) { case 'commission_deduction': icon = Icons.percent_rounded; break; case 'wallet_recharge': case 'receipt_recharge': icon = Icons.add_circle_rounded; break;
      case 'nurse_earning': icon = Icons.medical_services_rounded; break; case 'refund': icon = Icons.replay_rounded; break; default: icon = Icons.swap_horiz_rounded; }
    
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, 
        borderRadius: BorderRadius.circular(14), 
        border: Border.all(color: theme.colorScheme.outline.withAlpha(isDark ? 50 : 100)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withAlpha(isDark ? 30 : 20), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(description, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Row(children: [Text(dateStr, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withAlpha(100))),
            if (status != 'completed') ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.orange.withAlpha(40), borderRadius: BorderRadius.circular(6)),
              child: Text(status.toString().toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.orange)))]])])),
        Text('${direction == 'credit' ? '+' : '-'}${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color)),
      ]));
  }
}

class _RechargeSheet extends StatefulWidget {
  final List<dynamic> methods;
  final NurseWalletCubit cubit;
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
    final theme = Theme.of(context);
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(context: context, backgroundColor: Colors.transparent, builder: (ctx) => Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(child: Wrap(children: [
        ListTile(leading: const Icon(Icons.camera_alt_rounded), title: const Text('Camera'), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_rounded), title: const Text('Gallery'), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
      ]))));
    if (source == null) return;
    final picked = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 80);
    if (picked != null) setState(() => _receiptFile = File(picked.path));
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 10 || amount > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid amount (10 - 50,000 EGP)'), backgroundColor: Colors.orange));
      return;
    }
    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload your transfer receipt'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final bytes = await _receiptFile!.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      Navigator.pop(context);
      widget.cubit.submitReceipt(amount: amount, paymentMethod: _selectedMethod, receiptBase64: base64Str);
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final instapay = widget.methods.firstWhere((m) => m['method'] == 'instapay', orElse: () => null);
    final mobileWallet = widget.methods.firstWhere((m) => m['method'] == 'mobile_wallet', orElse: () => null);

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline.withAlpha(100), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        Text(l10n.rechargeWallet, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 6),
        Text(l10n.transferAmountDesc, style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14)),
        const SizedBox(height: 20),

        Text(l10n.paymentMethodLabel, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _MethodCard(icon: Icons.account_balance_rounded, label: 'Instapay', isSelected: _selectedMethod == 'instapay', onTap: () => setState(() => _selectedMethod = 'instapay'))),
          const SizedBox(width: 12),
          Expanded(child: _MethodCard(icon: Icons.phone_android_rounded, label: 'Mobile Wallet', isSelected: _selectedMethod == 'mobile_wallet', onTap: () => setState(() => _selectedMethod = 'mobile_wallet'))),
        ]),
        const SizedBox(height: 16),

        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(isDark ? 30 : 15), borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.primary.withAlpha(50))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedMethod == 'instapay' ? l10n.instapayDetails : l10n.mobileWalletDetails, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            if (_selectedMethod == 'instapay' && instapay != null) ...[
              _infoRow(context, l10n.phoneLabel, instapay['phoneNumber'] ?? ''),
              _infoRow(context, l10n.nameLabel, instapay['receiverName'] ?? ''),
              if (instapay['link'] != null) _infoRow(context, l10n.linkLabel, instapay['link']),
            ] else if (mobileWallet != null) ...[
              _infoRow(context, l10n.phoneLabel, mobileWallet['phoneNumber'] ?? ''),
              _infoRow(context, l10n.nameLabel, mobileWallet['receiverName'] ?? ''),
            ],
          ])),
        const SizedBox(height: 16),

        Row(children: [50, 100, 200, 500].map((a) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(onPressed: () => setState(() => _amountController.text = a.toString()),
            style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.primary, side: BorderSide(color: theme.colorScheme.primary.withAlpha(100)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 10)),
            child: Text('$a', style: const TextStyle(fontWeight: FontWeight.w600)))))).toList()),
        const SizedBox(height: 12),

        TextField(controller: _amountController, keyboardType: TextInputType.number,
          style: TextStyle(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            labelText: '${l10n.amountLabel} (${l10n.egp})', labelStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
            hintText: l10n.min10Label, hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(50)),
            prefixIcon: Icon(Icons.payments_rounded, color: theme.colorScheme.primary),
            filled: true, fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(50))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)))),
        const SizedBox(height: 16),

        GestureDetector(onTap: _pickReceipt, child: Container(width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), 
            border: Border.all(color: _receiptFile != null ? Colors.green : theme.colorScheme.outline.withAlpha(100), width: _receiptFile != null ? 2 : 1),
            color: _receiptFile != null ? Colors.green.withAlpha(20) : theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 40 : 100)),
          child: Column(children: [
            Icon(_receiptFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, size: 40, color: _receiptFile != null ? Colors.green : theme.colorScheme.onSurface.withAlpha(100)),
            const SizedBox(height: 8),
            Text(_receiptFile != null ? l10n.receiptUploaded : l10n.tapToUploadReceipt, style: TextStyle(color: _receiptFile != null ? Colors.green : theme.colorScheme.onSurface.withAlpha(150), fontWeight: FontWeight.w600)),
            if (_receiptFile != null) TextButton(onPressed: _pickReceipt, child: Text(l10n.changePhoto)),
          ]))),
        const SizedBox(height: 20),

        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
          label: Text(_isSubmitting ? l10n.submittingBtn : l10n.submitReceiptBtn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
      ])),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
      Text('$label: ', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 13)),
      Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
    ]));
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final VoidCallback onTap;
  const _MethodCard({required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary.withAlpha(isDark ? 60 : 20) : theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 80 : 255),
        borderRadius: BorderRadius.circular(14), 
        border: Border.all(color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withAlpha(isDark ? 50 : 100), width: isSelected ? 2 : 1)),
      child: Column(children: [
        Icon(icon, size: 28, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(100)), const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150)), textAlign: TextAlign.center),
      ])));
  }
}
