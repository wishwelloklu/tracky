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
    // Load packages when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        ref.read(minerPackagesProvider.notifier).loadMinerPackages(user.id);
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
      appBar: AppBar(
        title: Text('Hi, ${user.name.split(' ').first}! 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(minerPackagesProvider.notifier).refresh(user.id);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.engineering,
                          size: 30,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Small-Scale Miner',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            if (user.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.location!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.minerStatus == MinerStatus.active
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user.statusDisplayName,
                          style: TextStyle(
                            color: user.minerStatus == MinerStatus.active
                                ? Colors.green[700]
                                : Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              packagesAsync.when(
                data: (packages) => _buildStatisticsCards(context, packages),
                loading: () => _buildLoadingStatistics(),
                error: (error, _) => _buildErrorStatistics(error.toString()),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'New Package',
                      subtitle: 'Register new gold',
                      icon: Icons.add_box,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => _navigateToNewPackage(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      title: 'Package History',
                      subtitle: 'View all packages',
                      icon: Icons.history,
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: () => _navigateToPackageHistory(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Packages
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Packages',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToPackageHistory(context),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              packagesAsync.when(
                data: (packages) =>
                    _buildRecentPackages(context, packages.take(3).toList()),
                loading: () => _buildLoadingPackages(),
                error: (error, _) => _buildErrorMessage(error.toString()),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToNewPackage(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsCards(
    BuildContext context,
    List<PackageModel> packages,
  ) {
    final totalPackages = packages.length;
    final pendingPackages = packages
        .where((p) => p.status == PackageStatus.pending)
        .length;
    final verifiedPackages = packages
        .where((p) => p.status == PackageStatus.verified)
        .length;
    final totalQuantity = packages.fold<double>(
      0,
      (sum, package) => sum + package.quantity,
    );

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Packages',
            value: totalPackages.toString(),
            icon: Icons.inventory_2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Verified',
            value: verifiedPackages.toString(),
            icon: Icons.verified,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Total Gold',
            value: '${totalQuantity.toStringAsFixed(1)}g',
            icon: Icons.scale,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingStatistics() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
            child: Card(
              child: Container(
                height: 100,
                padding: const EdgeInsets.all(16),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorStatistics(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading statistics: $error'),
      ),
    );
  }

  Widget _buildRecentPackages(
    BuildContext context,
    List<PackageModel> packages,
  ) {
    if (packages.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No packages yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first gold package to get started',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: packages
          .map(
            (package) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PackageCard(package: package),
            ),
          )
          .toList(),
    );
  }

  Widget _buildLoadingPackages() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Container(
              height: 80,
              padding: const EdgeInsets.all(16),
              child: const Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Loading packages...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 8),
            Text('Error: $error'),
          ],
        ),
      ),
    );
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Icon(icon, color: color, size: 24)),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;

  const _PackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(
              package.status,
              context,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.inventory_2,
            color: _getStatusColor(package.status, context),
          ),
        ),
        title: Text(
          package.id,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${package.mineralType} • ${package.quantityDisplayText}'),
            Text(
              package.formattedCreatedAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
              package.status,
              context,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            package.statusDisplayName,
            style: TextStyle(
              color: _getStatusColor(package.status, context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PackageStatus status, BuildContext context) {
    switch (status) {
      case PackageStatus.pending:
        return Colors.orange;
      case PackageStatus.verified:
        return Colors.green;
      case PackageStatus.rejected:
        return Colors.red;
    }
  }
}
