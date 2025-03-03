import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/methods/common_methods.dart';
import 'package:sway/page/authentication/login.dart';

class SignupEmailVerifyScreen extends StatefulWidget {
  final String email;

  const SignupEmailVerifyScreen({
    super.key,
    required this.email,
  });

  @override
  State<SignupEmailVerifyScreen> createState() => _SignupEmailVerifyScreenState();
}

class _SignupEmailVerifyScreenState extends State<SignupEmailVerifyScreen> {
  TextEditingController otpController = TextEditingController();
  final CommonMethods commonMethods = CommonMethods();
  String? verificationId; 
  Timer? _timer;
  int _start = 300; 
  bool canResendOtp = false;
  final UserController userController = UserController(); 

  @override
  void initState() {
    super.initState();
    _startTimer(); 
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(_start); 

    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực Email'), centerTitle: true),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.email, size: 80, color: Color(0xFFedae10)),
                const SizedBox(height: 20),
                Text(
                  "Kiểm tra email của bạn để xác thực.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 16, color: Color(0xFFedae10)),
                ),
                const SizedBox(height: 5),
                Text(
                  "Mã có hiệu lực trong vòng $formattedTime ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                // Nhập mã xác thực
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Mã xác thực",
                    border: OutlineInputBorder(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Hiển thị "Vui lòng đợi" kèm thời gian

                    const SizedBox(width: 10), // Giữa 2 phần tử
                    // Nút gửi lại mã
                    TextButton(
                      onPressed: canResendOtp ? resendEmailVerification : null,
                      child: Text(
                        "Gửi lại mã xác thực",
                        style: TextStyle(fontSize: 16, color: canResendOtp ? Colors.white : Colors.grey),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                // Nút xác nhận
                ElevatedButton(
                  onPressed: verifyEmail,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    backgroundColor: Color(0xFFedae10), // Đổi màu nền nút
                    foregroundColor: Colors.white, // Đổi màu chữ trên nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Bo tròn viền nút
                    ),
                  ),
                  child: const Text("Xác nhận", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> verifyEmail() async {
    String otp = otpController.text.trim();

    // Kiểm tra nếu mã OTP trống
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập mã xác thực")),
      );
      return;
    }

    // Gọi phương thức verifyOtp từ UserController (hoặc nơi bạn định nghĩa verifyOtp)
    bool isVerified = await userController.verifyOtp(widget.email, otp);

    if (isVerified) {
      // Nếu mã OTP đúng, hiển thị thông báo xác thực thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Xác thực thành công!")),
      );

      // Chuyển hướng đến trang tiếp theo sau khi xác thực thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Thay NextScreen() bằng trang bạn muốn chuyển đến
      );
    } else {
      // Nếu mã OTP sai, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã xác thực không đúng. Vui lòng thử lại.")),
      );
    }
  }


  Future<void> resendEmailVerification() async {
    bool signupSuccess = await userController.resendOtp(widget.email);
    
    if (signupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã xác thực đã được gửi lại qua email!")),
      );
      setState(() {
        canResendOtp = false;
      });
      _startTimer();  // Reset lại đồng hồ đếm ngược
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xảy ra lỗi khi gửi mã OTP.")),
      );
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _start = 300; 

    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() {
          canResendOtp = true; 
        });
        timer.cancel(); 
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel(); 
  }
}
