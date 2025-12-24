import 'package:flutter/material.dart';

class NurseHomePage extends StatelessWidget {
  const NurseHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add nurse home with new requests, current services
    return Scaffold(
      appBar: AppBar(title: const Text('Home - Nurse')),
      body: const Center(child: Text('Nurse Home Page - New Requests')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
