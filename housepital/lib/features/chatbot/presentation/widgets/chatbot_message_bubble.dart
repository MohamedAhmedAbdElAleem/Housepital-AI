import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/services/triage_service.dart';
import '../pages/chatbot_page.dart';

class ChatbotMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(TriageServiceRoute) onServiceTap;
  final VoidCallback onSosTap;

  const ChatbotMessageBubble({
    super.key,
    required this.message,
    required this.onServiceTap,
    required this.onSosTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot Avatar
          if (isBot) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10, bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Color(0xFF667EEA),
                size: 20,
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
                  const SizedBox(height: 8),
                ],

                // Image
                if (message.hasImage) ...[
                  _buildImagePreview(message.imagePath!),
                  const SizedBox(height: 8),
                ],

                // Message Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    gradient: !isBot
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    color: isBot
                        ? (message.showSos ? const Color(0xFFFED7D7) : Colors.white)
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isBot ? 8 : 24),
                      bottomRight: Radius.circular(isBot ? 24 : 8),
                    ),
                    border: message.showSos
                        ? Border.all(color: const Color(0xFFE53E3E), width: 1.5)
                        : (isBot ? Border.all(color: Colors.black.withAlpha(5)) : null),
                    boxShadow: [
                      BoxShadow(
                        color: (isBot ? Colors.black : const Color(0xFF764BA2)).withAlpha(isBot ? 10 : 50),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(isBot ? 8 : 24),
                      bottomRight: Radius.circular(isBot ? 24 : 8),
                    ),
                    child: Stack(
                      children: [
                        // Subtle Watermark Icon for Bot
                        if (isBot)
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              Icons.psychology_rounded,
                              size: 60,
                              color: Colors.black.withAlpha(5),
                            ),
                          ),
                        // Subtle Watermark Icon for User
                        if (!isBot)
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Colors.white.withAlpha(15),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Text(
                            message.text,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: isBot ? const Color(0xFF1A202C) : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SOS Button
                if (message.showSos) ...[
                  const SizedBox(height: 12),
                  _buildSosButton(onSosTap),
                ],

                // Service Buttons
                if (message.serviceRoutes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...message.serviceRoutes.map((s) => _buildServiceCard(s, onServiceTap)),
                ],
              ],
            ),
          ),
          
          if (!isBot) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String path) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
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
        color = const Color(0xFFE53E3E);
        text = '🚨 Emergency';
        icon = Icons.warning_rounded;
        break;
      case 'High':
        color = const Color(0xFFED8936);
        text = '⚠️ High Priority';
        icon = Icons.priority_high_rounded;
        break;
      case 'Medium':
        color = Colors.amber[700]!;
        text = 'Medium';
        icon = Icons.info_outline_rounded;
        break;
      case 'Low':
        color = const Color(0xFF38A169);
        text = '✓ Low Risk';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53E3E).withAlpha(80),
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
              'Call 123 Now',
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

  Widget _buildServiceCard(TriageServiceRoute service, Function(TriageServiceRoute) onTap) {
    final iconColor = Color(int.parse(service.color));

    return GestureDetector(
      onTap: () => onTap(service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withAlpha(40)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(service.icon), color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.price} • ${service.duration}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'healing': return Icons.healing_rounded;
      case 'medication_liquid': return Icons.medication_liquid_rounded;
      case 'elderly': return Icons.elderly_rounded;
      case 'monitor_heart': return Icons.monitor_heart_rounded;
      case 'child_care': return Icons.child_care_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      default: return Icons.medical_services_rounded;
    }
  }
}
