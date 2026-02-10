import 'package:get/get.dart';
import 'package:binary_success/services/user_service.dart';

class StudentSettingsController extends GetxController {
  final UserService _userService = UserService();

  var isLoading = true.obs;
  var userProfile = Rxn<UserProfile>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final profile = await _userService.getUserProfile();
      userProfile.value = profile;
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkPasswordHistory(String password) async {
    return await _userService.checkPasswordHistory(password);
  }

  Future<void> updatePassword(String newPassword) async {
    await _userService.updatePassword(newPassword);
  }
}
