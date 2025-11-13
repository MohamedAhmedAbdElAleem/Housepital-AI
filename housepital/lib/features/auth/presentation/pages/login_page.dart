import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add login form with email, password fields
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Login Page', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              // TODO: Add Email TextField
              // TODO: Add Password TextField
              // TODO: Add Login Button
              // TODO: Add Register Navigation
            ],
          ),
        ),
      ),
    );
  }
}
