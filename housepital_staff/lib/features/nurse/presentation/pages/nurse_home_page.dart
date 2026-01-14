import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';

class NurseHomePage extends StatelessWidget {
  const NurseHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nurse Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: const Center(child: Text('Nurse functionality coming soon...')),
    );
  }
}
