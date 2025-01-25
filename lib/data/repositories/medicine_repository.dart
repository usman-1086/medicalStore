import '../models/medicine.dart';

class MedicineRepository {
  /// Add new medicine stock
  Future<void> addStock(Medicine medicine) async {
    // Implementation here
  }

  /// Update existing medicine stock
  Future<void> updateStock(Medicine medicine) async {
    // Implementation here
  }

  /// Delete medicine stock
  Future<void> deleteStock(int id) async {
    // Implementation here
  }

  /// Get all medicine stock
  Future<List<Medicine>> getStock() async {
    // Implementation here
    return [];
  }

  /// Search medicines by a specific field
  Future<List<Medicine>> searchStock(String field, String query) async {
    // Implementation here
    return [];
  }
}
