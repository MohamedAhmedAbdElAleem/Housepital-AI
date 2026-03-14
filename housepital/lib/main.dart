import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HousepitalApp());
}

class HousepitalApp extends StatelessWidget {
  const HousepitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
