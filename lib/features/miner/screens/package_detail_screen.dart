import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';

class PackageDetailScreen extends StatelessWidget {
  final PackageModel package;

  const PackageDetailScreen({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Package ${package.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePackage(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
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
                            package.statusDisplayName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(
                                    package.status,
                                    context,
                                  ),
                                ),
                          ),
                          Text(
                            _getStatusDescription(package.status),
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
                    _DetailRow(
                      label: 'Tag ID',
                      value: package.id,
                      copyable: true,
                    ),
                    _DetailRow(
                      label: 'Mineral Type',
                      value: package.mineralType,
                    ),
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

            // QR Code
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: QrImageView(
                        data: package.id,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        gapless: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      package.id,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context, package.id),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Tag ID'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Verification Instructions',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Present this QR code to GOLDBOD officials for verification\n'
                      '• If the QR code is damaged, provide the Tag ID for manual entry\n'
                      '• Keep your gold package with this tag at all times\n'
                      '• Contact GOLDBOD if you notice any discrepancies',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  String _getStatusDescription(PackageStatus status) {
    switch (status) {
      case PackageStatus.pending:
        return 'Awaiting verification by GOLDBOD officials';
      case PackageStatus.verified:
        return 'Successfully verified and approved';
      case PackageStatus.rejected:
        return 'Rejected during verification process';
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tag ID "$text" copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _sharePackage(BuildContext context) {
    final shareText =
        '''
Gold Package Details - Traky

Tag ID: ${package.id}
Mineral Type: ${package.mineralType}
Quantity: ${package.quantityDisplayText}
Grade: ${package.grade}
Mine Date: ${package.formattedMineDate}
Location: ${package.location}
Status: ${package.statusDisplayName}
Miner: ${package.minerName}

Created on ${package.formattedCreatedAt}
    ''';

    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be available in production'),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: copyable
                ? InkWell(
                    onTap: () => _copyToClipboard(context, value),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: copyable ? 'monospace' : null,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.copy,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  )
                : Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
