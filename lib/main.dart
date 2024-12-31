import 'package:flutter/material.dart';

import 'ui/signup/signup.dart';
import 'ui/login/login.dart'; // Đảm bảo đã import màn hình login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Điểm khởi đầu App
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sway',
      debugShowCheckedModeBanner: false,
      // Chỉnh theme của app
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      initialRoute: '/', 
      routes: {
        '/signup': (context) => const SignupScreen(), // Trang đăng ký
        '/': (context) => LoginScreen(), // Trang đăng nhập
      },
    );
  }
}
