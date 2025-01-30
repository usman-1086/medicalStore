import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:medicalstore/data/models/medicine.dart';


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

  // Save cart to Firestore and clear local cart
  Future<void> saveCartToFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final batch = _firestore.batch(); // Use batch for multiple writes

      for (final item in cartItems) {
        final timestamp = DateTime.now();
        final historyRef = _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('cartHistory')
            .doc();

        batch.set(historyRef, {
          'medicineName': item.medicine.medicineName,
          'quantity': item.quantity,
          'price': item.medicine.medicinePrice * item.quantity,
          'date': timestamp.toIso8601String(), // Save date in ISO format
          'time': TimeOfDay.now().format(Get.context!), // Save time as HH:MM AM/PM
        });
      }

      await batch.commit(); // Commit all writes
      clearCart(); // Clear cart after saving

      Get.snackbar(
        "Success",
        "Cart saved to history!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save cart: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

// Fetch history from Firestore
  Future<void> fetchCartHistory() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cartHistory')
          .orderBy('date', descending: true) // Sort by date
          .get();

      cartHistory.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return CartHistoryItem.fromFirestore(data); // Use the factory method to handle date
      }).toList();
    } catch (e) {
      print("Error fetching cart history: $e");
    }
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
        snackPosition: SnackPosition.TOP,
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
    // Remove the item from the cart
    cartItems.remove(cartItem);

    // Update the stock in Firestore by setting the stock to the original quantity.
    updateStock(cartItem.medicine.id, cartItem.medicine.quantity);

    // Refresh the medicines list to reflect the updated stock
    fetchMedicines();
  }

// Update stock and optionally name of a medicine for the logged-in user
  Future<void> updateStock(String medicineId, int newStock, {String? newName}) async {
    try {
      // Get the current logged-in user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Prepare the update data
      final updateData = <String, dynamic>{
        'quantity': newStock,
      };

      // If a new name is provided, add it to the update data
      if (newName != null && newName.isNotEmpty) {
        updateData['medicineName'] = newName;
      }

      // Update the medicine document in Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('medicines')
          .doc(medicineId)
          .update(updateData);

      // Refresh the medicine list after updating
      fetchMedicines();

      Get.snackbar(
        "Success",
        "Medicine updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error updating stock or name: $e");
      Get.snackbar(
        "Error",
        "Failed to update medicine: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

  Future<void> updateMedicineDetails(String userId, String medicineId, String newName, int newPrice, int newStock) async {
    try {
      // Reference to the specific medicine document
      final medicineRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('medicines')
          .doc(medicineId);

      // Update the fields
      await medicineRef.update({
        'medicineName': newName,
        'medicinePrice': newPrice,
        'quantity': newStock,
      });

      // Refresh medicines list after updating
      await fetchMedicines();

      Get.snackbar(
        "Success",
        "Medicine details updated successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update medicine details: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


}

// Cart item model
class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, required this.quantity});
}




class CartHistoryItem {
  final String medicineName;
  final int quantity;
  final double price; // Store as int
  final DateTime dateTime;

  CartHistoryItem({
    required this.medicineName,
    required this.quantity,
    required this.price,
    required this.dateTime,
  });

  // Add a method to convert from Firestore data
  factory CartHistoryItem.fromFirestore(Map<String, dynamic> data) {
    DateTime parsedDate;
    if (data['date'] is String) {
      // If it's a string, parse it to DateTime
      parsedDate = DateTime.parse(data['date']);
    } else if (data['date'] is Timestamp) {
      // If it's a Firestore Timestamp, convert it to DateTime
      parsedDate = (data['date'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now(); // Default to current time if invalid
    }

    // Handle price being either int or double
    double parsedPrice = (data['price'] ?? 0).toDouble(); // Convert to int

    return CartHistoryItem(
      medicineName: data['medicineName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: parsedPrice, // Use parsed price as int
      dateTime: parsedDate,
    );
  }

  // Format the date to a readable string
  String get formattedDate {
    return DateFormat('yyyy-MM-dd – HH:mm').format(dateTime); // Customize format as needed
  }
}
