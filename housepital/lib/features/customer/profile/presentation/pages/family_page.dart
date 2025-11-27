import 'package:flutter/material.dart';
import '../../../../auth/data/models/user_model.dart';
import '../../../../../core/network/api_service.dart';
import '../../../../../core/utils/token_manager.dart';
import 'add_dependent_page.dart';

class FamilyPage extends StatefulWidget {
  const FamilyPage({Key? key}) : super(key: key);

  @override
  State<FamilyPage> createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  List<dynamic> _dependents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDependents();
  }

  Future<void> _fetchDependents() async {
    setState(() { _isLoading = true; });
    try {
      final apiService = ApiService();
      final response = await apiService.get(
        '/api/user/getAllDependents',
      );
      setState(() {
        _dependents = response is List ? response : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      // Handle error (show snackbar, etc)
    }
  }

  void _goToAddDependent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDependentPage()),
    );
    if (result == true) {
      _fetchDependents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dependents.isEmpty
              ? const Center(child: Text('No dependents found.'))
              : ListView.builder(
                  itemCount: _dependents.length,
                  itemBuilder: (context, index) {
                    final dep = _dependents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(dep['fullName'] ?? ''),
                        subtitle: Text(dep['relationship'] ?? ''),
                        trailing: Text(dep['gender'] ?? ''),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _goToAddDependent,
          child: const Text('Add Dependent'),
        ),
      ),
    );
  }
}
