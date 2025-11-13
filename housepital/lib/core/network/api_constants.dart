class ApiConstants {
  // Base URL for the API
  // Use 10.0.2.2 for Android Emulator (localhost on host machine)
  static const String baseUrl = 'http://10.0.2.2:3500';

  // API Endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String getCurrentUser = '/api/auth/me';

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
