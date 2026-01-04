import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracky_mobile/features/auth/providers/auth_provider.dart';
import 'package:tracky_mobile/features/miner/providers/package_provider.dart';
import 'package:tracky_mobile/features/miner/screens/new_package_screen.dart';
import 'package:tracky_mobile/features/miner/screens/package_history_screen.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';
import 'package:tracky_mobile/features/auth/screens/role_selection_screen.dart';
import 'package:tracky_mobile/features/auth/models/user_model.dart';

class MinerDashboardScreen extends ConsumerStatefulWidget {
  const MinerDashboardScreen({super.key});

  @override
  ConsumerState<MinerDashboardScreen> createState() =>
      _MinerDashboardScreenState();
}

class _MinerDashboardScreenState extends ConsumerState<MinerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        ref.read(minerPackagesProvider.notifier).loadMinerPackages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final packagesAsync = ref.watch(minerPackagesProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(minerPackagesProvider.notifier).loadMinerPackages();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 32),
                packagesAsync.when(
                  data: (packages) => _buildStatsOverview(context, packages),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error loading stats: $e'),
                ),
                const SizedBox(height: 32),
                Text(
                  'Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildActionGrid(context),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToPackageHistory(context),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                packagesAsync.when(
                  data: (packages) =>
                      _buildRecentList(context, packages.take(5).toList()),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                user.firstName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showLogoutDialog(context),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5),
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(
    BuildContext context,
    List<PackageModel> packages,
  ) {
    final total = packages.length;
    final totalGold = packages.fold<double>(0, (sum, p) => sum + p.quantity);
    final verified = packages
        .where((p) => p.status == PackageStatus.verified)
        .length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            context,
            'Total Gold',
            '${totalGold.toStringAsFixed(1)}g',
            Icons.scale,
            isLight: true,
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            context,
            'Packages',
            total.toString(),
            Icons.inventory_2,
            isLight: true,
          ),
          Container(
            width: 1,
            height: 48,
            color: Theme.of(
              context,
            ).colorScheme.onPrimary.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            context,
            'Verified',
            verified.toString(),
            Icons.verified,
            isLight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isLight = false,
  }) {
    final color = isLight
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            title: 'New Package',
            icon: Icons.add,
            color: Theme.of(context).colorScheme.primaryContainer,
            iconColor: Theme.of(context).colorScheme.primary,
            onTap: () => _navigateToNewPackage(context),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionTile(
            title: 'History',
            icon: Icons.history,
            color: Theme.of(context).colorScheme.secondaryContainer,
            iconColor: Theme.of(context).colorScheme.secondary,
            onTap: () => _navigateToPackageHistory(context),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentList(BuildContext context, List<PackageModel> packages) {
    if (packages.isEmpty) {
      return Center(
        child: Text(
          'No activity yet',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return Column(
      children: packages
          .map(
            (p) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(p.status).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(p.status),
                      color: _getStatusColor(p.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.quantityDisplayText} ${p.mineralType}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          p.formattedCreatedAt,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      p.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(p.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Color _getStatusColor(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Colors.orange;
      case PackageStatus.verified:
        return Colors.green;
      case PackageStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Icons.hourglass_empty;
      case PackageStatus.verified:
        return Icons.check;
      case PackageStatus.rejected:
        return Icons.close;
    }
  }

  void _navigateToNewPackage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NewPackageScreen()));
  }

  void _navigateToPackageHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PackageHistoryScreen()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
