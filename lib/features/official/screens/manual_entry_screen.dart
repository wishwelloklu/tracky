import 'package:flutter/material.dart';
import 'package:tracky_mobile/features/official/screens/verification_screen.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagIdController = TextEditingController();

  @override
  void dispose() {
    _tagIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Tag Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Manual Tag ID Entry',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the Tag ID manually if the QR code cannot be scanned. Tag IDs start with "TRK" followed by alphanumeric characters.',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tag ID Input Field
              TextFormField(
                controller: _tagIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Tag ID',
                  hintText: 'e.g., TRK001SAMPLE1',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                  helperText: 'Enter the complete Tag ID from the package',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Tag ID';
                  }
                  if (!value.toUpperCase().startsWith('TRK')) {
                    return 'Tag ID should start with "TRK"';
                  }
                  if (value.length < 8) {
                    return 'Tag ID seems too short';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Convert to uppercase as user types
                  final upperValue = value.toUpperCase();
                  if (upperValue != value) {
                    _tagIdController.value = _tagIdController.value.copyWith(
                      text: upperValue,
                      selection: TextSelection.collapsed(
                        offset: upperValue.length,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Verify Button
              ElevatedButton(
                onPressed: _handleVerification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Verify Package'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Access Buttons (Demo Tags)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Demo Tags - Quick Access',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DemoTagButton(
                        tagId: 'TRK001SAMPLE1',
                        description: 'Gold Dust - Pending',
                        onTap: () => _fillTagId('TRK001SAMPLE1'),
                      ),
                      const SizedBox(height: 8),
                      _DemoTagButton(
                        tagId: 'TRK002SAMPLE2',
                        description: 'Raw Gold - Verified',
                        onTap: () => _fillTagId('TRK002SAMPLE2'),
                      ),
                      const SizedBox(height: 8),
                      _DemoTagButton(
                        tagId: 'TRK003SAMPLE3',
                        description: 'Gold Nuggets - Pending',
                        onTap: () => _fillTagId('TRK003SAMPLE3'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Alternative Action
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Use QR Scanner Instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fillTagId(String tagId) {
    _tagIdController.text = tagId;
  }

  void _handleVerification() {
    if (!_formKey.currentState!.validate()) return;

    final tagId = _tagIdController.text.trim().toUpperCase();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VerificationScreen(tagId: tagId)),
    );
  }
}

class _DemoTagButton extends StatelessWidget {
  final String tagId;
  final String description;
  final VoidCallback onTap;

  const _DemoTagButton({
    required this.tagId,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tagId,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
