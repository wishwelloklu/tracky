import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracky_mobile/core/constants/app_constants.dart';
import 'package:tracky_mobile/features/auth/providers/auth_provider.dart';
import 'package:tracky_mobile/features/miner/providers/package_provider.dart';
import 'package:tracky_mobile/features/miner/screens/qr_code_display_screen.dart';

class NewPackageScreen extends ConsumerStatefulWidget {
  const NewPackageScreen({super.key});

  @override
  ConsumerState<NewPackageScreen> createState() => _NewPackageScreenState();
}

class _NewPackageScreenState extends ConsumerState<NewPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedMineralType;
  String? _selectedGrade;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final creationState = ref.watch(packageCreationProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Navigate to QR code display when package is created
    ref.listen(packageCreationProvider, (previous, next) {
      if (next.createdPackage != null) {
        // Add the new package to the packages list
        ref
            .read(minerPackagesProvider.notifier)
            .addPackage(next.createdPackage!);

        // Navigate to QR code display
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                QRCodeDisplayScreen(package: next.createdPackage!),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Gold Package'),
        actions: [
          TextButton(
            onPressed: creationState.isLoading ? null : _handleSubmit,
            child: creationState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Fill in the details below to create a new gold package and generate a unique tracking tag.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mineral Type Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedMineralType,
                decoration: const InputDecoration(
                  labelText: 'Mineral Type',
                  hintText: 'Select mineral type',
                  prefixIcon: Icon(Icons.diamond),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.mineralTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedMineralType = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a mineral type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity Field
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantity (grams)',
                  hintText: 'Enter quantity in grams',
                  prefixIcon: Icon(Icons.scale),
                  suffixText: 'g',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  final quantity = double.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grade Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  hintText: 'Select gold grade',
                  prefixIcon: Icon(Icons.grade),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.gradeOptions
                    .map(
                      (grade) =>
                          DropdownMenuItem(value: grade, child: Text(grade)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedGrade = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mine Date Picker
              InkWell(
                onTap: () => _selectMineDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Mine Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Mining Location',
                  hintText: user.location ?? 'Enter specific mining location',
                  prefixIcon: const Icon(Icons.location_on),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the mining location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Field (Optional)
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information about the package...',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              if (creationState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          creationState.error!,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Create Package Button
              ElevatedButton(
                onPressed: creationState.isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: creationState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_box),
                          const SizedBox(width: 8),
                          const Text('Create Package & Generate QR'),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Info Card
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
                            Icons.lightbulb,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tip',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Once created, your package will be assigned a unique tracking ID and QR code. Keep the QR code safe - it will be used by GOLDBOD officials to verify your gold.',
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectMineDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // 1 year ago
      lastDate: DateTime.now(),
      helpText: 'Select mining date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    final quantity = double.parse(_quantityController.text.trim());
    final location = _locationController.text.trim();
    final notes = _notesController.text.trim().isNotEmpty
        ? _notesController.text.trim()
        : null;

    await ref
        .read(packageCreationProvider.notifier)
        .createPackage(
          mineralType: _selectedMineralType!,
          quantity: quantity,
          mineDate: _selectedDate,
          location: location,
          grade: _selectedGrade!,
          minerId: user.id,
          minerName: user.name,
          notes: notes,
        );
  }
}
