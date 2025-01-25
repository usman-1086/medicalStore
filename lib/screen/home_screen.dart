import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medicalstore/controller/auth_controller.dart';
import 'package:medicalstore/controller/medicine_controller.dart';
import '../data/models/medicine.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  final MedicineController medicineController = Get.put(MedicineController());
  final AuthController authController = Get.put(AuthController());
  final TextEditingController searchController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: authController.logout,
          ),
        ],
        title: Text("Medicine Inventory"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.only(bottom: height * 0.02),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by name, salt, or company",
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  medicineController.updateFilteredMedicines(query);
                },
              ),
            ),

            // Medicine List
            Expanded(
              child: Obx(() {
                final medicines = medicineController.filteredMedicines;
                return ListView.builder(
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return GestureDetector(
                      onLongPress: () {
                        _showMedicineOptionsDialog(context, medicine);
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: height * 0.02),
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.03),
                          child: Row(
                            children: [
                              SizedBox(width: width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine.medicineName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * 0.045,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      "${medicine.medicineCompany} - \Rs ${medicine.medicinePrice}",
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: width * 0.035,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      "Stock: ${medicine.quantity}",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: width * 0.03),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                                    onPressed: () {
                                      _showQuantityDialog(context, medicine);
                                    },
                                    tooltip: "Add to Cart",
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.orangeAccent),
                                    onPressed: () {
                                      _showUpdateStockDialog(context, medicine);
                                    },
                                    tooltip: "Edit Stock",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Button to navigate to CartScreen
            SizedBox(height: height * 0.1), // Spacing to avoid overlap with FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddMedicineDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  // Show dialog to input quantity for adding medicine to the cart
  Future<void> _showQuantityDialog(BuildContext context, Medicine medicine) async {
    final quantityController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Quantity for ${medicine.medicineName}"),
          content: TextField(
            controller: quantityController,
            decoration: InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity > 0 && quantity <= medicine.quantity) {
                  medicineController.addToCart(medicine, quantity);
                  Get.back();
                } else {
                  Get.snackbar("Invalid quantity", "Please enter a valid quantity.");
                }
              },
              child: Text("Add to Cart"),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to update stock and price of the medicine
  Future<void> _showUpdateStockDialog(BuildContext context, Medicine medicine) async {
    final priceController = TextEditingController(text: medicine.medicinePrice.toString());
    final stockController = TextEditingController(text: medicine.quantity.toString());

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Price and Stock for ${medicine.medicineName}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: "New Price"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: "New Stock Quantity"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final newPrice = int.tryParse(priceController.text);
                final newStock = int.tryParse(stockController.text);
                if (newPrice != null && newStock != null) {
                  updateMedicinePriceAndQuantity(
                    authController.currentUser?.uid ?? '',
                    medicine.id,
                    newPrice,
                    newStock,
                  );
                  Get.back();
                } else {
                  Get.snackbar("Invalid Input", "Please enter valid price and stock.");
                }
              },
              child: Text("Update Stock"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddMedicineDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final companyController = TextEditingController();
    final saltController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Medicine"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: "Medicine Name")),
                TextField(controller: companyController, decoration: InputDecoration(labelText: "Medicine Company")),
                TextField(controller: saltController, decoration: InputDecoration(labelText: "Salt Name")),
                TextField(controller: priceController, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                TextField(controller: quantityController, decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final company = companyController.text.trim();
                final salt = saltController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                final quantity = int.tryParse(quantityController.text.trim()) ?? 0;

                if (name.isNotEmpty && company.isNotEmpty && price > 0 && quantity > 0) {
                  medicineController.addMedicine(Medicine(
                    medicineName: name,
                    medicineCompany: company,
                    medicineSalt: salt,
                    medicinePrice: price,
                    quantity: quantity,
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                  ));
                  Get.back();
                } else {
                  Get.snackbar("Invalid Input", "Please fill in all fields correctly.");
                }
              },
              child: Text("Add Medicine"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateMedicinePriceAndQuantity(String uid, String medicineId, int newPrice, int newStock) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('medicines')
          .doc(medicineId)
          .update({'medicinePrice': newPrice, 'quantity': newStock});

      Get.snackbar("Medicine Updated", "Price and stock updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Error updating medicine: $e");
    }
  }

  Future<void> _showMedicineOptionsDialog(BuildContext context, Medicine medicine) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Options for ${medicine.medicineName}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showUpdateStockDialog(context, medicine);
                  Get.back();
                },
                child: Text("Update Stock"),
              ),
              ElevatedButton(
                onPressed: () {
                  medicineController.deleteMedicine(medicine.id);
                  Get.back();
                },
                child: Text("Delete Medicine"),
              ),
            ],
          ),
        );
      },
    );
  }
}
