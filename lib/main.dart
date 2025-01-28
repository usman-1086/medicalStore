import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicalstore/screen/history_screen.dart';
import 'package:medicalstore/screen/home_screen.dart';
import 'package:medicalstore/screen/login_screen.dart';
import 'package:medicalstore/screen/main_screen.dart';
import 'controller/auth_controller.dart';
import 'controller/medicine_controller.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MedicineController());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Store',
      theme: ThemeData(
        useMaterial3: true,
      ),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/history': (context) => HistoryScreen(),
        '/main': (context) => MainScreen(),

      },
      home: AuthHandler(), // Handle initial screen dynamically
    );
  }
}

class AuthHandler extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authController.isLoggedIn.value) {
        // If logged in, show MainScreen with the bottom navigation bar
        return MainScreen();
      } else {
        // If not logged in, show LoginScreen
        return LoginScreen();
      }
    });
  }
}
