import 'package:flutter/material.dart';

class OfflineSyncPage extends StatelessWidget {
  const OfflineSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync'),
      ),
      body: const Center(
        child: Text('Offline Sync Page'),
      ),
    );
  }
}