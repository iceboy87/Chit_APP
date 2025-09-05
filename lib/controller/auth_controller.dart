import 'package:get/get.dart';

import '../firebase_services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final _auth = AuthService();
  final isLoading = false.obs;

  @override
  void onReady() {
    _auth.authChanges.listen((user) {
      if (user == null) {
        Get.offAllNamed(AppRoutes.splashScreen);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    });
    super.onReady();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.login(email, password);
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signup(email, password);
      Get.snackbar('Success', 'Account created. Please login.');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Signup Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() => _auth.logout();
}