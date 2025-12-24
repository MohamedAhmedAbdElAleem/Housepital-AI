import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Show user profile information
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          const Text(
            'User Name',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text('user@email.com', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          _buildMenuItem('Personal Information', Icons.info),
          _buildMenuItem('Medical History', Icons.medical_information),
          _buildMenuItem('Dependancies', Icons.people),
          _buildMenuItem('Plans', Icons.card_membership),
          _buildMenuItem('Settings', Icons.settings),
          _buildMenuItem('Logout', Icons.logout),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to respective page
        },
      ),
    );
  }
}
