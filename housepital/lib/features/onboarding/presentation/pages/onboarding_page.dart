import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add PageView with 2 intro pages
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: const Center(child: Text('Onboarding Page - 2 Intro Pages')),
    );
  }
}
