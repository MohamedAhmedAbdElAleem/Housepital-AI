import 'package:flutter/material.dart';

class GreetingSearchCard extends StatefulWidget {
  final String? userName;

  const GreetingSearchCard({super.key, this.userName});

  @override
  State<GreetingSearchCard> createState() => _GreetingSearchCardState();
}

class _GreetingSearchCardState extends State<GreetingSearchCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.userName != null && widget.userName!.isNotEmpty
              ? 'Hi, ${widget.userName!.split(' ').first.toUpperCase()} 👋'
              : 'Hi there 👋',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'What do you need today?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            focusNode: _focusNode,
            autofocus: false,
            enableInteractiveSelection: true,
            onTap: () {
              _focusNode.requestFocus();
            },
            decoration: InputDecoration(
              hintText: 'Search nursing services…',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
