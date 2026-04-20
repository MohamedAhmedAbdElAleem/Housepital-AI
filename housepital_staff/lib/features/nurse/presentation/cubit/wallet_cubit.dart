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

  WalletLoaded({
    required this.balance,
    required this.walletBlocked,
    this.walletBlockReason,
    required this.threshold,
    required this.commissionRate,
    required this.transactions,
    required this.totalTransactions,
  });
}

class WalletRechargeCard extends WalletState {
  final String iframeUrl;
  final int orderId;
  final double amount;

  WalletRechargeCard({
    required this.iframeUrl,
    required this.orderId,
    required this.amount,
  });
}

class WalletRechargeWallet extends WalletState {
  final String redirectUrl;
  final int orderId;
  final double amount;

  WalletRechargeWallet({
    required this.redirectUrl,
    required this.orderId,
    required this.amount,
  });
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
      ]);

      final balanceData = results[0]['data'];
      final txData = results[1]['data'];

      emit(WalletLoaded(
        balance: (balanceData['balance'] ?? 0).toDouble(),
        walletBlocked: balanceData['walletBlocked'] ?? false,
        walletBlockReason: balanceData['walletBlockReason'],
        threshold: (balanceData['threshold'] ?? -150).toDouble(),
        commissionRate: (balanceData['commissionRate'] ?? 0.15).toDouble(),
        transactions: txData['transactions'] ?? [],
        totalTransactions: txData['total'] ?? 0,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Initiate card payment — returns iframe URL
  Future<void> initiateCardRecharge(double amount) async {
    try {
      final response = await apiClient.post(
        ApiConstants.walletRechargeInitiate,
        body: {'amount': amount, 'paymentMethod': 'card'},
      );

      if (response['success'] == true) {
        final data = response['data'];
        emit(WalletRechargeCard(
          iframeUrl: data['iframeUrl'],
          orderId: data['orderId'],
          amount: amount,
        ));
      } else {
        emit(WalletError(response['message'] ?? 'Failed to initiate card payment'));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// Initiate mobile wallet payment — returns redirect URL
  Future<void> initiateWalletRecharge(double amount, String phoneNumber) async {
    try {
      final response = await apiClient.post(
        ApiConstants.walletRechargeInitiate,
        body: {
          'amount': amount,
          'paymentMethod': 'wallet',
          'walletPhoneNumber': phoneNumber,
        },
      );

      if (response['success'] == true) {
        final data = response['data'];
        emit(WalletRechargeWallet(
          redirectUrl: data['redirectUrl'],
          orderId: data['orderId'],
          amount: amount,
        ));
      } else {
        emit(WalletError(response['message'] ?? 'Failed to initiate wallet payment'));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> refreshAfterRecharge() async {
    await loadWallet();
  }
}
