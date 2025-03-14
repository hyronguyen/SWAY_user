import 'package:flutter/material.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/mainpage.dart';
import 'package:sway/page/authentication/signup.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:http/http.dart' as http; // Import HTTP for API calls

class LoginScreen extends StatelessWidget {
  ////////////////////////////// BIẾN WIDGETS  ////////////////////////////////////////////////////////
  final TextEditingController emailController = TextEditingController(); // Changed to emailController
  final TextEditingController passwordController = TextEditingController();
  final UserController userController = UserController(); // Khởi tạo Usercontroller

  LoginScreen({super.key});

  ////////////////////////////// LAYOUT  ////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/images/logo.png'),
              const SizedBox(height: 20),

              // Field email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress, // Update for email input
                decoration: const InputDecoration(
                  labelText: "Email", // Changed label to "Email"
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
                  ),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Field mật khẩu
              TextField(
                controller: passwordController,
                obscureText: true, // Ẩn mật khẩu
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
                  ),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              // Nút đăng nhập
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => MakeLogin(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Color(0xFFedae10), // Đổi màu nền nút
                    foregroundColor: Colors.white, // Đổi màu chữ trên nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo tròn viền nút
                    ),
                  ),
                  child: const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),
              // Divider và chữ "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10), // Khoảng cách giữa Divider và chữ "or"
                    child: Text(
                      "or",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.white, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Đăng nhập bằng mạng xã hội
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1), // Viền trắng
                      borderRadius: BorderRadius.circular(8), // Góc bo tròn nhẹ
                    ),
                    child: IconButton(
                      onPressed: () {
                        debugPrint("Đăng nhập với Facebook");
                      },
                      icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        debugPrint("Đăng nhập với Apple");
                      },
                      icon: const Icon(Icons.apple, color: Colors.white, size: 40),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        debugPrint("Đăng nhập với Google");
                      },
                      icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chuyển đến trang đăng ký
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) => SignupScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Đi từ bên phải vào
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Chưa có tài khoản? ",
                        style: TextStyle(color: Colors.white), // Màu trắng cho phần đầu
                      ),
                      TextSpan(
                        text: "Đăng ký ở đây",
                        style: TextStyle(color: Color(0xFFedae10), fontWeight: FontWeight.bold), // Màu vàng cho phần sau
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    ////////////////////////////// FUNCTION  ////////////////////////////////////////////////////////
    void MakeLogin(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    // Gửi yêu cầu đăng nhập với email và mật khẩu
    Map<String, dynamic>? responseData = await userController.login(email, password); // Lấy dữ liệu trả về

    if (!context.mounted) return;

    // Kiểm tra xem responseData có null không và có chứa key 'token' và 'customer'
    if (responseData != null &&
        responseData.containsKey('token') &&
        responseData.containsKey('customer')) {
      // Lấy token và customer_id từ responseData
      String token = responseData['token']; // Lấy token
      String customerId = responseData['customer']['CUSTOMER_ID'].toString(); // Lấy CUSTOMER_ID từ customer

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đăng nhập thành công!")),
      );

      // Lưu token và customer_id vào SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);  // Lưu token
      await prefs.setString("customer_id", customerId);  // Lưu customer_id

      // Chuyển đến trang chính
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => Mainpage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Đi từ bên phải vào
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      // Nếu không có dữ liệu hợp lệ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Email hoặc mật khẩu không đúng!")),
      );
    }
  }
}
