import 'package:flutter/material.dart';
import '../../../services/presentation/pages/service_details_page.dart';
import '../pages/all_nursing_services_page.dart';

class PopularServicesGrid extends StatelessWidget {
  const PopularServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D47F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Color(0xFF00B870),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Popular Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllNursingServicesPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00B870),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF00B870),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.88,
          children: [
            ServiceCard(
              icon: Icons.healing_rounded,
              iconColor: const Color(0xFFEF4444),
              bgGradient: const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
              title: 'Wound Care',
              price: '150 EGP',
              rating: 4.9,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailsPage(
                            title: 'Wound Care',
                            price: '150 EGP',
                            duration: '30-45 min',
                            icon: Icons.healing,
                            iconColor: Color(0xFFEF4444),
                            description:
                                'Professional wound care and dressing services provided by certified nurses. We ensure proper wound cleaning, medication application, and regular monitoring to promote faster healing and prevent infections.',
                            includes: [
                              'Professional wound assessment',
                              'Sterile dressing and bandaging',
                              'Wound cleaning and medication',
                              'Regular follow-up visits',
                              'Progress monitoring and reporting',
                            ],
                          ),
                    ),
                  ),
            ),
            ServiceCard(
              icon: Icons.medication_liquid_rounded,
              iconColor: const Color(0xFF3B82F6),
              bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              title: 'Injections',
              price: '50 EGP',
              rating: 4.8,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailsPage(
                            title: 'Injections',
                            price: '50 EGP',
                            duration: '15-20 min',
                            icon: Icons.medication_liquid,
                            iconColor: Color(0xFF3B82F6),
                            description:
                                'Safe and painless injection services at your home. Our trained nurses administer all types of injections including IV, IM, and subcutaneous injections with proper sterilization and care.',
                            includes: [
                              'All types of injections (IV, IM, SC)',
                              'Proper sterilization',
                              'Medication administration',
                              'Post-injection care instructions',
                              'Emergency support if needed',
                            ],
                          ),
                    ),
                  ),
            ),
            ServiceCard(
              icon: Icons.elderly_rounded,
              iconColor: const Color(0xFF8B5CF6),
              bgGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
              title: 'Elderly Care',
              price: '200 EGP/hr',
              rating: 4.9,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailsPage(
                            title: 'Elderly Care',
                            price: '200 EGP/hr',
                            duration: '1-4 hours',
                            icon: Icons.elderly,
                            iconColor: Color(0xFF8B5CF6),
                            description:
                                'Comprehensive care for elderly patients including assistance with daily activities, medication management, vital signs monitoring, and companionship. Our nurses are specially trained in geriatric care.',
                            includes: [
                              'Daily activity assistance',
                              'Medication management',
                              'Vital signs monitoring',
                              'Personal hygiene care',
                              'Companionship and emotional support',
                            ],
                          ),
                    ),
                  ),
            ),
            ServiceCard(
              icon: Icons.monitor_heart_rounded,
              iconColor: const Color(0xFF10B981),
              bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              title: 'Post-Op Care',
              price: '300 EGP',
              rating: 4.7,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ServiceDetailsPage(
                            title: 'Post-Op Care',
                            price: '300 EGP',
                            duration: '45-60 min',
                            icon: Icons.monitor_heart,
                            iconColor: Color(0xFF10B981),
                            description:
                                'Post-operative care services to ensure smooth recovery after surgery. Includes wound care, medication administration, pain management, and monitoring for complications.',
                            includes: [
                              'Surgical wound care',
                              'Pain management',
                              'Medication administration',
                              'Vital signs monitoring',
                              'Complication detection and reporting',
                            ],
                          ),
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class ServiceCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final List<Color> bgGradient;
  final String title;
  final String price;
  final double rating;
  final VoidCallback? onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.bgGradient,
    required this.title,
    required this.price,
    required this.rating,
    this.onTap,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.iconColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.bgGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 26),
                  ),
                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.rating.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Professional service',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D47F), Color(0xFF00B870)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D47F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.price,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
