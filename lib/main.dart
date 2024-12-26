import 'package:flutter/material.dart';

import 'ui/signup/signup.dart';

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
        scaffoldBackgroundColor: Colors.black
      ),
      home: const SignupScreen(),
    );
  }
}

