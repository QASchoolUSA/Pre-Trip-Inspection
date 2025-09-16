import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n/app_localizations.dart';

class DefectReportingPage extends ConsumerWidget {
  final String inspectionId;
  final String itemId;
  
  const DefectReportingPage({
    super.key,
    required this.inspectionId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportDefect),
      ),
      body: Center(
        child: Text(l10n.defectReportingForItem(itemId)),
      ),
    );
  }
}