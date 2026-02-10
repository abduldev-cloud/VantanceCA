class PasswordChangeRequest {
  final String email;
  final String newPassword;

  PasswordChangeRequest({
    required this.email,
    required this.newPassword,
  });

  Map<String, String> toMap() {
    return {
      'email': email,
      'new_password': newPassword,
    };
  }
}

class PasswordChangeResponse {
  final bool success;
  final String message;
  final dynamic data;
  final String? error;

  PasswordChangeResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory PasswordChangeResponse.success(String message, {dynamic data}) {
    return PasswordChangeResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory PasswordChangeResponse.error(String message, {String? error}) {
    return PasswordChangeResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}
