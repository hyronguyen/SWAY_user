import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/Controller/user_controller.dart';

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
  bool _isLoading = false;
  String? _customerId;

  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _customerId = prefs.getString("customer_id"); // Đọc đúng kiểu String
    });

    print("DEBUG: customer_id = $_customerId"); // Kiểm tra giá trị
  }

  void _onChangePasswordPressed() {
    if (_customerId == null) {
      _showSnackbar('Không tìm thấy ID khách hàng!', Colors.red);
      return;
    }

    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackbar('Vui lòng nhập đầy đủ thông tin!', Colors.red);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackbar('Mật khẩu xác nhận không khớp!', Colors.red);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackbar('Mật khẩu phải có ít nhất 6 ký tự!', Colors.red);
      return;
    }

    _changePassword();
  }

  /// 🔥 Gửi yêu cầu đổi mật khẩu
  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    print("DEBUG: customer_id = $_customerId"); // Kiểm tra giá trị ID
    print("DEBUG: token = $token"); // Kiểm tra token có null không
    if (token == null) {
      _showSnackbar("Bạn chưa đăng nhập!", Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    print("DEBUG: customer_id = $_customerId"); // Kiểm tra giá trị

    final response = await _userController.apiChangePassword(
      _customerId ?? "", // Giữ nguyên String
      _oldPasswordController.text,
      _newPasswordController.text,
      _confirmPasswordController.text,
      token,
    );

    _showSnackbar(response["message"],
        response["status"] == "success" ? Colors.green : Colors.red);

    if (response["status"] == "success") {
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đổi mật khẩu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _onChangePasswordPressed,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
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
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: () => onVisibilityChanged(!isPasswordVisible),
          ),
        ),
      ),
    );
  }
}
