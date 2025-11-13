import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add booking form with date, time, notes, supplies selection
    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date & Time', style: TextStyle(fontSize: 18)),
            // TODO: Add date picker
            const SizedBox(height: 16),
            const Text('Supplies', style: TextStyle(fontSize: 18)),
            // TODO: Add checkbox for supplies included
            const SizedBox(height: 16),
            const Text('Additional Notes', style: TextStyle(fontSize: 18)),
            // TODO: Add notes text field
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Submit booking request
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
