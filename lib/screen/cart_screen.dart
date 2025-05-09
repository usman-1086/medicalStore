import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/medicine_controller.dart';

class CartScreen extends StatelessWidget {
  final MedicineController medicineController = Get.find();

  @override
  Widget build(BuildContext context) {
    // Get screen width and height using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Adjustments for large screens like laptops or desktops
    if (screenWidth > 1024) {
      screenWidth = 1024; // Set a max width limit for very large screens
    }

    // Dynamic font size based on screen width
    double fontSizeFactor = screenWidth > 800 ? 0.035 : 0.05;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Colors.blueAccent, // AppBar color
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // Padding relative to screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart Items List
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: medicineController.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = medicineController.cartItems[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.02), // Margin relative to screen height
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(screenWidth * 0.03), // Padding relative to screen width
                        title: Text(
                          cartItem.medicine.medicineName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * fontSizeFactor, // Adjust font size dynamically
                          ),
                        ),
                        subtitle: Text(
                          'Quantity: ${cartItem.quantity} - Total: \Rs ${cartItem.medicine.medicinePrice * cartItem.quantity}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: screenWidth * (fontSizeFactor - 0.005), // Slightly smaller for subtitle
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_shopping_cart),
                          onPressed: () {
                            medicineController.removeFromCart(cartItem);
                            Get.snackbar(
                              "Item Removed",
                              "${cartItem.medicine.medicineName} has been removed from the cart",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: Duration(seconds: 2),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Total Bill Display
            Obx(() {
              final total = medicineController.cartItems.fold<double>(0, (previousValue, cartItem) {
                return previousValue + (cartItem.medicine.medicinePrice * cartItem.quantity);
              });

              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03), // Vertical padding relative to screen height
                child: Text(
                  "Total Bill: \Rs $total",
                  style: TextStyle(
                    fontSize: screenWidth * (fontSizeFactor + 0.01), // Slightly larger font size for total
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              );
            }),

            // Done Button
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.03), // Bottom padding relative to screen height
              child: ElevatedButton(
                onPressed: () async {
                  // Save cart items to history
                  await medicineController.saveCartToFirestore();

                  // Clear the cart after printing
                  medicineController.clearCart();

                  Get.snackbar(
                    "Cart Cleared",
                    "Your cart has been saved to history and the receipt has been printed.",
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 2),
                  );
                  // Get.toNamed('/history'); // Navigate to the History screen
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.1,
                  ),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontSize: screenWidth * fontSizeFactor, // Adjusted font size for the button text
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
