import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/triage_service.dart';
import '../../../customer/services/presentation/pages/service_details_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Design System
// ═══════════════════════════════════════════════════════════════════════════════
class _ChatDesign {
  // Colors
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color primaryLight = Color(0xFF58D68D);

  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color userBubble = Color(0xFF2ECC71);
  static const Color botBubble = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);

  static const Color emergency = Color(0xFFE53E3E);
  static const Color emergencyLight = Color(0xFFFED7D7);
  static const Color warning = Color(0xFFED8936);
  static const Color warningLight = Color(0xFFFEEBC8);
  static const Color info = Color(0xFF3182CE);
  static const Color success = Color(0xFF38A169);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get messageShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// Chatbot Page
// ═══════════════════════════════════════════════════════════════════════════════
class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final TriageService _triageService = TriageService();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _inputFocus = FocusNode();

  bool _isTyping = false;
  bool _isAnalyzingImage = false;

  late AnimationController _typingAnimController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _addWelcomeMessage();
  }

  void _initAnimations() {
    _typingAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text:
            'أهلاً بيك! 👋\n\nأنا المساعد الذكي بتاع Housepital.\n\nإزيك؟ قولي بتحس بإيه أو ابعتلي صورة وأنا هساعدك تلاقي الخدمة المناسبة. 📸',
        isBot: true,
        time: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Message Handling
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(
        ChatMessage(text: text, isBot: false, time: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
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
              text: 'عذراً، حدث خطأ. حاول مرة تانية. 🔄',
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _showImageSourceDialog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerSheet(),
    );
  }

  Widget _buildImagePickerSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _ChatDesign.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: _ChatDesign.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إضافة صورة للتحليل',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _ChatDesign.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ابعتلي صورة للإصابة وهحللها وأقولك الخدمة المناسبة',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Options
          Row(
            children: [
              Expanded(
                child: _buildImageOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  subtitle: 'التقط صورة',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageOption(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  subtitle: 'اختر صورة',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: _ChatDesign.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _ChatDesign.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _ChatDesign.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: _ChatDesign.primary),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _ChatDesign.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

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

  // ═══════════════════════════════════════════════════════════════════════════
  // Build Methods
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ChatDesign.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildQuickActions(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: _ChatDesign.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x302ECC71),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: _ChatDesign.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المساعد الذكي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF90EE90),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'متصل الآن • يرد فوراً',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isBot = message.isBot;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot Avatar
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                color: _ChatDesign.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: _ChatDesign.primary,
                size: 18,
              ),
            ),
          ],

          // Message Content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                // Urgency Badge
                if (message.urgency != null) ...[
                  _buildUrgencyBadge(message.urgency!),
                  const SizedBox(height: 6),
                ],

                // Image
                if (message.hasImage) ...[
                  _buildImagePreview(message.imagePath!),
                  const SizedBox(height: 8),
                ],

                // Message Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isBot
                            ? (message.showSos
                                ? _ChatDesign.emergencyLight
                                : _ChatDesign.botBubble)
                            : _ChatDesign.userBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isBot ? 6 : 20),
                      bottomRight: Radius.circular(isBot ? 20 : 6),
                    ),
                    border:
                        message.showSos
                            ? Border.all(
                              color: _ChatDesign.emergency,
                              width: 1.5,
                            )
                            : null,
                    boxShadow: _ChatDesign.messageShadow,
                  ),
                  child: Text(
                    message.text,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isBot ? _ChatDesign.textPrimary : Colors.white,
                    ),
                  ),
                ),

                // SOS Button
                if (message.showSos) ...[
                  const SizedBox(height: 12),
                  _buildSosButton(),
                ],

                // Service Buttons
                if (message.serviceRoutes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...message.serviceRoutes
                      .map((s) => _buildServiceCard(s))
                      .toList(),
                ],

                // Time
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.time),
                  style: const TextStyle(
                    fontSize: 11,
                    color: _ChatDesign.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // User spacing
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _ChatDesign.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: 200,
                height: 150,
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge(String urgency) {
    Color color;
    String text;
    IconData icon;

    switch (urgency) {
      case 'Emergency':
        color = _ChatDesign.emergency;
        text = '🚨 طوارئ';
        icon = Icons.warning_rounded;
        break;
      case 'High':
        color = _ChatDesign.warning;
        text = '⚠️ أولوية عالية';
        icon = Icons.priority_high_rounded;
        break;
      case 'Medium':
        color = Colors.amber;
        text = 'متوسط';
        icon = Icons.info_outline_rounded;
        break;
      case 'Low':
        color = _ChatDesign.success;
        text = '✓ بسيط';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton() {
    return GestureDetector(
      onTap: _showEmergencyDialog,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: _ChatDesign.emergencyGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _ChatDesign.emergency.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
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

  void _showEmergencyDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _ChatDesign.emergencyLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: _ChatDesign.emergency,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'حالة طوارئ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'اتصل بالإسعاف فوراً!\n\n📞 رقم الطوارئ: 123',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.call, size: 20),
                label: const Text('اتصل الآن'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ChatDesign.emergency,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildServiceCard(TriageServiceRoute service) {
    final iconColor = Color(int.parse(service.color));

    return GestureDetector(
      onTap: () => _navigateToService(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.25)),
          boxShadow: _ChatDesign.messageShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(service.icon),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _ChatDesign.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.price,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        service.duration,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _ChatDesign.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: _ChatDesign.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: _ChatDesign.primary,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: _ChatDesign.messageShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) => _buildAnimatedDot(index)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimController,
      builder: (context, child) {
        final value = (_typingAnimController.value * 3 - index).clamp(0.0, 1.0);
        final scale = 0.5 + (0.5 * (1 - (value - 0.5).abs() * 2));

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _ChatDesign.primary.withOpacity(0.3 + (scale * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('🩹 عندي جرح', Icons.healing_rounded),
      ('💉 محتاج حقنة', Icons.medication_rounded),
      ('👴 رعاية كبار', Icons.elderly_rounded),
      ('📷 ابعت صورة', Icons.camera_alt_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children:
              actions.map((action) {
                final isCamera = action.$2 == Icons.camera_alt_rounded;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      if (isCamera) {
                        _showImageSourceDialog();
                      } else {
                        _sendMessage(action.$1);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isCamera
                                ? _ChatDesign.primary.withOpacity(0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isCamera
                                  ? _ChatDesign.primary
                                  : _ChatDesign.primary.withOpacity(0.25),
                        ),
                        boxShadow: isCamera ? null : _ChatDesign.messageShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.$2, size: 18, color: _ChatDesign.primary),
                          const SizedBox(width: 8),
                          Text(
                            action.$1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isCamera
                                      ? _ChatDesign.primary
                                      : _ChatDesign.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Camera Button
          GestureDetector(
            onTap: _isAnalyzingImage ? null : _showImageSourceDialog,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    _isAnalyzingImage
                        ? Colors.grey[200]
                        : _ChatDesign.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: _isAnalyzingImage ? Colors.grey : _ChatDesign.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _ChatDesign.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _inputFocus,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  hintTextDirection: TextDirection.rtl,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _ChatDesign.headerGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _ChatDesign.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════════════
  void _navigateToService(TriageServiceRoute service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceDetailsPage(
              title: service.title,
              price: service.price,
              duration: service.duration,
              icon: _getIconData(service.icon),
              iconColor: Color(int.parse(service.color)),
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Chat Message Model
// ═══════════════════════════════════════════════════════════════════════════════
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
