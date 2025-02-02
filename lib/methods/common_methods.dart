import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommonMethods {
////////////////////////////// METHOD FUNCTION //////////////////////////////////////
  Future<void> sendOtp(String phoneNumber, Function(String, int?) onCodeSent) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    timeout: const Duration(seconds: 60),
    verificationCompleted: (PhoneAuthCredential credential) async {
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint("Xác thực tự động thành công!");
    },
    verificationFailed: (FirebaseAuthException e) {
      debugPrint("Lỗi gửi OTP: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      debugPrint("Mã OTP đã gửi đến: $phoneNumber");
      onCodeSent(verificationId, resendToken);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      debugPrint("Hết thời gian chờ nhập OTP.");
    },
  );
}

}