import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tracky_mobile/features/miner/services/package_service.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';

import 'package:tracky_mobile/core/network/dio_provider.dart';

final packageServiceProvider = Provider<PackageService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return PackageService(dioClient);
});

final minerPackagesProvider =
    StateNotifierProvider<
      MinerPackagesNotifier,
      AsyncValue<List<PackageModel>>
    >((ref) {
      return MinerPackagesNotifier(ref.read(packageServiceProvider));
    });

final packageCreationProvider =
    StateNotifierProvider<PackageCreationNotifier, PackageCreationState>((ref) {
      return PackageCreationNotifier(ref.read(packageServiceProvider));
    });

class MinerPackagesNotifier
    extends StateNotifier<AsyncValue<List<PackageModel>>> {
  final PackageService _packageService;

  MinerPackagesNotifier(this._packageService)
    : super(const AsyncValue.loading());

  Future<void> loadMinerPackages() async {
    try {
      state = const AsyncValue.loading();
      final packages = await _packageService.getMinerPackages();
      state = AsyncValue.data(packages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadMinerPackages();
  }

  void addPackage(PackageModel package) {
    state.whenData((packages) {
      final updatedPackages = [package, ...packages];
      state = AsyncValue.data(updatedPackages);
    });
  }
}

class PackageCreationState {
  final bool isLoading;
  final PackageModel? createdPackage;
  final String? error;

  PackageCreationState({
    this.isLoading = false,
    this.createdPackage,
    this.error,
  });

  PackageCreationState copyWith({
    bool? isLoading,
    PackageModel? createdPackage,
    String? error,
  }) {
    return PackageCreationState(
      isLoading: isLoading ?? this.isLoading,
      createdPackage: createdPackage ?? this.createdPackage,
      error: error ?? this.error,
    );
  }
}

class PackageCreationNotifier extends StateNotifier<PackageCreationState> {
  final PackageService _packageService;

  PackageCreationNotifier(this._packageService) : super(PackageCreationState());

  Future<bool> createPackage({
    required String mineralType,
    required double quantity,
    required DateTime mineDate,
    required String location,
    required String grade,
    required String minerName,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final package = await _packageService.createPackage(
        mineralType: mineralType,
        quantity: quantity,
        mineDate: mineDate,
        location: location,
        grade: grade,
        minerName: minerName,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        createdPackage: package,
        error: null,
      );

      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  void clearState() {
    state = PackageCreationState();
  }
}

// Provider for getting a specific package by ID
// final packageByIdProvider = FutureProviderFamily<PackageModel?, String>((
//   ref,
//   packageId,
// ) async {
//   final packageService = ref.read(packageServiceProvider);
//   return await packageService.getPackageById(packageId);
// });

// Provider for all packages (used by officials)
final allPackagesProvider =
    StateNotifierProvider<AllPackagesNotifier, AsyncValue<List<PackageModel>>>((
      ref,
    ) {
      return AllPackagesNotifier(ref.read(packageServiceProvider));
    });

class AllPackagesNotifier
    extends StateNotifier<AsyncValue<List<PackageModel>>> {
  final PackageService _packageService;

  AllPackagesNotifier(this._packageService) : super(const AsyncValue.loading());

  Future<void> loadAllPackages() async {
    try {
      state = const AsyncValue.loading();
      final packages = await _packageService.getAllPackages();
      state = AsyncValue.data(packages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePackageStatus(
    String packageId,
    PackageStatus newStatus, {
    String? notes,
  }) async {
    try {
      final updatedPackage = await _packageService.updatePackageStatus(
        packageId,
        newStatus,
        notes: notes,
      );

      state.whenData((packages) {
        final updatedPackages = packages.map((p) {
          return p.id == packageId ? updatedPackage : p;
        }).toList();
        state = AsyncValue.data(updatedPackages);
      });
    } catch (error) {
      // Handle error - in a real app, you might want to show a snackbar
      print('Error updating package status: $error');
    }
  }

  Future<void> refresh() async {
    await loadAllPackages();
  }
}
