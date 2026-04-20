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

  DoctorWalletLoaded({
    required this.balance,
    required this.walletBlocked,
    this.walletBlockReason,
    required this.threshold,
    required this.commissionRate,
    required this.transactions,
    required this.totalTransactions,
  });
}

class DoctorWalletRechargeCard extends DoctorWalletState {
  final String iframeUrl;
  final int orderId;
  final double amount;

  DoctorWalletRechargeCard({
    required this.iframeUrl,
    required this.orderId,
    required this.amount,
  });
}

class DoctorWalletRechargeWallet extends DoctorWalletState {
  final String redirectUrl;
  final int orderId;
  final double amount;

  DoctorWalletRechargeWallet({
    required this.redirectUrl,
    required this.orderId,
    required this.amount,
  });
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
      ]);

      final balanceData = results[0]['data'];
      final txData = results[1]['data'];

      emit(DoctorWalletLoaded(
        balance: (balanceData['balance'] ?? 0).toDouble(),
        walletBlocked: balanceData['walletBlocked'] ?? false,
        walletBlockReason: balanceData['walletBlockReason'],
        threshold: (balanceData['threshold'] ?? -150).toDouble(),
        commissionRate: (balanceData['commissionRate'] ?? 0.10).toDouble(),
        transactions: txData['transactions'] ?? [],
        totalTransactions: txData['total'] ?? 0,
      ));
    } catch (e) {
      emit(DoctorWalletError(e.toString()));
    }
  }

  Future<void> initiateCardRecharge(double amount) async {
    try {
      final response = await apiClient.post(
        ApiConstants.walletRechargeInitiate,
        body: {'amount': amount, 'paymentMethod': 'card'},
      );

      if (response['success'] == true) {
        final data = response['data'];
        emit(DoctorWalletRechargeCard(
          iframeUrl: data['iframeUrl'],
          orderId: data['orderId'],
          amount: amount,
        ));
      } else {
        emit(DoctorWalletError(response['message'] ?? 'Failed to initiate card payment'));
      }
    } catch (e) {
      emit(DoctorWalletError(e.toString()));
    }
  }

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
        emit(DoctorWalletRechargeWallet(
          redirectUrl: data['redirectUrl'],
          orderId: data['orderId'],
          amount: amount,
        ));
      } else {
        emit(DoctorWalletError(response['message'] ?? 'Failed to initiate wallet payment'));
      }
    } catch (e) {
      emit(DoctorWalletError(e.toString()));
    }
  }

  Future<void> refreshAfterRecharge() async {
    await loadWallet();
  }
}
