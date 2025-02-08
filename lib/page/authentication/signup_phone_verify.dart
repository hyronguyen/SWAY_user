import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:sway/methods/common_methods.dart';
import 'package:sway/page/authentication/signup_password.dart';

class SignupPhoneVerifyScreen extends StatefulWidget {
  ////////////////////////////// BIẾN WIDGET  ////////////////////////////////////////////////////////
  final String phoneNumber;
  final String name;
  final String mail;
  final String? gender;

  const SignupPhoneVerifyScreen({
    super.key,
    required this.phoneNumber,
    required this.name,
    required this.mail,
    required this.gender,
  });

  @override
  State<SignupPhoneVerifyScreen> createState() => _SignupPhoneVerifyScreenState();
}

class _SignupPhoneVerifyScreenState extends State<SignupPhoneVerifyScreen> {
  ////////////////////////////// KHAI BÁO BIẾN  ////////////////////////////////////////////////////////
  TextEditingController otpController = TextEditingController();
  final CommonMethods commonMethods = CommonMethods();
  String? verificationId; // Lưu verificationId để xác thực OTP

  @override
  void initState() {
    super.initState();
    sendOtp(); // Gửi OTP ngay khi vào màn hình
  }

////////////////////////////// LAYOUT  ////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác thực OTP'),centerTitle: true,),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.password, size: 80, color:  Color(0xFFedae10) ),
                const SizedBox(height: 20),
                Text(
                  "Nhập mã OTP đã gửi đến",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.phoneNumber,
                  style: TextStyle(fontSize: 16, color: Color(0xFFedae10)),
                ),
                const SizedBox(height: 30),
                Pinput(
                  length: 6, // Firebase OTP là 6 số
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  onCompleted: (pin) => verifyOtp(),
                  defaultPinTheme: PinTheme(
                    height: 50,
                    width: 50,
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: verifyOtp,
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
                const SizedBox(height: 20),
                TextButton(
                  onPressed: sendOtp, // Gửi lại mã OTP
                  child: const Text("Gửi lại mã OTP", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// FUNCTIONS  ////////////////////////////////////////////////////////

// Xác thực OTP nhập vào
  Future<void> verifyOtp() async {
    String otp = otpController.text.trim();

    if (otp.length == 6 && verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xác thực OTP thành công!")),
        );
        debugPrint("SignupPhoneVerifyScreen: Xác thực OTP thành công!");

        Navigator.push( context,
            PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 100),
                      pageBuilder: (context, animation, secondaryAnimation) => SetPasswordScreen(
              userId: userCredential.user!.uid,
              phoneNumber: widget.phoneNumber,
              name: widget.name,
              mail: widget.mail,
              gender: widget.gender,
            ),
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

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã OTP không đúng. Vui lòng thử lại!")),
        );
        debugPrint("SignupPhoneVerifyScreen: Lỗi xác thực OTP: $e");
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã OTP không hợp lệ!")),
      );
    }
  }

  // Gửi OTP
  void sendOtp() {
    commonMethods.sendOtp(widget.phoneNumber, (String verId, int? resendToken) {
      setState(() {
        verificationId = verId;
      });
    });
  }
}
