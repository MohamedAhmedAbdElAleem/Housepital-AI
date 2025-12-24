import 'package:flutter/material.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Show new service requests for nurse/doctor
    return Scaffold(
      appBar: AppBar(title: const Text('New Requests')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRequestCard(
            'Wound Care Service',
            'Patient: Ahmed Mohamed',
            'Location: Cairo, Nasr City',
            'Time: Today, 3:00 PM',
          ),
          // TODO: Add more request cards from API
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    String service,
    String patient,
    String location,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(patient),
            Text(location),
            Text(time),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Reject request
                  },
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Accept request
                  },
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
