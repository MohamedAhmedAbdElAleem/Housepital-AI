import 'package:flutter/material.dart';

class VerifyOTPPage extends StatelessWidget {
  const VerifyOTPPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add OTP input fields (6 digits)
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: const Center(child: Text('Enter OTP Code')),
    );
  }
}
