import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SetPasswordScreen extends StatefulWidget {
  ////////////////////////////// Biến Widgets ///////////////////////////////////////////////////////////////
  final String userId;
  final String name;
  final String mail;
  final String? gender;
  final String phoneNumber;

  const SetPasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.mail,
    required this.gender,
    required this.userId,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  ////////////////////////////// Biến cục bộ ///////////////////////////////////////////////////////////////
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool obscureText = true;
  static const String secretKey = "12345678901234567890123456789012";
  static const String ivKey = "1234567890123456";


////////////////////////////// LAYOUT ///////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thiết lập mật khẩu"),
        centerTitle: true,
        automaticallyImplyLeading: false
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
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(), // Viền mặc định
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0), // Viền xanh khi focus
                  borderRadius: BorderRadius.circular(8.0),
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
              decoration: InputDecoration(
                labelText: "Xác nhận mật khẩu",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(), // Viền mặc định
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0), // Viền xanh khi focus
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),


            const SizedBox(height: 15),

            // Gợi ý tạo mật khẩu mạnh
            const Text(
              "⚡ Gợi ý tạo mật khẩu mạnh:",
              style: TextStyle(fontWeight: FontWeight.bold, color:  Color(0xFFedae10)),
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
                      onPressed: savePassword,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          backgroundColor: Color(0xFFedae10), // Đổi màu nền nút
                          foregroundColor: Colors.white, // Đổi màu chữ trên nút
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bo tròn viền nút
                          ),
                      ),
                      child: const Text("Xác nhận", style: TextStyle(fontSize: 16)),
                    ),
            ),
            
          ],
        ),
      ),
    );
  }

////////////////////////////// Function ///////////////////////////////////////////////////////////////
  // Mã hoá mật khẩu
  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8(secretKey);
    final iv = encrypt.IV.fromUtf8(ivKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Lưu mật khẩu
  Future<void> savePassword() async {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu phải có ít nhất 8 ký tự")),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String encryptedPassword = encryptPassword(password);
      await FirebaseFirestore.instance.collection("USERS").doc(widget.userId).set({
        "user_password": encryptedPassword,
        "user_name": widget.name,
        "user_phone": widget.phoneNumber,
        "user_gender": widget.gender,
        "user_mail": widget.mail,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu đã được thiết lập thành công!")),
      );

      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
