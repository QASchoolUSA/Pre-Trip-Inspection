import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/themes/app_theme.dart';

/// Floating voice-call button that overlays all pages
class TripAssistantButton extends StatelessWidget {
  final String phoneNumber;
  final bool mini;

  const TripAssistantButton({
    super.key,
    this.phoneNumber = '+18001234567',
    this.mini = false,
  });

  Future<void> _callOperator(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    final canCall = await canLaunchUrl(uri);
    if (canCall) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start a call on this device')),
      );
    }
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.support_agent, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Text(
                    'Trip Assistant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Voice call with an operator. Get help in real time.',
                style: TextStyle(color: AppColors.grey700),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _callOperator(context),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Operator'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: Semantics(
            label: 'Trip Assistant',
            button: true,
            child: FloatingActionButton.extended(
              onPressed: () => _openSheet(context),
              icon: const Icon(Icons.support_agent),
              label: const Text('Trip Assistant'),
              backgroundColor: AppColors.secondaryOrange,
              foregroundColor: AppColors.white,
              elevation: 6,
              extendedPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      ),
    );
  }
}