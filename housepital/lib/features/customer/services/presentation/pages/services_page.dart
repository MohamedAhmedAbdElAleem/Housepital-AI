import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add service catalog with filtering
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Service Categories', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 16),
          // TODO: Add category chips/filters
          // TODO: Add service cards list
          _buildServiceCategoryCard('Post-Surgical Care'),
          _buildServiceCategoryCard('Elderly / Chronic Diseases Care'),
          _buildServiceCategoryCard('Injection Service'),
          _buildServiceCategoryCard('Broken Bones'),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryCard(String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // TODO: Navigate to service details
        },
      ),
    );
  }
}
