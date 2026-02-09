import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy widget stub.
class ConflictResolutionDialog extends ConsumerWidget {
  final dynamic conflict;
  final VoidCallback? onResolved;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    this.onResolved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

Future<void> showConflictResolutionDialog(
  BuildContext context,
  dynamic conflict, {
  VoidCallback? onResolved,
}) async {}