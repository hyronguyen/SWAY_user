import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ngôn ngữ',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/vietnamflag.png',
              width: 80,
              height: 50,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              'Ngôn ngữ hiện tại:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tiếng Việt',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Ứng dụng sử dụng Tiếng Việt để mang đến trải nghiệm dễ dàng và tiện lợi cho người dùng.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '"Trải nghiệm dịch vụ nhanh chóng và tiện lợi với Tiếng Việt"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 30),
            Icon(
              Icons.language,
              color: Colors.blueAccent,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
