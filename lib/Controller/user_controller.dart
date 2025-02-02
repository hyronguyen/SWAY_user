import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt; 

class Usercontroller {
  ////////////////////////////// BIẾN CỤC BỘ //////////////////////////////////////
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String secretKey = "12345678901234567890123456789012";
  static const String ivKey = "1234567890123456";
  
////////////////////////////// SUB-FUNCTION //////////////////////////////////////
  String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8(secretKey);
    final iv = encrypt.IV.fromUtf8(ivKey);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    try {
      return encrypter.decrypt64(encryptedPassword, iv: iv); // Trả về mật khẩu gốc
    } catch (e) {
      debugPrint("Lỗi giải mã mật khẩu: $e");
      return ""; // Trả về chuỗi rỗng nếu lỗi
    }
  }

////////////////////////////// CONTROLLER FUNCTION ///////////////////////////////
  //Con_kiểm tra đăng nhập
  Future<bool> login(String phoneNumber, String password) async {
    
    
    try {
      // 🔍 Tìm người dùng theo số điện thoại
      var querySnapshot = await _firestore
          .collection("USERS")
          .where("user_phone", isEqualTo: phoneNumber)
          .limit(1) // Lấy 1 kết quả đầu tiên
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint("Không tìm thấy tài khoản với số điện thoại này.");
        return false; // Không tìm thấy tài khoản
      }

      var userDoc = querySnapshot.docs.first.data();
      String encryptedPassword = userDoc["user_password"]; // Lấy mật khẩu đã mã hóa

      // 🔓 Giải mã mật khẩu
      String decryptedPassword = decryptPassword(encryptedPassword);

      // 🔍 Kiểm tra mật khẩu
      if (decryptedPassword == password) {
        debugPrint("Đăng nhập thành công!");
        return true;
      } else {
        debugPrint("Sai mật khẩu!");
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi khi đăng nhập: $e");
      return false;
    }
  }
 
  //Con_Kiểm tra số điện thoại đã tồn tẠi
  Future<bool> checkExistPhone(String phoneNumber) async {
    try {
      // Truy vấn collection USERS, kiểm tra có document nào có field user_phone = phoneNumber không
      var querySnapshot = await _firestore
          .collection("USERS")
          .where("user_phone", isEqualTo: phoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty; // Trả về true nếu có ít nhất 1 kết quả
    } catch (e) {
      debugPrint("Lỗi khi kiểm tra số điện thoại: $e");
      return false; // Trả về false trong trường hợp lỗi
    }
  }
}
