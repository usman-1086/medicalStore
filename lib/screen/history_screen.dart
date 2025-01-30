import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/medicine_controller.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final MedicineController medicineController = Get.find();
  final TextEditingController searchController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  double totalSales = 0.0;

  void calculateTotalSales() {
    final filteredHistory = medicineController.cartHistory.where((historyItem) {
      return (startDate == null || historyItem.dateTime.isAfter(startDate!)) &&
          (endDate == null || historyItem.dateTime.isBefore(endDate!));
    }).toList();

    totalSales = filteredHistory.fold(0.0, (sum, item) => sum + item.price);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: "Search by Date (DD:MM:YYYY)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                          calculateTotalSales();
                        }
                      },
                      child: Text(startDate == null ? "Start Date" : DateFormat('dd-MM-yyyy').format(startDate!)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => endDate = picked);
                          calculateTotalSales();
                        }
                      },
                      child: Text(endDate == null ? "End Date" : DateFormat('dd-MM-yyyy').format(endDate!)),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text("Total Sales: Rs $totalSales", style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: medicineController.fetchCartHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return Obx(() {
                  final filteredHistory = medicineController.cartHistory.where((historyItem) {
                    final formattedDate = DateFormat('dd:MM:yyyy').format(historyItem.dateTime);
                    return searchController.text.isEmpty || formattedDate.contains(searchController.text);
                  }).toList();

                  if (filteredHistory.isEmpty) {
                    return Center(
                      child: Text(
                        "No history available.",
                        style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final historyItem = filteredHistory[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.015,
                            horizontal: screenWidth * 0.04,
                          ),
                          title: Text(
                            historyItem.medicineName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.05,
                              color: Colors.blueAccent,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.005),
                              Text("Quantity: ${historyItem.quantity}",
                                  style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700])),
                              SizedBox(height: screenHeight * 0.005),
                              Text("Price: Rs ${historyItem.price}",
                                  style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.green)),
                              SizedBox(height: screenHeight * 0.005),
                              Text("Date: ${historyItem.formattedDate}",
                                  style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[600])),
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
          ),
        ],
      ),
    );
  }
}