import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_models.dart';
import '../providers/app_providers.dart';

/// Widget to display sync status and statistics
class SyncStatusWidget extends ConsumerWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);
    final syncBatchAsync = ref.watch(syncBatchProvider);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sync,
                    color: _getSyncStatusColor(syncStatusAsync, syncBatchAsync),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sync Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  _buildSyncIndicator(syncStatusAsync, syncBatchAsync),
                ],
              ),
              if (showDetails) ...[
                const SizedBox(height: 16),
                _buildSyncDetails(context, syncStatusAsync),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncIndicator(
    AsyncValue<SyncStats> syncStatusAsync,
    AsyncValue<SyncBatch> syncBatchAsync,
  ) {
    return syncBatchAsync.when(
      data: (batch) {
        if (batch.status == SyncBatchStatus.running) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: batch.totalEntities > 0
                      ? batch.processedEntities / batch.totalEntities
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${batch.processedEntities}/${batch.totalEntities}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }
        return _buildStatusChip(batch.status);
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error, color: Colors.red, size: 16),
    );
  }

  Widget _buildStatusChip(SyncBatchStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case SyncBatchStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case SyncBatchStatus.completed:
        color = Colors.green;
        text = 'Synced';
        break;
      case SyncBatchStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
      case SyncBatchStatus.running:
        color = Colors.blue;
        text = 'Syncing';
        break;
      case SyncBatchStatus.cancelled:
        color = Colors.grey;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSyncDetails(BuildContext context, AsyncValue<SyncStats> syncStatusAsync) {
    return syncStatusAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow('Total Entities', stats.totalEntities.toString()),
          _buildStatRow('Synced', stats.syncedEntities.toString()),
          if (stats.pendingEntities > 0)
            _buildStatRow('Pending', stats.pendingEntities.toString(), Colors.orange),
          if (stats.failedEntities > 0)
            _buildStatRow('Failed', stats.failedEntities.toString(), Colors.red),
          if (stats.conflictedEntities > 0)
            _buildStatRow('Conflicts', stats.conflictedEntities.toString(), Colors.purple),
          if (stats.lastSyncAt != null)
            _buildStatRow(
              'Last Sync',
              _formatDateTime(stats.lastSyncAt!),
            ),
          const SizedBox(height: 8),
          _buildEntityTypeCounts(stats.entityTypeCounts),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        'Error loading sync stats: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityTypeCounts(Map<String, int> entityTypeCounts) {
    if (entityTypeCounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entity Types:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        ...entityTypeCounts.entries.map(
          (entry) => _buildStatRow(entry.key, entry.value.toString()),
        ),
      ],
    );
  }

  Color _getSyncStatusColor(
    AsyncValue<SyncStats> syncStatusAsync,
    AsyncValue<SyncBatch> syncBatchAsync,
  ) {
    return syncBatchAsync.when(
      data: (batch) {
        switch (batch.status) {
          case SyncBatchStatus.pending:
            return Colors.orange;
          case SyncBatchStatus.completed:
            return Colors.green;
          case SyncBatchStatus.failed:
            return Colors.red;
          case SyncBatchStatus.running:
            return Colors.blue;
          case SyncBatchStatus.cancelled:
            return Colors.grey;
        }
      },
      loading: () => Colors.grey,
      error: (_, __) => Colors.red,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Compact sync status indicator for app bars
class SyncStatusIndicator extends ConsumerWidget {
  final VoidCallback? onTap;

  const SyncStatusIndicator({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncBatchAsync = ref.watch(syncBatchProvider);

    return IconButton(
      onPressed: onTap,
      icon: syncBatchAsync.when(
        data: (batch) {
          switch (batch.status) {
            case SyncBatchStatus.pending:
              return const Icon(Icons.cloud_queue, color: Colors.orange);
            case SyncBatchStatus.running:
              return const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            case SyncBatchStatus.completed:
              return const Icon(Icons.cloud_done, color: Colors.green);
            case SyncBatchStatus.failed:
              return const Icon(Icons.cloud_off, color: Colors.red);
            case SyncBatchStatus.cancelled:
              return const Icon(Icons.cloud_off, color: Colors.grey);
          }
        },
        loading: () => const Icon(Icons.cloud_sync, color: Colors.grey),
        error: (_, __) => const Icon(Icons.cloud_off, color: Colors.red),
      ),
    );
  }
}