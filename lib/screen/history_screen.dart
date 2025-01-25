import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/medicine_controller.dart';

class HistoryScreen extends StatelessWidget {
  final MedicineController medicineController = Get.find();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: medicineController.cartHistory.length,
          itemBuilder: (context, index) {
            final historyItem = medicineController.cartHistory[index];
            return ListTile(
              title: Text(
                historyItem.medicineName,
                style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Quantity: ${historyItem.quantity}\nDate: ${historyItem.dateTime}",
                style: TextStyle(fontSize: width * 0.035),
              ),
              isThreeLine: true,
            );
          },
        );
      }),
    );
  }
}
