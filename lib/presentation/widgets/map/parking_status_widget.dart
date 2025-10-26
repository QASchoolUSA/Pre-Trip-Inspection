import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/map_models.dart';

class ParkingStatusWidget extends StatefulWidget {
  final TruckLocation location;
  final ParkingStatusUpdate? latestStatus;
  final Function(ParkingStatus) onStatusUpdate;
  final bool isUpdating;

  const ParkingStatusWidget({
    super.key,
    required this.location,
    this.latestStatus,
    required this.onStatusUpdate,
    this.isUpdating = false,
  });

  @override
  State<ParkingStatusWidget> createState() => _ParkingStatusWidgetState();
}

class _ParkingStatusWidgetState extends State<ParkingStatusWidget> {
  ParkingStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_parking,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Parking Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current status display
            if (widget.latestStatus != null) ...[
              _buildCurrentStatus(),
              const SizedBox(height: 16),
            ],
            
            // Status update options
            Text(
              'Update Status:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildStatusOptions(),
            
            const SizedBox(height: 16),
            
            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedStatus != null && !widget.isUpdating
                    ? () => widget.onStatusUpdate(_selectedStatus!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: widget.isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    final status = widget.latestStatus!;
    final statusInfo = _getStatusInfo(status.status);
    final timeAgo = _getTimeAgo(status.timestamp);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusInfo.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusInfo.icon,
            color: statusInfo.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current: ${statusInfo.label}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: statusInfo.color,
                  ),
                ),
                Text(
                  'Updated $timeAgo by ${status.userName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOptions() {
    return Column(
      children: ParkingStatus.values.map((status) {
        final statusInfo = _getStatusInfo(status);
        final isSelected = _selectedStatus == status;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedStatus = status;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? statusInfo.color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected 
                      ? statusInfo.color
                      : AppColors.grey300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    statusInfo.icon,
                    color: statusInfo.color,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusInfo.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? statusInfo.color : AppColors.grey700,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: statusInfo.color,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  StatusInfo _getStatusInfo(ParkingStatus status) {
    switch (status) {
      case ParkingStatus.available:
        return StatusInfo(
          label: 'Available',
          icon: Icons.check_circle,
          color: AppColors.successGreen,
        );
      case ParkingStatus.fewSpotsLeft:
        return StatusInfo(
          label: 'Few Spots Left',
          icon: Icons.warning,
          color: AppColors.warningYellow,
        );
      case ParkingStatus.full:
        return StatusInfo(
          label: 'Full',
          icon: Icons.cancel,
          color: AppColors.errorRed,
        );
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class StatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}