import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/triage_service.dart';
import '../../../customer/services/presentation/pages/service_details_page.dart';
import '../widgets/chatbot_header.dart';
import '../widgets/chatbot_input_area.dart';
import '../widgets/chatbot_quick_actions.dart';
import '../widgets/chatbot_message_bubble.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

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
            'Hello! 👋\n\nI am Housepital\'s AI Health Assistant.\n\nHow are you feeling today? You can describe your symptoms or upload a photo for analysis. 📸',
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
              text: 'Sorry, something went wrong. Please try again. 🔄',
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerSheet(),
    );

    if (source == null) return;

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
            text: '📷 Analyzing your image...',
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
                  '⚠️ I couldn\'t analyze the image. Can you describe the issue in text?',
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  Widget _buildImagePickerSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191919) : const Color(0xFFFDFDFD),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Add Photo for Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFFDFDFD) : const Color(0xFF232323),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withAlpha(isDark ? 40 : 20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF667EEA).withAlpha(isDark ? 80 : 40),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isDark ? const Color(0xFF764BA2) : const Color(0xFF667EEA),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isDark ? const Color(0xFFFDFDFD) : const Color(0xFF232323),
              ),
            ),
          ],
        ),
      ),
    );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Main Chat Area (Scrolls under header)
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 85 + MediaQuery.of(context).padding.top,
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: Container(
                        color: theme.scaffoldBackgroundColor,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            20,
                            16,
                            40,
                          ), // Adjusted padding
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          itemCount: _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _isTyping) {
                              return _buildTypingIndicator();
                            }
                            return ChatbotMessageBubble(
                              message: _messages[index],
                              onServiceTap: _navigateToService,
                              onSosTap: _showEmergencyDialog,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. The Canopy Header (Always on top for back button)
          const Positioned(top: 0, left: 0, right: 0, child: ChatbotHeader()),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChatbotQuickActions(
            onActionTap: (text, icon) => _sendMessage(text),
            onImageActionTap: _pickImage,
          ),
          ChatbotInputArea(
            controller: _messageController,
            focusNode: _inputFocus,
            onSubmitted: _sendMessage,
            onImagePick: _pickImage,
            isAnalyzing: _isAnalyzingImage,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF667EEA),
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int i) {
    return AnimatedBuilder(
      animation: _typingAnimController,
      builder: (context, child) {
        final val = (_typingAnimController.value * 3 - i).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withAlpha((100 + val * 155).toInt()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _navigateToService(TriageServiceRoute service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ServiceDetailsPage(
              title: service.title,
              serviceRoute: service.route,
              price: service.price,
              duration: service.duration,
              icon: _getIcon(service.icon),
              iconColor: Color(int.parse(service.color)),
              description:
                  service.description ?? 'Professional healthcare service.',
              includes: const ['Assessment', 'Professional Care', 'Follow-up'],
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
            title: const Text('Emergency'),
            content: const Text(
              'Please call emergency services immediately!\n\n📞 Emergency: 123',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
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
