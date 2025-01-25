import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String medicineName;
  final String medicineSalt;
  final String medicineCompany;
  final int medicinePrice; // This should be an int
  final int quantity; // This should be an int

  Medicine({
    required this.id,
    required this.medicineName,
    required this.medicineSalt,
    required this.medicineCompany,
    required this.medicinePrice,
    required this.quantity,
  });

  // Create a Medicine object from Firestore data
  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Medicine(
      id: doc.id,
      medicineName: data['medicineName'] ?? '',
      medicineSalt: data['medicineSalt'] ?? '',
      medicineCompany: data['medicineCompany'] ?? '',
      // Ensure the price and quantity are parsed as integers
      medicinePrice: int.tryParse(data['medicinePrice'].toString()) ?? 0,
      quantity: int.tryParse(data['quantity'].toString()) ?? 0,
    );
  }

  // Convert Medicine object to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'medicineName': medicineName,
      'medicineSalt': medicineSalt,
      'medicineCompany': medicineCompany,
      'medicinePrice': medicinePrice,
      'quantity': quantity,
    };
  }
}
