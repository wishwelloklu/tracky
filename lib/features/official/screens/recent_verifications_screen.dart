import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracky_mobile/features/miner/providers/package_provider.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';
import 'package:tracky_mobile/features/official/screens/verification_screen.dart';

class RecentVerificationsScreen extends ConsumerStatefulWidget {
  const RecentVerificationsScreen({super.key});

  @override
  ConsumerState<RecentVerificationsScreen> createState() =>
      _RecentVerificationsScreenState();
}

class _RecentVerificationsScreenState
    extends ConsumerState<RecentVerificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load all packages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allPackagesProvider.notifier).loadAllPackages();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packagesAsync = ref.watch(allPackagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Verifications'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Tag ID, miner name, or location...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 16),

              // Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Verified'),
                  Tab(text: 'Rejected'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: packagesAsync.when(
        data: (packages) {
          final filteredPackages = _filterPackages(packages);

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(allPackagesProvider.notifier).refresh();
            },
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPackageList(filteredPackages),
                _buildPackageList(
                  _filterByStatus(filteredPackages, PackageStatus.pending),
                ),
                _buildPackageList(
                  _filterByStatus(filteredPackages, PackageStatus.verified),
                ),
                _buildPackageList(
                  _filterByStatus(filteredPackages, PackageStatus.rejected),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading packages',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(allPackagesProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PackageModel> _filterPackages(List<PackageModel> packages) {
    if (_searchQuery.isEmpty) return packages;

    return packages.where((package) {
      final query = _searchQuery.toLowerCase();
      return package.id.toLowerCase().contains(query) ||
          package.minerName.toLowerCase().contains(query) ||
          package.mineralType.toLowerCase().contains(query) ||
          package.location.toLowerCase().contains(query) ||
          package.grade.toLowerCase().contains(query);
    }).toList();
  }

  List<PackageModel> _filterByStatus(
    List<PackageModel> packages,
    PackageStatus status,
  ) {
    return packages.where((package) => package.status == status).toList();
  }

  Widget _buildPackageList(List<PackageModel> packages) {
    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No packages found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'Packages will appear here as they are created',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PackageCard(
            package: package,
            onTap: () => _navigateToVerification(context, package.id),
          ),
        );
      },
    );
  }

  void _navigateToVerification(BuildContext context, String tagId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VerificationScreen(tagId: tagId)),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final VoidCallback onTap;

  const _PackageCard({required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Tag ID and Status
              Row(
                children: [
                  Container(
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
                      _getStatusIcon(package.status),
                      color: _getStatusColor(package.status, context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.id,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                        ),
                        Text(
                          'By ${package.minerName}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                ],
              ),
              const SizedBox(height: 16),

              // Package Details Grid
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.diamond,
                      label: 'Type',
                      value: package.mineralType,
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.scale,
                      label: 'Quantity',
                      value: package.quantityDisplayText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.grade,
                      label: 'Grade',
                      value: package.grade,
                    ),
                  ),
                  Expanded(
                    child: _DetailItem(
                      icon: Icons.calendar_today,
                      label: 'Mine Date',
                      value: package.formattedMineDate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _DetailItem(
                icon: Icons.location_on,
                label: 'Location',
                value: package.location,
              ),
              const SizedBox(height: 8),
              _DetailItem(
                icon: Icons.access_time,
                label: 'Created',
                value: package.formattedCreatedAt,
              ),

              // Action Button for Pending Packages
              if (package.status == PackageStatus.pending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.verified_user),
                    label: const Text('Verify Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
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

  IconData _getStatusIcon(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return Icons.hourglass_empty;
      case PackageStatus.verified:
        return Icons.verified;
      case PackageStatus.rejected:
        return Icons.cancel;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
