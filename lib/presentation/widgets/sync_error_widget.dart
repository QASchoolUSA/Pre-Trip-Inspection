import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Legacy widget stub. Firestore handles sync automatically.
class SyncErrorWidget extends ConsumerWidget {
  final dynamic error; // Typed dynamic to avoid missing type error
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  const SyncErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class SyncErrorsList extends ConsumerWidget {
  final List<dynamic> errors;
  final Function(dynamic)? onRetry;
  final Function(dynamic)? onDismiss;
  final bool showDetails;

  const SyncErrorsList({
    super.key,
    required this.errors,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class SyncErrorBanner extends ConsumerWidget {
  final List<dynamic> errors;
  final VoidCallback? onTap;

  const SyncErrorBanner({
    super.key,
    required this.errors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class SyncErrorBottomSheet extends ConsumerWidget {
  final List<dynamic> errors;

  const SyncErrorBottomSheet({
    super.key,
    required this.errors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

Future<void> showSyncErrorsBottomSheet(
  BuildContext context,
  List<dynamic> errors,
) async {}