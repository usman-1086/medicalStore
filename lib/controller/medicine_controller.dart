import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicalstore/data/models/medicine.dart';

import '../data/models/cart_history_item.dart';

class MedicineController extends GetxController {
  RxList<Medicine> medicines = <Medicine>[].obs;
  RxList<Medicine> filteredMedicines = <Medicine>[].obs;
  RxList<CartItem> cartItems = <CartItem>[].obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<CartHistoryItem> cartHistory = <CartHistoryItem>[].obs;


  @override
  void onInit() {
    super.onInit();
    fetchMedicines();
    
  }

  void saveCartToHistory() {
    final timestamp = DateTime.now();
    for (final item in cartItems) {
      cartHistory.add(CartHistoryItem(
        medicineName: item.medicine.medicineName,
        quantity: item.quantity,
        dateTime: timestamp,
      ));
    }
    clearCart(); // Clear cart after saving
  }

  void resetMedicines() {
    medicines.clear(); // Clear the medicines list when the user changes
    filteredMedicines.clear(); // Clear the filtered list as well
  }
  Future<void> fetchMedicines() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      print("Fetching medicines for user: ${currentUser.uid}");

      final snapshot = _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medicines')
          .snapshots();

      snapshot.listen((querySnapshot) {
        medicines.value = querySnapshot.docs
            .map((doc) => Medicine.fromFirestore(doc))
            .toList();

        filteredMedicines.value = List.from(medicines);
      });
    } catch (e) {
      print("Error fetching medicines: $e");
    }
  }

  // Add a new medicine
  Future<void> addMedicine(Medicine medicine) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medicines')
          .add(medicine.toMap());

      Get.snackbar(
        "Success",
        "Medicine added successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add medicine: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Add to cart
  void addToCart(Medicine medicine, int quantity) {
    // Check if the medicine is already in the cart
    final existingCartItem = cartItems.firstWhere(
          (item) => item.medicine.id == medicine.id,
      orElse: () => CartItem(medicine: medicine, quantity: 0), // Return a new CartItem with quantity 0 if not found
    );

    if (existingCartItem.quantity == 0) {
      // Add medicine to cart if it's not already there
      cartItems.add(CartItem(medicine: medicine, quantity: quantity));
    } else {
      // If the medicine is already in the cart, just update the quantity
      existingCartItem.quantity += quantity;
    }

    // Ensure the stock is not less than the quantity added to the cart
    if (medicine.quantity >= quantity) {
      // Update stock in Firestore (decrease stock)
      final newStock = medicine.quantity - quantity;
      updateStock(medicine.id, newStock);
    } else {
      // If there's not enough stock, show an error or a message
      Get.snackbar("Insufficient Stock", "Not enough stock to add to cart.");
    }
  }

  // Remove item from cart
  void removeFromCart(CartItem cartItem) {
    cartItems.remove(cartItem);
    updateStock(cartItem.medicine.id, cartItem.quantity);
  }

// Update stock of a medicine for the logged-in user
  Future<void> updateStock(String medicineId, int newStock) async {
    try {
      // Get the current logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Update the medicine stock under the current user's collection
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medicines')
          .doc(medicineId)
          .update({'quantity': newStock});

      // Refresh the medicine list after updating stock
      fetchMedicines();
    } catch (e) {
      print("Error updating stock: $e");
    }
  }
  // Delete medicine
  Future<void> deleteMedicine(String id) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medicines')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting medicine: $e");
    }
  }

  // Clear cart
  void clearCart() {
    cartItems.clear();
  }

  // Calculate total price
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) => sum + (item.medicine.medicinePrice * item.quantity));
  }

  void updateFilteredMedicines(String query) {
    if (query.isEmpty) {
      filteredMedicines.value = List.from(medicines); // Show all if query is empty
    } else {
      // Filter medicines by name, salt, or company
      filteredMedicines.value = medicines.where((medicine) {
        return medicine.medicineName.toLowerCase().contains(query.toLowerCase()) ||
            medicine.medicineSalt.toLowerCase().contains(query.toLowerCase()) ||
            medicine.medicineCompany.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }


}

// Cart item model
class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, required this.quantity});
}
