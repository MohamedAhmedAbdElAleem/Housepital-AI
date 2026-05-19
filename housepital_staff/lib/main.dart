import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/theme_cubit.dart';
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
import 'features/doctor/presentation/cubit/clinic_cubit.dart';
import 'features/doctor/presentation/cubit/service_cubit.dart';
import 'features/doctor/presentation/cubit/appointment_cubit.dart';
import 'features/nurse/data/datasources/nurse_remote_datasource.dart';
import 'features/nurse/data/repositories/nurse_repository.dart';
import 'features/nurse/presentation/cubit/nurse_profile_cubit.dart';
import 'features/nurse/presentation/cubit/nurse_booking_cubit.dart';
import 'features/nurse/presentation/cubit/wallet_cubit.dart';
import 'features/doctor/presentation/cubit/wallet_cubit.dart';
import 'features/doctor/presentation/cubit/notification_cubit.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Core Dependencies
  final apiClient = ApiClient();
  final authDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);

  // Doctor Dependencies
  final doctorDataSource = DoctorRemoteDataSourceImpl(apiClient: apiClient);
  final doctorRepository = DoctorRepositoryImpl(
    remoteDataSource: doctorDataSource,
  );

  // Nurse Dependencies
  final nurseDataSource = NurseRemoteDataSourceImpl(apiClient: apiClient);
  final nurseRepository = NurseRepositoryImpl(
    remoteDataSource: nurseDataSource,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AuthCubit(repository: authRepository)),
          BlocProvider(create: (_) => DoctorCubit(repository: doctorRepository)),
          BlocProvider(create: (_) => ClinicCubit(repository: doctorRepository)),
          BlocProvider(create: (_) => ServiceCubit(repository: doctorRepository)),
          BlocProvider(create: (_) => AppointmentCubit()),
          BlocProvider(
            create: (_) => NurseProfileCubit(repository: nurseRepository),
          ),
          BlocProvider(create: (_) => NurseBookingCubit(apiClient)),
          BlocProvider(create: (_) => NurseWalletCubit(apiClient)),
          BlocProvider(create: (_) => DoctorWalletCubit(apiClient)),
          BlocProvider(create: (_) => NotificationCubit(apiClient: apiClient)),
          BlocProvider(create: (_) => AdminCubit(apiClient: apiClient)),
        ],
        child: const HousepitalStaffApp(),
      ),
    ),
  );
}

class HousepitalStaffApp extends StatelessWidget {
  const HousepitalStaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
