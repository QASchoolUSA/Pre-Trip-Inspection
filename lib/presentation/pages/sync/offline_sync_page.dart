import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n/app_localizations.dart';

class OfflineSyncPage extends ConsumerWidget {
  const OfflineSyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.offlineSync),
      ),
      body: Center(
        child: Text(l10n.offlineSyncPageContent),
      ),
    );
  }
}