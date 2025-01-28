import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../data/repositories/auth_repository.dart';
import '../screen/login_screen.dart';
import '../screen/main_screen.dart';
import 'medicine_controller.dart';
class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  final AuthRepository _authRepository = AuthRepository();

  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    // Listen to the Firebase auth state changes to check if the user is logged in
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        isLoggedIn(true); // User is logged in
        // Fetch the medicines for the current logged-in user
        Get.find<MedicineController>().fetchMedicines();
      } else {
        isLoggedIn(false); // User is logged out
        // Reset medicines when user logs out
        Get.find<MedicineController>().resetMedicines();
      }
    });
  }

  // Login method
  Future<void> login(String email, String password) async {
    try {
      final user = await _authRepository.login(email, password);
      if (user != null) {
        isLoggedIn(true);
        Get.find<MedicineController>().fetchMedicines();
        // Use Get.offAll(MainScreen()) to navigate and remove previous screens from stack
        Get.offAll(() => MainScreen());  // Replaces the previous screen with MainScreen
      }
    } catch (e) {
      Get.snackbar("Login Failed", "Unexpected error occurred.");
    }
  }
  // Logout method
  Future<void> logout() async {
    await _authRepository.logout();
    isLoggedIn(false);
    Get.find<MedicineController>().resetMedicines(); // Reset medicines on logout
    Get.offAll(LoginScreen()); // Navigate to login screen
  }

  Future<bool> checkAuthState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        isLoggedIn.value = true;
        return true;
      } else {
        isLoggedIn.value = false;
        return false;
      }
    } catch (e) {
      isLoggedIn.value = false;
      return false;
    }
  }

}
