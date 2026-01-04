import 'package:tracky_mobile/core/network/dio_client.dart';
import 'package:tracky_mobile/features/shared/models/package_model.dart';

class PackageService {
  final DioClient _dioClient;

  PackageService(this._dioClient);

  Future<PackageModel> createPackage({
    required String mineralType,
    required double quantity,
    required DateTime mineDate,
    required String location,
    required String grade,
    required String minerName,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/packages/create',
        data: {
          'mineralType': mineralType,
          'quantity': quantity,
          'mineDate': mineDate.toIso8601String().split('T')[0],
          'createdAt': DateTime.now().toIso8601String().split('T')[0],
          'location': location,
          'grade': grade,
          'notes': notes ?? '',
          'status': 'pending',
        },
      );

      dynamic data = response.data;
      if (data is Map && data.containsKey('data')) {
        data = data['data']; // Unwrap envelope
      }

      // If backend returns the created object, use it.
      // If not, we construct a local version with a temp or returned ID.
      if (data != null && data is Map) {
        return PackageModel.fromJson(Map<String, dynamic>.from(data));
      }

      // Fallback (shouldn't be reached if API is correct)
      return PackageModel(
        id: 'TEMP_${DateTime.now().millisecondsSinceEpoch}',
        mineralType: mineralType,
        quantity: quantity,
        mineDate: mineDate,
        location: location,
        grade: grade,
        minerName: minerName,
        createdAt: DateTime.now(),
        status: PackageStatus.pending,
        notes: notes,
      );
    } catch (e) {
      throw Exception('Failed to create package: ${e.toString()}');
    }
  }

  Future<List<PackageModel>> getMinerPackages() async {
    // Assuming /api/v1/packages/ returns packages visible to the user (miner)
    return getAllPackages();
  }

  // Future<PackageModel?> getPackageById() async {
  //   try {
  //     final packages = await getAllPackages();
  //     return packages;
  //   } catch (_) {
  //     return null;
  //   }
  // }

  Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await _dioClient.get('/api/v1/packages/');

      if (response.isSuccess) {
        dynamic data = response.data;
        if (data is Map && data.containsKey('data')) {
          data = data['data'];
        }

        if (data is List) {
          return data.map((json) {
            return PackageModel.fromJson(json);
          }).toList();
        }
      }
      return [];
    } catch (e) {
      // In case of error (e.g. offline), we might want to return empty or throw.
      // Returning empty list for safety.
      return [];
    }
  }

  Future<PackageModel> updatePackageStatus(
    String packageId,
    PackageStatus newStatus, {
    String? notes,
  }) async {
    try {
      await _dioClient.post(
        '/api/v1/packages/verify',
        data: {'packageId': packageId, 'status': newStatus.name},
      );

      // Re-fetch to get updated state
      final packages = await getAllPackages();
      try {
        return packages.firstWhere((p) => p.id == packageId);
      } catch (_) {
        throw Exception('Updated package not found in list');
      }
    } catch (e) {
      throw Exception('Failed to update package status: ${e.toString()}');
    }
  }

  // Method meant for sample data initialization - likely no longer needed with real API
  // Keeping empty or deprecated to match interface if used elsewhere
  Future<void> initializeSampleData() async {
    // No-op for real API
  }
}
