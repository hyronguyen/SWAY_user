import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Old password field
            _buildPasswordField(
              controller: _oldPasswordController,
              hintText: 'Mật khẩu cũ',
              isPasswordVisible: _isOldPasswordVisible,
              onVisibilityChanged: (value) {
                setState(() {
                  _isOldPasswordVisible = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // New password field
            _buildPasswordField(
              controller: _newPasswordController,
              hintText: 'Mật khẩu mới',
              isPasswordVisible: _isNewPasswordVisible,
              onVisibilityChanged: (value) {
                setState(() {
                  _isNewPasswordVisible = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Confirm password field
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: 'Xác nhận mật khẩu',
              isPasswordVisible: _isConfirmPasswordVisible,
              onVisibilityChanged: (value) {
                setState(() {
                  _isConfirmPasswordVisible = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Change password button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _validateAndChangePassword,
                child: const Text(
                  'Thay đổi mật khẩu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isPasswordVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () => onVisibilityChanged(!isPasswordVisible),
          ),
        ),
      ),
    );
  }

  void _validateAndChangePassword() {
    // Get the values
    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (newPassword != confirmPassword) {
      _showError('Mật khẩu mới không khớp');
      return;
    }

    // TODO: Implement password change logic
    // If successful:
    _showSuccess('Đổi mật khẩu thành công');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}