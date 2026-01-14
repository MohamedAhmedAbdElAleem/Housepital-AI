import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/doctor/data/datasources/doctor_remote_datasource.dart';
import 'features/doctor/data/repositories/doctor_repository_impl.dart';
import 'features/doctor/presentation/cubit/doctor_cubit.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Core Dependencies
  final apiClient = ApiClient();
  final authDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

  // Doctor Dependencies
  final doctorDataSource = DoctorRemoteDataSourceImpl(apiClient: apiClient);
  final doctorRepository = DoctorRepositoryImpl(
    remoteDataSource: doctorDataSource,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(repository: authRepository)),
        BlocProvider(create: (_) => DoctorCubit(repository: doctorRepository)),
      ],
      child: const HousepitalStaffApp(),
    ),
  );
}

class HousepitalStaffApp extends StatelessWidget {
  const HousepitalStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
