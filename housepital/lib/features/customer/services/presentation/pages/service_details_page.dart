import 'package:flutter/material.dart';

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Show service details, pricing, duration
    return Scaffold(
      appBar: AppBar(title: const Text('Service Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Service image
            const Text(
              'Service Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Description goes here'),
            const SizedBox(height: 16),
            const Text('Price: 150-250 EGP'),
            const SizedBox(height: 8),
            const Text('Duration: 15-25 mins'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking page
              },
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
