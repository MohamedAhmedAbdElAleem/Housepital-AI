import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

// ── States ────────────────────────────────────────────────────

abstract class DoctorWalletState {}

class DoctorWalletInitial extends DoctorWalletState {}

class DoctorWalletLoading extends DoctorWalletState {}

class DoctorWalletLoaded extends DoctorWalletState {
  final double balance;
  final bool walletBlocked;
  final String? walletBlockReason;
  final double threshold;
  final double commissionRate;
  final List<dynamic> transactions;
  final int totalTransactions;
  final List<dynamic> receipts;

  DoctorWalletLoaded({
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

class DoctorWalletPaymentInfoLoaded extends DoctorWalletState {
  final List<dynamic> methods;
  final Map<String, dynamic> instructions;

  DoctorWalletPaymentInfoLoaded({
    required this.methods,
    required this.instructions,
  });
}

class DoctorWalletReceiptSubmitting extends DoctorWalletState {}

class DoctorWalletReceiptSubmitted extends DoctorWalletState {
  final String message;
  final String receiptId;

  DoctorWalletReceiptSubmitted({required this.message, required this.receiptId});
}

class DoctorWalletError extends DoctorWalletState {
  final String message;
  DoctorWalletError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────

class DoctorWalletCubit extends Cubit<DoctorWalletState> {
  final ApiClient apiClient;

  DoctorWalletCubit(this.apiClient) : super(DoctorWalletInitial());

  Future<void> loadWallet() async {
    emit(DoctorWalletLoading());
    try {
      final results = await Future.wait([
        apiClient.get(ApiConstants.walletBalance),
        apiClient.get('${ApiConstants.walletTransactions}?limit=50'),
        apiClient.get(ApiConstants.walletMyReceipts),
      ]);

      final balanceData = results[0]['data'];
      final txData = results[1]['data'];
      final receiptsData = results[2]['data'];

      emit(DoctorWalletLoaded(
        balance: (balanceData['balance'] ?? 0).toDouble(),
        walletBlocked: balanceData['walletBlocked'] ?? false,
        walletBlockReason: balanceData['walletBlockReason'],
        threshold: (balanceData['threshold'] ?? -150).toDouble(),
        commissionRate: (balanceData['commissionRate'] ?? 0.10).toDouble(),
        transactions: txData['transactions'] ?? [],
        totalTransactions: txData['total'] ?? 0,
        receipts: receiptsData['receipts'] ?? [],
      ));
    } catch (e) {
      emit(DoctorWalletError(e.toString()));
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
    emit(DoctorWalletReceiptSubmitting());
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
        emit(DoctorWalletReceiptSubmitted(
          message: response['message'] ?? 'receipt_submitted_successfully'.tr(),
          receiptId: response['data']?['receiptId'] ?? '',
        ));
        // Reload wallet data after submission
        await loadWallet();
      } else {
        emit(DoctorWalletError(response['message'] ?? 'failed_to_submit_receipt'.tr()));
      }
    } catch (e) {
      emit(DoctorWalletError(e.toString()));
    }
  }

  Future<void> refreshAfterRecharge() async {
    await loadWallet();
  }
}
