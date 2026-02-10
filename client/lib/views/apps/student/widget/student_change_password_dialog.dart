import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordDialog extends StatefulWidget {
  // Returns true if success, false if failed (e.g. history check)
  final Future<bool> Function(String newPassword) onConfirm;

  const ChangePasswordDialog({super.key, required this.onConfirm});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  
  // Basic validation state (for illustration, or could use Form)
  String? _errorText;

  // Regex for strong password:
  // At least 1 upper, 1 lower, 1 digit, 1 special char, min 8 length (implied by content)
  final RegExp _passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[_@$!%*?&]).{8,}$');

  Future<void> _submit() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    
    setState(() => _errorText = null);

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() {
        _errorText = "Fields cannot be empty";
      });
      return;
    }

    if (newPass != confirmPass) {
      setState(() {
        _errorText = "Passwords do not match";
      });
      return;
    }

    if (!_passwordRegex.hasMatch(newPass)) {
      setState(() {
        _errorText = "Password must use Caps, Small, Number & Symbols (_@\$)";
      });
      return;
    }

    // Check history (would normally need an instance of UserService, pass it or use locator)
    // For this context, we'll assume the callback handles it OR we add the check here if we had access.
    // However, the cleanest way without refactoring everything is to assume onConfirm does the check or we pass service.
    // Given the previous setup, SettingsPage has _userService.
    // Let's pass a validator callback or do it in the parent? 
    // User requested "in the password validation". 
    // Let's modify the widget to accept a validator Future.
    
    // Changing approach: Update widget to accept a validator.
    // But since I can't easily change the constructor across files efficiently in one go without causing errors if I miss one,
    // I check if I can access UserService here. I cannot directly without passing it.
    // I will modify the widget constructor in the next step or assume the parent passes a validation function.
    
    // Wait, the prompt asked to "proceed fast". 
    // I will implement the regex first here. The history check requires async validation from the parent.
    // I will change the logic to call a new `validatePassword` prop if it exists, or update `onConfirm` to return a result?
    // Let's update `onConfirm` to be `Future<bool> Function(String)`.
    
    bool success = await widget.onConfirm(newPass);
    if (success) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 514,
        constraints: const BoxConstraints(minHeight: 425),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Change Your Password",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to change?",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel("New Password *"),
              const SizedBox(height: 8),
              _buildPasswordField(_newPasswordController, _obscureNew, () {
                setState(() => _obscureNew = !_obscureNew);
              }),

              const SizedBox(height: 16),

              _buildLabel("Confirm Password *"),
               const SizedBox(height: 8),
              _buildPasswordField(_confirmPasswordController, _obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),

              if (_errorText != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorText!,
                  style: GoogleFonts.inter(color: Colors.red, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildButton("Cancel", Colors.grey[200]!, Colors.black, () => Navigator.of(context).pop()),
                  const SizedBox(width: 16),
                  _buildButton("Confirm", Colors.black, Colors.white, _submit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          text: text.replaceAll(" *", ""),
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
          children: [
             TextSpan(text: " *", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "**********",
          hintStyle: TextStyle(color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color bg, Color textCb, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: textCb,
        elevation: 0,
        fixedSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        text, 
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
