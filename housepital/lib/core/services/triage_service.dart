import 'dart:convert';
import 'package:http/http.dart' as http;
import '../network/api_constants.dart';

/// Service model for triage-recommended services with navigation info
class TriageServiceRoute {
  final String route;
  final String title;
  final String price;
  final String duration;
  final String icon;
  final String color;
  final String? description;

  TriageServiceRoute({
    required this.route,
    required this.title,
    required this.price,
    required this.duration,
    required this.icon,
    required this.color,
    this.description,
  });

  factory TriageServiceRoute.fromJson(Map<String, dynamic> json) {
    return TriageServiceRoute(
      route: json['route'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? '',
      duration: json['duration'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '0xFF00B870',
      description: json['description'],
    );
  }
}

/// Response model for triage chat
class TriageResponse {
  final String response;
  final String? urgency;
  final bool showSos;
  final List<String> services;
  final List<TriageServiceRoute> serviceRoutes;
  final String source;

  TriageResponse({
    required this.response,
    this.urgency,
    required this.showSos,
    required this.services,
    required this.serviceRoutes,
    required this.source,
  });

  factory TriageResponse.fromJson(Map<String, dynamic> json) {
    return TriageResponse(
      response: json['response'] ?? '',
      urgency: json['urgency'],
      showSos: json['showSos'] ?? false,
      services: List<String>.from(json['services'] ?? []),
      serviceRoutes:
          (json['serviceRoutes'] as List<dynamic>?)
              ?.map((e) => TriageServiceRoute.fromJson(e))
              .toList() ??
          [],
      source: json['source'] ?? 'unknown',
    );
  }

  bool get isEmergency => urgency == 'Emergency';
  bool get isHighUrgency => urgency == 'High';
  bool get isMediumUrgency => urgency == 'Medium';
  bool get isLowUrgency => urgency == 'Low';
  bool get hasRecommendedServices => serviceRoutes.isNotEmpty;
}

/// Triage service for AI health assistant chatbot
class TriageService {
  static final TriageService _instance = TriageService._internal();
  factory TriageService() => _instance;
  TriageService._internal();

  String? _sessionId;

  String get sessionId {
    _sessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    return _sessionId!;
  }

  /// Send a message to the triage chatbot
  Future<TriageResponse> chat(String message) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/triage/chat');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message, 'sessionId': sessionId}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TriageResponse.fromJson(data);
      } else {
        // Return fallback response
        return _getFallbackResponse(message);
      }
    } catch (e) {
      print('Triage service error: $e');
      return _getFallbackResponse(message);
    }
  }

  /// Reset the conversation session
  Future<void> resetSession() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/triage/reset');
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId}),
      );
      _sessionId = null;
    } catch (e) {
      print('Reset session error: $e');
      _sessionId = null;
    }
  }

  /// Fallback response when API is unavailable
  TriageResponse _getFallbackResponse(String message) {
    final msgLower = message.toLowerCase();

    // Check for common patterns and provide helpful responses
    if (msgLower.contains('جرح') ||
        msgLower.contains('wound') ||
        msgLower.contains('ضمادة')) {
      return TriageResponse(
        response:
            '🩹 فاهم إنك محتاج رعاية جرح.\n\nخدمة "العناية بالجروح" مناسبة ليك - ممرضة متخصصة هتيجي البيت.\n\n💰 السعر: 150 جنيه\n⏱ المدة: 30-45 دقيقة\n\n👇 اضغط على الخدمة للحجز',
        urgency: 'Medium',
        showSos: false,
        services: ['Wound Care'],
        serviceRoutes: [
          TriageServiceRoute(
            route: 'wound_care',
            title: 'Wound Care',
            price: '150 EGP',
            duration: '30-45 min',
            icon: 'healing',
            color: '0xFFEF4444',
          ),
        ],
        source: 'fallback',
      );
    }

    if (msgLower.contains('حقنة') ||
        msgLower.contains('injection') ||
        msgLower.contains('ابرة')) {
      return TriageResponse(
        response:
            '💉 محتاج حقنة؟\n\nعندنا خدمة الحقن في البيت - ممرضة محترفة هتيجي تديك الحقنة بأمان.\n\n💰 السعر: 50 جنيه\n⏱ المدة: 15-20 دقيقة\n\n👇 اضغط للحجز',
        urgency: 'Low',
        showSos: false,
        services: ['Injections'],
        serviceRoutes: [
          TriageServiceRoute(
            route: 'injections',
            title: 'Injections',
            price: '50 EGP',
            duration: '15-20 min',
            icon: 'medication_liquid',
            color: '0xFF3B82F6',
          ),
        ],
        source: 'fallback',
      );
    }

    if (msgLower.contains('كبير') ||
        msgLower.contains('elderly') ||
        msgLower.contains('والدي') ||
        msgLower.contains('والدتي')) {
      return TriageResponse(
        response:
            '👴 رعاية كبار السن مهمة جداً.\n\nعندنا ممرضات متخصصات:\n• المساعدة في الأنشطة اليومية\n• متابعة الأدوية\n• قياس الضغط والسكر\n\n💰 السعر: 200 جنيه/ساعة\n\n👇 اضغط للحجز',
        urgency: 'Medium',
        showSos: false,
        services: ['Elderly Care'],
        serviceRoutes: [
          TriageServiceRoute(
            route: 'elderly_care',
            title: 'Elderly Care',
            price: '200 EGP/hr',
            duration: '1-4 hours',
            icon: 'elderly',
            color: '0xFF8B5CF6',
          ),
        ],
        source: 'fallback',
      );
    }

    if (msgLower.contains('عملية') ||
        msgLower.contains('surgery') ||
        msgLower.contains('جراحة')) {
      return TriageResponse(
        response:
            '🏥 الرعاية بعد العمليات مهمة للتعافي.\n\nخدمة "رعاية ما بعد العمليات" تشمل:\n• العناية بالجرح\n• متابعة الأدوية\n• مراقبة العلامات الحيوية\n\n💰 السعر: 300 جنيه\n\n👇 اضغط للحجز',
        urgency: 'High',
        showSos: false,
        services: ['Post-Op Care'],
        serviceRoutes: [
          TriageServiceRoute(
            route: 'post_op_care',
            title: 'Post-Op Care',
            price: '300 EGP',
            duration: '45-60 min',
            icon: 'monitor_heart',
            color: '0xFF10B981',
          ),
        ],
        source: 'fallback',
      );
    }

    // Default response
    return TriageResponse(
      response:
          'شكراً على رسالتك! 😊\n\nممكن تحكيلي أكتر عن اللي بتحس بيه عشان أقدر أساعدك أحسن.\n\nمثلاً:\n• عندك جرح محتاج ضمادة؟\n• محتاج حقنة في البيت؟\n• محتاج رعاية لكبير في السن؟',
      urgency: null,
      showSos: false,
      services: [],
      serviceRoutes: [],
      source: 'fallback',
    );
  }
}
