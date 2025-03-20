import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/mainpage.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/home/trip_picker.dart';
import 'package:sway/page/onboarding/onboarding.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundblack, // Nền trắng theo phong cách Apple
      appBar: AppBar(
        title: Text(
          'SWAY LAUNCH OPTIONS',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundblack,
        elevation: 0, // Bỏ bóng cho app bar
        iconTheme: IconThemeData(color: Colors.black), // Màu icon về đen
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton(
                text: "Live",
                color: primary,
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  if (prefs.containsKey('customer_id')) {
                    await prefs
                        .remove('customer_id'); // Xóa customer_id hiện tại
                  }

                  if (prefs.containsKey('customer_data')) {
                    await prefs
                        .remove('customer_data'); // Xóa customer_id hiện tại
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingStart()),
                  );
                },
              ),
              SizedBox(height: 20),
              _buildButton(
                text: "Run Test",
                color: greymenu,
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  if (prefs.containsKey('customer_data')) {
                    await prefs
                        .remove('customer_data'); // Xóa customer_id hiện tại
                  }

                  // Kiểm tra customer_id hiện tại
                  if (prefs.containsKey('customer_id')) {
                    await prefs
                        .remove('customer_id'); // Xóa customer_id hiện tại
                  }

                  // Thiết lập customer_id mới
                  await prefs.setString('customer_id', 'customer_id_test');

                  // Chuyển hướng đến TripPicker()
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TripPicker()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Tăng chiều cao button
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bo góc mềm mại hơn
          ),
          elevation: 2, // Nhẹ nhàng tạo chiều sâu
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
