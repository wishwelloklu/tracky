import 'package:uuid/uuid.dart';
import 'package:tracky_mobile/core/services/storage_service.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';

class PackageService {
  static const _uuid = Uuid();

  Future<PackageModel> createPackage({
    required String mineralType,
    required double quantity,
    required DateTime mineDate,
    required String location,
    required String grade,
    required String minerId,
    required String minerName,
    String? notes,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    final package = PackageModel(
      id: _generateTagId(),
      mineralType: mineralType,
      quantity: quantity,
      mineDate: mineDate,
      location: location,
      grade: grade,
      minerId: minerId,
      minerName: minerName,
      createdAt: DateTime.now(),
      status: PackageStatus.pending,
      notes: notes,
    );

    // Save to local storage
    await _savePackageLocally(package);

    return package;
  }

  Future<List<PackageModel>> getMinerPackages(String minerId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final packages = StorageService.getPackages();
    final minerPackages = packages
        .where((p) => p['minerId'] == minerId)
        .map((p) => PackageModel.fromJson(p))
        .toList();

    // Sort by creation date (newest first)
    minerPackages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return minerPackages;
  }

  Future<PackageModel?> getPackageById(String packageId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final packages = StorageService.getPackages();
    try {
      final packageData = packages.firstWhere((p) => p['id'] == packageId);
      return PackageModel.fromJson(packageData);
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePackageLocally(PackageModel package) async {
    final packages = StorageService.getPackages();
    packages.add(package.toJson());
    await StorageService.savePackages(packages);
  }

  String _generateTagId() {
    // Generate a unique tag ID with prefix
    final uuid = _uuid.v4();
    final shortId = uuid.replaceAll('-', '').substring(0, 12).toUpperCase();
    return 'TRK$shortId';
  }

  Future<List<PackageModel>> getAllPackages() async {
    // This would be used by officials to get all packages
    await Future.delayed(const Duration(milliseconds: 500));

    final packages = StorageService.getPackages();
    final allPackages = packages.map((p) => PackageModel.fromJson(p)).toList();

    // Sort by creation date (newest first)
    allPackages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return allPackages;
  }

  Future<PackageModel> updatePackageStatus(
    String packageId,
    PackageStatus newStatus, {
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final packages = StorageService.getPackages();
    final packageIndex = packages.indexWhere((p) => p['id'] == packageId);

    if (packageIndex == -1) {
      throw Exception('Package not found');
    }

    final packageData = packages[packageIndex];
    final package = PackageModel.fromJson(packageData);
    final updatedPackage = package.copyWith(
      status: newStatus,
      notes: notes ?? package.notes,
    );

    packages[packageIndex] = updatedPackage.toJson();
    await StorageService.savePackages(packages);

    return updatedPackage;
  }

  // Initialize with some sample data
  Future<void> initializeSampleData() async {
    final existingPackages = StorageService.getPackages();
    if (existingPackages.isNotEmpty) return;

    final samplePackages = [
      PackageModel(
        id: 'TRK001SAMPLE1',
        mineralType: 'Gold Dust',
        quantity: 15.5,
        mineDate: DateTime.now().subtract(const Duration(days: 5)),
        location: 'Obuasi, Ashanti Region',
        grade: '22K',
        minerId: '1',
        minerName: 'Kwame Asante',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        status: PackageStatus.pending,
      ),
      PackageModel(
        id: 'TRK002SAMPLE2',
        mineralType: 'Raw Gold',
        quantity: 8.2,
        mineDate: DateTime.now().subtract(const Duration(days: 12)),
        location: 'Obuasi, Ashanti Region',
        grade: '24K',
        minerId: '1',
        minerName: 'Kwame Asante',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        status: PackageStatus.verified,
      ),
      PackageModel(
        id: 'TRK003SAMPLE3',
        mineralType: 'Gold Nuggets',
        quantity: 23.7,
        mineDate: DateTime.now().subtract(const Duration(days: 3)),
        location: 'Tarkwa, Western Region',
        grade: '20K',
        minerId: '3',
        minerName: 'Kofi Adjei',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: PackageStatus.pending,
      ),
    ];

    final packagesJson = samplePackages.map((p) => p.toJson()).toList();
    await StorageService.savePackages(packagesJson);
  }
}
