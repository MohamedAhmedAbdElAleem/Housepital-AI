import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/constants/app_colors.dart';

class RechargeSheet extends StatefulWidget {
  final List<dynamic> methods;
  final String baseUrl;
  final Map<String, String> authHeaders;
  final VoidCallback onSuccess;

  const RechargeSheet({
    super.key,
    required this.methods,
    required this.baseUrl,
    required this.authHeaders,
    required this.onSuccess,
  });

  @override
  State<RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<RechargeSheet> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'instapay';
  File? _receiptFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Receipt Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _PickOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                const SizedBox(width: 16),
                _PickOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
    if (source == null) return;
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _receiptFile = File(picked.path));
  }

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    
    if (amount == null || amount < 10) {
      _showError('Enter a valid amount (Min 10 EGP)');
      return;
    }
    if (_receiptFile == null) {
      _showError('Please upload your transfer receipt');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final bytes = await _receiptFile!.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      final resp = await http.post(
        Uri.parse('${widget.baseUrl}/api/wallet/submit-receipt'),
        headers: widget.authHeaders,
        body: jsonEncode({
          'amount': amount,
          'paymentMethod': _selectedMethod,
          'receiptBase64': base64Str,
        }),
      );

      if (!mounted) return;
      final body = jsonDecode(resp.body);
      
      if (resp.statusCode == 201 || resp.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Receipt submitted for review!'),
            backgroundColor: const Color(0xFF2ECC71),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSuccess();
      } else {
        setState(() => _isSubmitting = false);
        _showError(body['message'] ?? 'Failed to submit receipt');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showError('Connection error. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: AppColors.primary500,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final methodData = widget.methods.firstWhere(
      (m) => m['method'] == _selectedMethod,
      orElse: () => null,
    );

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recharge Wallet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              'Transfer the amount first, then upload the receipt below.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            // Method Selection
            Row(
              children: [
                _MethodTab(
                  label: 'Instapay',
                  isSelected: _selectedMethod == 'instapay',
                  onTap: () => setState(() => _selectedMethod = 'instapay'),
                ),
                const SizedBox(width: 12),
                _MethodTab(
                  label: 'Mobile Wallet',
                  isSelected: _selectedMethod == 'mobile_wallet',
                  onTap: () => setState(() => _selectedMethod = 'mobile_wallet'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Payment Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E3A8A).withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF1E3A8A)),
                      const SizedBox(width: 8),
                      const Text(
                        'Transfer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Account Name', 
                    value: methodData?['receiverName'] ?? 'Housepital Care',
                    onCopy: () => _copyToClipboard(methodData?['receiverName'] ?? 'Housepital Care', 'Account Name'),
                  ),
                  _DetailRow(
                    label: 'Phone Number', 
                    value: methodData?['phoneNumber'] ?? '0123456789',
                    onCopy: () => _copyToClipboard(methodData?['phoneNumber'] ?? '0123456789', 'Phone Number'),
                  ),
                  if (methodData?['link'] != null)
                    _DetailRow(
                      label: 'Instapay Link', 
                      value: methodData!['link'], 
                      isCopyable: true,
                      onCopy: () => _copyToClipboard(methodData!['link'], 'Instapay Link'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Amount (EGP)',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.withValues(alpha: 0.03),
              ),
            ),
            const SizedBox(height: 16),
            
            // Receipt Upload
            GestureDetector(
              onTap: _pickReceipt,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _receiptFile != null ? const Color(0xFF2ECC71) : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  color: _receiptFile != null ? const Color(0xFF2ECC71).withValues(alpha: 0.05) : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      _receiptFile != null ? Icons.check_circle_rounded : Icons.add_a_photo_outlined,
                      size: 40,
                      color: _receiptFile != null ? const Color(0xFF2ECC71) : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _receiptFile != null ? 'Receipt Selected' : 'Upload Transfer Receipt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _receiptFile != null ? const Color(0xFF2ECC71) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCopyable;
  final VoidCallback onCopy;

  const _DetailRow({
    required this.label, 
    required this.value, 
    this.isCopyable = false,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF1E3A8A)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF1E3A8A)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
