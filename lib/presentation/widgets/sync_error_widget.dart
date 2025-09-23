import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_models.dart';
import '../providers/app_providers.dart';

/// Widget for displaying sync errors with retry options
class SyncErrorWidget extends ConsumerWidget {
  final SyncError error;
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
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getErrorIcon(),
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getErrorTitle(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onDismiss,
                    color: Colors.red.shade700,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade600,
              ),
            ),
            if (showDetails && error.details != null) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Error Details'),
                tilePadding: EdgeInsets.zero,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.details?.toString() ?? 'No details available',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Occurred: ${_formatDateTime(error.occurredAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade500,
                  ),
                ),
                const Spacer(),
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case SyncErrorType.networkError:
        return Icons.wifi_off;
      case SyncErrorType.authenticationError:
        return Icons.lock;
      case SyncErrorType.serverError:
        return Icons.error;
      case SyncErrorType.conflictError:
        return Icons.warning;
      case SyncErrorType.validationError:
        return Icons.error_outline;
      case SyncErrorType.unknownError:
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle() {
    switch (error.type) {
      case SyncErrorType.networkError:
        return 'Network Error';
      case SyncErrorType.authenticationError:
        return 'Authentication Error';
      case SyncErrorType.serverError:
        return 'Server Error';
      case SyncErrorType.conflictError:
        return 'Sync Conflict';
      case SyncErrorType.validationError:
        return 'Validation Error';
      case SyncErrorType.unknownError:
      default:
        return 'Sync Error';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget for displaying a list of sync errors
class SyncErrorsList extends ConsumerWidget {
  final List<SyncError> errors;
  final Function(SyncError)? onRetry;
  final Function(SyncError)? onDismiss;
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
    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Sync Errors (${errors.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (errors.length > 1)
                TextButton(
                  onPressed: () => _dismissAllErrors(ref),
                  child: const Text('Dismiss All'),
                ),
            ],
          ),
        ),
        ...errors.map((error) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SyncErrorWidget(
                error: error,
                onRetry: onRetry != null ? () => onRetry!(error) : null,
                onDismiss: onDismiss != null ? () => onDismiss!(error) : null,
                showDetails: showDetails,
              ),
            )),
      ],
    );
  }

  void _dismissAllErrors(WidgetRef ref) {
    if (onDismiss != null) {
      for (final error in errors) {
        onDismiss!(error);
      }
    }
  }
}

/// Compact error banner for app bar or bottom of screen
class SyncErrorBanner extends ConsumerWidget {
  final List<SyncError> errors;
  final VoidCallback? onTap;

  const SyncErrorBanner({
    super.key,
    required this.errors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (errors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.red.shade600,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.error,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errors.length == 1
                      ? 'Sync error: ${errors.first.message}'
                      : '${errors.length} sync errors occurred',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for displaying sync errors
class SyncErrorBottomSheet extends ConsumerWidget {
  final List<SyncError> errors;

  const SyncErrorBottomSheet({
    super.key,
    required this.errors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Sync Errors',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: SyncErrorsList(
                errors: errors,
                showDetails: true,
                onRetry: (error) => _retrySync(ref, error),
                onDismiss: (error) => _dismissError(ref, error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retrySync(WidgetRef ref, SyncError error) {
    // Trigger a retry for the specific operation that failed
    final syncService = ref.read(syncServiceProvider);
    // TODO: Implement retry logic when SyncService has retryFailedOperation method
  }

  void _dismissError(WidgetRef ref, SyncError error) {
    // Remove the error from the error list
    final errorNotifier = ref.read(errorProvider.notifier);
    // TODO: Implement dismiss logic when errorProvider has dismissError method
    errorNotifier.state = null;
  }
}

/// Helper function to show sync errors bottom sheet
Future<void> showSyncErrorsBottomSheet(
  BuildContext context,
  List<SyncError> errors,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SyncErrorBottomSheet(errors: errors),
  );
}