import 'package:flutter/material.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/data/model/user.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/authentication/signup_email_verify.dart'; // Đảm bảo có màn hình LoginScreen

class SetPasswordScreen extends StatefulWidget {
  final String fullname;
  final String email;
  final String? gender;
  final String phone;
  final String birthday;

  const SetPasswordScreen({
    super.key,
    required this.phone,
    required this.fullname,
    required this.email,
    required this.gender,
    required this.birthday,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;
  final UserController userController =
      UserController(); // Khởi tạo Usercontroller

  // Hàm đăng ký người dùng
  Future<void> SignUp() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Kiểm tra nếu mật khẩu và xác nhận mật khẩu không trùng khớp
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Mật khẩu và xác nhận mật khẩu không khớp")),
      );
      return;
    }

    // Kiểm tra độ dài mật khẩu (ví dụ: phải ít nhất 8 ký tự)
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải có ít nhất 8 ký tự")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Dữ liệu người dùng để gửi API (không mã hóa mật khẩu vì bạn đã mã hóa ở backend)
      User userData = User(
        fullname: widget.fullname,
        email: widget.email,
        phone: widget.phone,
        gender: widget.gender,
        birthday: widget.birthday,
        password: password, // Sử dụng mật khẩu trực tiếp (không mã hóa)
      );

      // Gọi API signUp (Giả sử bạn có một hàm `signUp` trong UserController để gọi API backend)
      bool signupSuccess = await userController.signUp(userData);

      if (signupSuccess) {
        // Nếu đăng ký thành công, điều hướng người dùng đến màn hình đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SignupEmailVerifyScreen(
                  email: widget.email)), // Chuyển hướng về trang đăng nhập
        );
      } else {
        // Nếu có lỗi khi đăng ký
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thất bại. Vui lòng thử lại.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra. Vui lòng thử lại.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm kiểm tra email
  bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Hàm kiểm tra số điện thoại
  bool isValidPhone(String phone) {
    final RegExp regex =
        RegExp(r'^\d{10,11}$'); // Kiểm tra số điện thoại có 10-11 chữ số
    return regex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thiết lập mật khẩu"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tạo mật khẩu mới",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Ô nhập mật khẩu mới
            TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: "Mật khẩu mới",
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(), // Viền mặc định
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white, width: 2.0), // Viền xanh khi focus
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Ô nhập xác nhận mật khẩu
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Xác nhận mật khẩu",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(), // Viền mặc định
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white, width: 2.0), // Viền xanh khi focus
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Gợi ý tạo mật khẩu mạnh
            const Text(
              "⚡ Gợi ý tạo mật khẩu mạnh:",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFedae10)),
            ),
            const SizedBox(height: 5),
            const Text(
              "• Sử dụng ít nhất 8 ký tự.\n"
              "• Bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.\n"
              "• Tránh sử dụng thông tin cá nhân dễ đoán.\n",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: SignUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        backgroundColor:
                            const Color(0xFFedae10), // Đổi màu nền nút
                        foregroundColor: Colors.white, // Đổi màu chữ trên nút
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bo tròn viền nút
                        ),
                      ),
                      child: const Text("Xác nhận",
                          style: TextStyle(fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
