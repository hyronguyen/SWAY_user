import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập'),automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Image.asset(
              'assets/images/logo.png'
            ),
            
            TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
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
            
            //Field số điện thoại
            TextField(
                      controller: passwordController,
                      keyboardType: TextInputType.phone,
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
                        onPressed: () {
                          // Logic khi nhấn nút Đăng ký
                          debugPrint("[login]password: ${passwordController.text}");
                          debugPrint("[login]Số điện thoại: ${phoneController.text}");
                          
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: const Color(0xFFedae10),
                          foregroundColor: Colors.white, // Màu chữ
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text("Đăng nhập"),
                      ),
                    ),
                    
                  const SizedBox(height: 20),

                   const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Facebook");
                        },
                        icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
                      ),
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Apple");
                        },
                        icon: const Icon(Icons.apple, color: Colors.white, size: 40),
                      ),
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Google");
                        },
                        icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Bạn chưa có tài khoản? ",
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: "Đăng ký ngay",
                            style: const TextStyle(
                              color: Color(0xFFedae10),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            Navigator.pushNamed(context, '/signup'); 
                          },
                          
                          ),
                        ],
                      ),
                    ),
                  ),
           
          ],
        ),
      ),
    );
  }
}
