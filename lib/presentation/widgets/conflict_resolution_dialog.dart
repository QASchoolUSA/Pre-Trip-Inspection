import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_models.dart';
import '../../core/services/conflict_resolution_service.dart';

/// Dialog for resolving sync conflicts
class ConflictResolutionDialog extends ConsumerStatefulWidget {
  final SyncConflict conflict;
  final VoidCallback? onResolved;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    this.onResolved,
  });

  @override
  ConsumerState<ConflictResolutionDialog> createState() => _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends ConsumerState<ConflictResolutionDialog> {
  ConflictResolution? _selectedResolution;
  bool _isResolving = false;
  Map<String, dynamic>? _mergedData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Text('Sync Conflict - ${widget.conflict.entityType}'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A conflict was detected for ${widget.conflict.entityType} with ID: ${widget.conflict.entityId}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Conflict occurred at: ${_formatDateTime(widget.conflict.detectedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildResolutionOptions(),
            if (_selectedResolution == ConflictResolution.merge) ...[
              const SizedBox(height: 16),
              _buildMergeInterface(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isResolving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedResolution == null || _isResolving
              ? null
              : _resolveConflict,
          child: _isResolving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Resolve'),
        ),
      ],
    );
  }

  Widget _buildResolutionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose resolution strategy:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _buildResolutionOption(
          ConflictResolution.useLocal,
          'Use Local Version',
          'Keep the local changes and overwrite server data',
          Icons.phone_android,
        ),
        _buildResolutionOption(
          ConflictResolution.useServer,
          'Use Server Version',
          'Discard local changes and use server data',
          Icons.cloud,
        ),
        _buildResolutionOption(
          ConflictResolution.merge,
          'Merge Changes',
          'Combine local and server changes manually',
          Icons.merge,
        ),
        _buildResolutionOption(
          ConflictResolution.createNew,
          'Create New Entry',
          'Keep both versions as separate entries',
          Icons.add_circle_outline,
        ),
      ],
    );
  }

  Widget _buildResolutionOption(
    ConflictResolution resolution,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedResolution == resolution;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedResolution = resolution),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<ConflictResolution>(
                value: resolution,
                groupValue: _selectedResolution,
                onChanged: (value) => setState(() => _selectedResolution = value),
              ),
              Icon(icon, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMergeInterface() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merge Data',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Review and edit the merged data below:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _buildDataComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataComparison() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDataSection(
                'Local Data',
                widget.conflict.localData,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDataSection(
                'Server Data',
                widget.conflict.serverData,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMergedDataSection(),
      ],
    );
  }

  Widget _buildDataSection(String title, Map<String, dynamic> data, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMergedDataSection() {
    _mergedData ??= Map<String, dynamic>.from(widget.conflict.localData);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              'Merged Data (Editable)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.purple,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: _mergedData!.entries
                  .map((entry) => _buildEditableField(entry.key, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$key:',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextFormField(
              initialValue: value.toString(),
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  _mergedData![key] = newValue;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveConflict() async {
    if (_selectedResolution == null) return;

    setState(() => _isResolving = true);

    try {
      await ConflictResolutionService.instance.resolveConflict(
        widget.conflict.id,
        _selectedResolution!,
        mergedData: _selectedResolution == ConflictResolution.merge ? _mergedData : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onResolved?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conflict resolved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resolve conflict: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Helper function to show conflict resolution dialog
Future<void> showConflictResolutionDialog(
  BuildContext context,
  SyncConflict conflict, {
  VoidCallback? onResolved,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ConflictResolutionDialog(
      conflict: conflict,
      onResolved: onResolved,
    ),
  );
}