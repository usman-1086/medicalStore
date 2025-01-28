import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/medicine_controller.dart';

class HistoryScreen extends StatelessWidget {
  final MedicineController medicineController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: medicineController.fetchCartHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Observe cartHistory updates
          return Obx(() {
            if (medicineController.cartHistory.isEmpty) {
              return Center(child: Text("No history available.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
            }

            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: medicineController.cartHistory.length,
              itemBuilder: (context, index) {
                final historyItem = medicineController.cartHistory[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    title: Text(
                      historyItem.medicineName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text("Quantity: ${historyItem.quantity}", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                        SizedBox(height: 4),
                        Text("Price: Rs ${historyItem.price}", style: TextStyle(fontSize: 14, color: Colors.green)),
                        SizedBox(height: 4),
                        Text("Date: ${historyItem.formattedDate}", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }
}
