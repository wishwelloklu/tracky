import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tracky_mobile/features/miner/providers/package_provider.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';
import 'package:tracky_mobile/features/official/screens/report_screen.dart';

class VerificationScreen extends ConsumerWidget {
  final String tagId;

  const VerificationScreen({super.key, required this.tagId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageAsync = ref.watch(packageByIdProvider(tagId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Verification'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
      body: packageAsync.when(
        data: (package) => package != null
            ? _buildPackageDetails(context, ref, package)
            : _buildPackageNotFound(context, tagId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildPackageDetails(
    BuildContext context,
    WidgetRef ref,
    PackageModel package,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Status Card
          Card(
            color: _getStatusColor(
              package.status,
              context,
            ).withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(package.status),
                    color: _getStatusColor(package.status, context),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getVerificationTitle(package.status),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(package.status, context),
                              ),
                        ),
                        Text(
                          _getVerificationDescription(package.status),
                          style: TextStyle(
                            color: _getStatusColor(
                              package.status,
                              context,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Package Information
          Text(
            'Package Information',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow(label: 'Tag ID', value: package.id),
                  _DetailRow(label: 'Mineral Type', value: package.mineralType),
                  _DetailRow(
                    label: 'Quantity',
                    value: package.quantityDisplayText,
                  ),
                  _DetailRow(label: 'Grade', value: package.grade),
                  _DetailRow(
                    label: 'Mine Date',
                    value: package.formattedMineDate,
                  ),
                  _DetailRow(label: 'Location', value: package.location),
                  _DetailRow(
                    label: 'Created',
                    value: package.formattedCreatedAt,
                  ),
                  if (package.notes != null)
                    _DetailRow(label: 'Notes', value: package.notes!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Miner Information
          Text(
            'Miner Information',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow(label: 'Miner ID', value: package.minerId),
                  _DetailRow(label: 'Miner Name', value: package.minerName),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // QR Code Verification
          Text(
            'QR Code',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QrImageView(
                      data: package.id,
                      version: QrVersions.auto,
                      size: 150,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      gapless: false,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    package.id,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Verification Actions
          if (package.status == PackageStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyPackage(
                      context,
                      ref,
                      package,
                      PackageStatus.verified,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Verify Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyPackage(
                      context,
                      ref,
                      package,
                      PackageStatus.rejected,
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject Package'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Report Issue Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigateToReport(context, package),
              icon: const Icon(Icons.report),
              label: const Text('Report Issue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageNotFound(BuildContext context, String tagId) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Package Not Found',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No package found with Tag ID: $tagId',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This could mean:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '• The Tag ID was entered incorrectly\n'
            '• The package has not been registered\n'
            '• The QR code may be damaged or counterfeit',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Try Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _reportSuspiciousPackage(context, tagId),
                  icon: const Icon(Icons.report),
                  label: const Text('Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
            'Verification Error',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
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

  String _getVerificationTitle(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return 'Pending Verification';
      case PackageStatus.verified:
        return 'Package Verified ✓';
      case PackageStatus.rejected:
        return 'Package Rejected';
    }
  }

  String _getVerificationDescription(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return 'This package is authentic and awaits your verification';
      case PackageStatus.verified:
        return 'This package has been successfully verified';
      case PackageStatus.rejected:
        return 'This package was rejected during verification';
    }
  }

  void _verifyPackage(
    BuildContext context,
    WidgetRef ref,
    PackageModel package,
    PackageStatus newStatus,
  ) {
    final action = newStatus == PackageStatus.verified ? 'verify' : 'reject';
    final color = newStatus == PackageStatus.verified
        ? Colors.green
        : Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${action.substring(0, 1).toUpperCase()}${action.substring(1)} Package',
        ),
        content: Text('Are you sure you want to $action this package?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(allPackagesProvider.notifier)
                  .updatePackageStatus(package.id, newStatus);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Package ${action}ed successfully'),
                  backgroundColor: color,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(
              action.substring(0, 1).toUpperCase() + action.substring(1),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToReport(BuildContext context, PackageModel package) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ReportScreen(package: package)),
    );
  }

  void _reportSuspiciousPackage(BuildContext context, String tagId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ReportScreen(tagId: tagId)));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
