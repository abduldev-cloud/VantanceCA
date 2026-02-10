import 'dart:convert';

class UserProfile {
  final String name;
  final String email;

  UserProfile({required this.name, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
    );
  }
}

class UserService {
  // Mock Data
  static const String _mockUserJson = '{"name": "Arun Kumar", "email": "arunkumar@gmail.com"}';

  Future<UserProfile> getUserProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    final Map<String, dynamic> data = jsonDecode(_mockUserJson);
    return UserProfile.fromJson(data);
  }

  Future<void> updatePassword(String newPassword) async {
    // Simulate backend call
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Construct JSON payload
    final Map<String, dynamic> payload = {
      "newPassword": newPassword,
      // In a real app, you might send currentPassword too, or use a token
    };

    print("Sending Password Update to Backend: ${jsonEncode(payload)}");
  }

  Future<bool> checkPasswordHistory(String password) async {
    // Simulate backend call
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Mock logic: reject "OldPassword1@" as the last used password
    if (password == "OldPassword1@") {
      return true; // Found in history
    }
    return false;
  }
}
