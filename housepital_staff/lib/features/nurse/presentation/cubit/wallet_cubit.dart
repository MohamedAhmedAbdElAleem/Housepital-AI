import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

// ── States ────────────────────────────────────────────────────

abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final double balance;
  final bool walletBlocked;
  final String? walletBlockReason;
  final double threshold;
  final double commissionRate;
  final List<dynamic> transactions;
  final int totalTransactions;
  final List<dynamic> receipts;

  WalletLoaded({
    required this.balance,
    required this.walletBlocked,
    this.walletBlockReason,
    required this.threshold,
    required this.commissionRate,
    required this.transactions,
    required this.totalTransactions,
    required this.receipts,
  });
}

class WalletPaymentInfoLoaded extends WalletState {
  final List<dynamic> methods;
  final Map<String, dynamic> instructions;

  WalletPaymentInfoLoaded({
    required this.methods,
    required this.instructions,
  });
}

class WalletReceiptSubmitting extends WalletState {}

class WalletReceiptSubmitted extends WalletState {
  final String message;
  final String receiptId;

  WalletReceiptSubmitted({required this.message, required this.receiptId});
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────

class NurseWalletCubit extends Cubit<WalletState> {
  final ApiClient apiClient;

  NurseWalletCubit(this.apiClient) : super(WalletInitial());

  Future<void> loadWallet() async {
    emit(WalletLoading());
    try {
      final results = await Future.wait([
        apiClient.get(ApiConstants.walletBalance),
        apiClient.get('${ApiConstants.walletTransactions}?limit=50'),
        apiClient.get(ApiConstants.walletMyReceipts),
      ]);

      final balanceData = results[0]['data'];
      final txData = results[1]['data'];
      final receiptsData = results[2]['data'];

      emit(WalletLoaded(
        balance: (balanceData['balance'] ?? 0).toDouble(),
        walletBlocked: balanceData['walletBlocked'] ?? false,
        walletBlockReason: balanceData['walletBlockReason'],
        threshold: (balanceData['threshold'] ?? -150).toDouble(),
        commissionRate: (balanceData['commissionRate'] ?? 0.15).toDouble(),
        transactions: txData['transactions'] ?? [],
        totalTransactions: txData['total'] ?? 0,
        receipts: receiptsData['receipts'] ?? [],
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Fetch available payment methods (Instapay / Mobile Wallet)
  Future<Map<String, dynamic>?> fetchPaymentInfo() async {
    try {
      final response = await apiClient.get(ApiConstants.walletPaymentInfo);
      if (response['success'] == true) {
        return response['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Submit a recharge receipt
  Future<void> submitReceipt({
    required double amount,
    required String paymentMethod,
    required String receiptBase64,
  }) async {
    emit(WalletReceiptSubmitting());
    try {
      final response = await apiClient.post(
        ApiConstants.walletSubmitReceipt,
        body: {
          'amount': amount,
          'paymentMethod': paymentMethod,
          'receiptBase64': receiptBase64,
        },
      );

      if (response['success'] == true) {
        emit(WalletReceiptSubmitted(
          message: response['message'] ?? 'Receipt submitted successfully!',
          receiptId: response['data']?['receiptId'] ?? '',
        ));
        // Reload wallet data after submission
        await loadWallet();
      } else {
        emit(WalletError(response['message'] ?? 'Failed to submit receipt'));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> refreshAfterRecharge() async {
    await loadWallet();
  }
}
