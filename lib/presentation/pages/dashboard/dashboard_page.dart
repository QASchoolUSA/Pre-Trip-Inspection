import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../vehicle/vehicle_selection_page.dart';
import '../../providers/loadboard_providers.dart';
import '../../../data/models/load_models.dart';

/// Provider for inspection stats - loads asynchronously without blocking UI
final inspectionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final notifier = ref.watch(enhancedInspectionsProvider.notifier);
  return notifier.getStats();
});

/// Main dashboard page
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    // Use .maybeWhen to show 0 immediately instead of blocking
    final driverLoadsAsync = ref.watch(driverLoadsProvider);
    final deliveredLoadsCount = driverLoadsAsync.maybeWhen(
      data: (loads) => loads.where((l) => l.status == LoadStatus.delivered).length,
      orElse: () => 0,
    );
    
    // Use provider for stats - non-blocking, shows default then updates
    final statsAsync = ref.watch(inspectionStatsProvider);
    final inspectionStats = statsAsync.maybeWhen(
      data: (stats) => stats,
      orElse: () => <String, dynamic>{
        'total': 0,
        'completed': 0,
        'in_progress': 0,
        'pending': 0,
        'completion_rate': 0.0,
      },
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.settings,
            onPressed: () {
              context.goToSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppLocalizations.of(context)!.logout,
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context, currentUser),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActionsSection(context),
            
            const SizedBox(height: 24),
            
            // Statistics Section - now non-blocking
            _buildStatsSection(context, inspectionStats, deliveredLoadsCount),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            _buildRecentActivitySection(context),
          ],
        ),
      ),

    );
  }

  Widget _buildWelcomeSection(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? AppLocalizations.of(context)!.driver,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CDL: ${user?.cdlNumber ?? AppLocalizations.of(context)!.notApplicable}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.assignment_add,
                title: AppLocalizations.of(context)!.newInspection,
                subtitle: AppLocalizations.of(context)!.startPreTripInspection,
                color: AppColors.successGreen,
                onTap: () => _startNewInspection(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.history,
                title: AppLocalizations.of(context)!.viewReports,
                subtitle: AppLocalizations.of(context)!.previousInspections,
                color: AppColors.infoBlue,
                onTap: () => _viewReports(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.list_alt,
                title: AppConstants.loadboardTitle,
                subtitle: AppConstants.loadboardSubtitle,
                color: AppColors.secondaryOrange,
                onTap: () => context.goToLoadboard(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.map,
                title: 'Map & Navigation',
                subtitle: 'Find truck stops and services',
                color: AppColors.successGreen,
                onTap: () => context.goToMap(),
              ),
            ),
          ],
        ),

       ],
     );
   }

  Widget _buildStatsSection(
    BuildContext context,
    Map<String, dynamic> inspectionStats,
    int deliveredLoadsCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statistics,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                title: AppLocalizations.of(context)!.totalInspections,
                value: '${inspectionStats['total'] ?? 0}',
                icon: Icons.assignment,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                title: 'Loads Delivered',
                value: '$deliveredLoadsCount',
                icon: Icons.local_shipping,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recentActivity,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.noRecentActivity,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logoutConfirmTitle),
          content: Text(AppLocalizations.of(context)!.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currentUserProvider.notifier).state = null;
                context.goToLogin();
              },
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }

  void _startNewInspection(BuildContext context) {
    context.goToVehicleSelection();
  }

  void _viewReports(BuildContext context) {
    context.goToReports();
  }


  void _syncData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.dataSyncComingSoon),
        backgroundColor: Colors.blue,
      ),
    );
  }
}