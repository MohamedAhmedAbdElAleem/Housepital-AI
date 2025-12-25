import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        text:
            'أهلاً بيك! 👋\n\nأنا المساعد الذكي بتاع Housepital.\n\nإزيك؟ بتحس بإيه النهارده؟ قولي وأنا هساعدك تلاقي الخدمة المناسبة.',
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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isBot: false, time: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: _getAIResponse(text),
              isBot: true,
              time: DateTime.now(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('جرح') ||
        message.contains('wound') ||
        message.contains('ضمادة')) {
      return '🩹 فاهم إنك محتاج رعاية جرح.\n\nانصحك بخدمة "العناية بالجروح" - ممرضة متخصصة هتيجي البيت وتغير الضمادة.\n\n💰 السعر: 150 جنيه\n⏱ المدة: 30-45 دقيقة\n\nعايز تحجز دلوقتي؟';
    }

    if (message.contains('حقنة') ||
        message.contains('injection') ||
        message.contains('ابرة')) {
      return '💉 محتاج حقنة؟\n\nعندنا خدمة الحقن في البيت - ممرضة محترفة هتيجي تديك الحقنة بأمان.\n\n💰 السعر: 50 جنيه\n⏱ المدة: 15-20 دقيقة\n\nعايز تحجز؟';
    }

    if (message.contains('كبير') ||
        message.contains('elderly') ||
        message.contains('والدي') ||
        message.contains('والدتي')) {
      return '👴 رعاية كبار السن مهمة جداً.\n\nعندنا ممرضات متخصصات في رعاية كبار السن:\n• المساعدة في الأنشطة اليومية\n• متابعة الأدوية\n• قياس الضغط والسكر\n\n💰 السعر: 200 جنيه/ساعة\n\nإزاي أقدر أساعدك؟';
    }

    if (message.contains('عملية') ||
        message.contains('surgery') ||
        message.contains('جراحة')) {
      return '🏥 الرعاية بعد العمليات مهمة جداً للتعافي.\n\nخدمة "رعاية ما بعد العمليات" تشمل:\n• العناية بالجرح\n• متابعة الأدوية\n• مراقبة العلامات الحيوية\n\n💰 السعر: 300 جنيه\n\nمحتاج تحجز موعد؟';
    }

    if (message.contains('حجز') ||
        message.contains('book') ||
        message.contains('موعد')) {
      return '📅 تمام! هحولك لصفحة الحجز.\n\nاختار الخدمة اللي محتاجها وحدد الموعد المناسب ليك.\n\n[اضغط على أي خدمة من الصفحة الرئيسية للحجز]';
    }

    if (message.contains('سعر') ||
        message.contains('price') ||
        message.contains('كام')) {
      return '💰 أسعارنا:\n\n• العناية بالجروح: 150 جنيه\n• الحقن: 50 جنيه\n• رعاية كبار السن: 200 جنيه/ساعة\n• رعاية ما بعد العمليات: 300 جنيه\n\nكل الأسعار شاملة الزيارة المنزلية! 🏠';
    }

    return 'شكراً على رسالتك! 😊\n\nممكن تحكيلي أكتر عن اللي بتحس بيه عشان أقدر أساعدك أحسن.\n\nمثلاً:\n• عندك جرح محتاج ضمادة؟\n• محتاج حقنة في البيت؟\n• محتاج حد يرعى كبير في السن؟';
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
                          hintText: 'اكتب رسالتك هنا...',
                          hintTextDirection: TextDirection.rtl,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment:
              message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isBot ? Colors.white : AppColors.primary500,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isBot ? 4 : 20),
                  bottomRight: Radius.circular(message.isBot ? 20 : 4),
                ),
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

  ChatMessage({required this.text, required this.isBot, required this.time});
}
