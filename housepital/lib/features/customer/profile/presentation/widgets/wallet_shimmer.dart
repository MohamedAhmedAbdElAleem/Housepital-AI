import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white10 : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white24 : Colors.grey[100]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card Shimmer
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              const SizedBox(height: 32),
              // Button Shimmer
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(height: 40),
              // Section Title Shimmer
              Container(height: 20, width: 150, color: Colors.white),
              const SizedBox(height: 20),
              // Transaction Shimmer List
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
