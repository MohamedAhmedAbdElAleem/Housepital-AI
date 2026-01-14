import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/triage_service.dart';
import '../../../customer/services/presentation/pages/service_details_page.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final TriageService _triageService = TriageService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isTyping = false;
  bool _isAnalyzingImage = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text:
            'أهلاً بيك! 👋\n\nأنا المساعد الذكي بتاع Housepital.\n\nإزيك؟ بتحس بإيه النهارده؟ قولي أو ابعتلي صورة وأنا هساعدك تلاقي الخدمة المناسبة. 📸',
        isBot: true,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isBot: false, time: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Call the triage service
      final response = await _triageService.chat(text);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: response.response,
              isBot: true,
              time: DateTime.now(),
              urgency: response.urgency,
              showSos: response.showSos,
              serviceRoutes: response.serviceRoutes,
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: 'عذراً، حدث خطأ. حاول مرة تانية.',
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  /// Show image source picker dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'إضافة صورة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'الكاميرا',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.photo_library_rounded,
                      label: 'المعرض',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary500.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 30, color: AppColors.primary500),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  /// Pick and analyze image
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        // Add image message
        _messages.add(
          ChatMessage(
            text: '📷 جاري تحليل الصورة...',
            isBot: false,
            time: DateTime.now(),
            imagePath: pickedFile.path,
          ),
        );
        _isAnalyzingImage = true;
        _isTyping = true;
      });
      _scrollToBottom();

      // Analyze the image
      final response = await _triageService.analyzeImage(pickedFile.path);

      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: response.response,
              isBot: true,
              time: DateTime.now(),
              urgency: response.urgency,
              showSos: response.showSos,
              serviceRoutes: response.serviceRoutes,
            ),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzingImage = false;
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text:
                  '⚠️ حصل مشكلة في تحليل الصورة. ممكن توصفلي الإصابة بالكتابة؟',
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _navigateToService(TriageServiceRoute service) {
    final iconData = _getIconData(service.icon);
    final iconColor = Color(int.parse(service.color));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceDetailsPage(
              title: service.title,
              price: service.price,
              duration: service.duration,
              icon: iconData,
              iconColor: iconColor,
              description:
                  service.description ?? _getServiceDescription(service.route),
              includes: _getServiceIncludes(service.route),
            ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'healing':
        return Icons.healing_rounded;
      case 'medication_liquid':
        return Icons.medication_liquid_rounded;
      case 'elderly':
        return Icons.elderly_rounded;
      case 'monitor_heart':
        return Icons.monitor_heart_rounded;
      case 'child_care':
        return Icons.child_care_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  String _getServiceDescription(String route) {
    switch (route) {
      case 'wound_care':
        return 'Professional wound care and dressing services provided by certified nurses.';
      case 'injections':
        return 'Safe and painless injection services at your home.';
      case 'elderly_care':
        return 'Comprehensive care for elderly patients including daily activities assistance.';
      case 'post_op_care':
        return 'Post-operative care services to ensure smooth recovery after surgery.';
      default:
        return 'Professional healthcare service provided by our certified nurses.';
    }
  }

  List<String> _getServiceIncludes(String route) {
    switch (route) {
      case 'wound_care':
        return [
          'Wound assessment',
          'Sterile dressing',
          'Wound cleaning',
          'Follow-up visits',
        ];
      case 'injections':
        return [
          'All types of injections',
          'Proper sterilization',
          'Post-injection care',
        ];
      case 'elderly_care':
        return [
          'Daily activity assistance',
          'Medication management',
          'Vital signs monitoring',
        ];
      case 'post_op_care':
        return [
          'Surgical wound care',
          'Pain management',
          'Vital signs monitoring',
        ];
      default:
        return ['Professional service', 'Certified nurses', 'Home visit'];
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.primary500,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.support_agent, color: Colors.white, size: 22),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المساعد الذكي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'متصل الآن',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAction('🩹 عندي جرح'),
                  _buildQuickAction('💉 محتاج حقنة'),
                  _buildQuickAction('👴 رعاية كبار'),
                  _buildQuickAction('💰 الأسعار'),
                ],
              ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Camera button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color:
                            _isAnalyzingImage
                                ? Colors.grey
                                : AppColors.primary500,
                      ),
                      onPressed:
                          _isAnalyzingImage ? null : _showImageSourceDialog,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالتك أو ابعت صورة...',
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment:
              message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Urgency badge
            if (message.urgency != null) _buildUrgencyBadge(message.urgency!),

            // Image if present
            if (message.hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(message.imagePath!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    message.isBot
                        ? (message.showSos
                            ? const Color(0xFFFEE2E2)
                            : Colors.white)
                        : AppColors.primary500,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isBot ? 4 : 20),
                  bottomRight: Radius.circular(message.isBot ? 20 : 4),
                ),
                border:
                    message.showSos
                        ? Border.all(color: Colors.red.shade300, width: 2)
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: message.isBot ? Colors.black87 : Colors.white,
                ),
              ),
            ),

            // SOS button for emergencies
            if (message.showSos) ...[
              const SizedBox(height: 12),
              _buildSosButton(),
            ],

            // Service recommendation buttons
            if (message.serviceRoutes.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...message.serviceRoutes.map(
                (service) => _buildServiceButton(service),
              ),
            ],

            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isBot)
                  const Icon(Icons.smart_toy, size: 12, color: Colors.grey),
                if (message.isBot) const SizedBox(width: 4),
                Text(
                  _formatTime(message.time),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color badgeColor;
    String text;
    IconData icon;

    switch (urgency) {
      case 'Emergency':
        badgeColor = Colors.red;
        text = 'طوارئ';
        icon = Icons.warning_amber_rounded;
        break;
      case 'High':
        badgeColor = Colors.orange;
        text = 'أولوية عالية';
        icon = Icons.priority_high_rounded;
        break;
      case 'Medium':
        badgeColor = Colors.amber;
        text = 'متوسط';
        icon = Icons.info_outline_rounded;
        break;
      case 'Low':
        badgeColor = Colors.green;
        text = 'بسيط';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.emergency, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حالة طوارئ'),
                  ],
                ),
                content: const Text(
                  'اتصل بالإسعاف فوراً!\n\nرقم الطوارئ: 123',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.call),
                    label: const Text('اتصل الآن'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'اتصل بالطوارئ - 123',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(TriageServiceRoute service) {
    final iconColor = Color(int.parse(service.color));

    return GestureDetector(
      onTap: () => _navigateToService(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconData(service.icon),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.price} • ${service.duration}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'احجز',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [_buildDot(0), _buildDot(1), _buildDot(2)],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildQuickAction(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary500.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime time;
  final String? urgency;
  final bool showSos;
  final List<TriageServiceRoute> serviceRoutes;
  final String? imagePath;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.time,
    this.urgency,
    this.showSos = false,
    this.serviceRoutes = const [],
    this.imagePath,
  });

  bool get hasImage => imagePath != null;
}
