import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/loadboard_providers.dart';
import '../../../data/models/load_models.dart';
import '../../../core/navigation/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';

class LoadboardPage extends ConsumerWidget {
  const LoadboardPage({super.key});

  Color _statusColor(LoadStatus status) {
    switch (status) {
      case LoadStatus.assigned:
        return AppColors.infoBlue;
      case LoadStatus.inTransit:
        return AppColors.warningYellow;
      case LoadStatus.delivered:
        return AppColors.successGreen;
      case LoadStatus.cancelled:
        return AppColors.errorRed;
    }
  }

  String _statusText(LoadStatus status) {
    switch (status) {
      case LoadStatus.assigned:
        return 'Assigned';
      case LoadStatus.inTransit:
        return 'In Transit';
      case LoadStatus.delivered:
        return 'Delivered';
      case LoadStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadsAsync = ref.watch(driverLoadsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goToDashboard(),
          tooltip: AppLocalizations.of(context)!.goToDashboard,
        ),
        title: const Text('Loadboard'),
      ),
      body: loadsAsync.when(
        data: (loads) {
          if (loads.isEmpty) {
            return const Center(
              child: Text('No loads assigned.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemBuilder: (context, index) {
              final load = loads[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            load.referenceNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(load.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _statusColor(load.status)),
                            ),
                            child: Text(
                              _statusText(load.status),
                              style: TextStyle(
                                color: _statusColor(load.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.north_east, color: AppColors.infoBlue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pickup: ${load.pickupCity}, ${load.pickupState} • ${_formatDateTime(load.pickupTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.south_west, color: AppColors.secondaryOrange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Dropoff: ${load.dropoffCity}, ${load.dropoffState} • ${_formatDateTime(load.dropoffTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (load.weightLbs != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.scale, size: 18, color: AppColors.grey600),
                                  const SizedBox(width: 6),
                                  Text('${load.weightLbs!.toStringAsFixed(0)} lbs'),
                                ],
                              ),
                            ),
                          if (load.rateUsd != null)
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 18, color: AppColors.grey600),
                                const SizedBox(width: 6),
                                Text('${load.rateUsd!.toStringAsFixed(0)} rate'),
                              ],
                            ),
                        ],
                      ),
                      if (load.brokerName != null) ...[
                        const SizedBox(height: 8),
                        Text('Broker: ${load.brokerName!}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                      if (load.notes != null && load.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${load.notes!}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: loads.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Failed to load: $err'),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}