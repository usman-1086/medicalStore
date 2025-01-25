import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medicalstore/screen/home_screen.dart';
import 'package:medicalstore/screen/login_screen.dart';
import 'package:medicalstore/screen/main_screen.dart';
import 'controller/auth_controller.dart';
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Store',
      theme: ThemeData(
        useMaterial3: true,
      ),
      // Define routes for named navigation
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
      home: AuthHandler(), // Handle initial screen dynamically
    );
  }
}

class AuthHandler extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to check the current authentication state
    return FutureBuilder(
      future: authController.checkAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Loading indicator
        } else if (snapshot.hasData && snapshot.data == true) {
          // User is logged in
          return MainScreen();
        } else {
          // User is not logged in
          return LoginScreen();
        }
      },
    );
  }
}
