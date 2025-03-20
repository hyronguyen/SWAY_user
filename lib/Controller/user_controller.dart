import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/model/user.dart';  

class UserController {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    User user = User(email: email, password: password);

    final response = await apiLogin(user);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      return responseData['data'];  
    } else {
      return null;  
    }
  }

  Future<Map<String, dynamic>?> getCustomer(int customerId, String token) async {
    final response = await apiGetInformationCustomer(customerId, token);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      return responseData;  
    } else {
      print('Lỗi khi gọi API: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> checkEmailAndPhone(String email, String phone) async {
    User user = User(email: email, phone: phone);
    final response = await apiCheckEmailAndPhone(user);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signUp(User user) async {
    final response = await apiSignUp(user);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp_code) async {
    final response = await apiVerifyOtp(email, otp_code);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

    Future<bool> resendOtp(String email) async {
    final response = await apiResendOtp(email);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

Future<http.Response> apiGetInformationCustomer(int customerId, String token) async {
  final String url = 'http://10.0.2.2:8080/api/UserManagement/get-infomation-customer';

  // Kiểm tra token có bị trùng "Bearer " hay không
  if (!token.startsWith("Bearer ")) {
    token = "Bearer $token"; // Chỉ thêm "Bearer " nếu chưa có
  }

  print("Token gửi đi: $token"); // Debug để kiểm tra token đúng chưa

  final response = await http.get(
    Uri.parse('$url?customer_id=$customerId'), 
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token, 
    },
  );

  return response;
}


  Future<http.Response> apiSignUp(User user) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/signup"; 
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),  
    );
    return response;
  }

  Future<http.Response> apiVerifyOtp(String email, String otp_code) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/verifyOtp";  
    Map<String, String> body = {
      'email': email,
      'otp_code': otp_code,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body), 
    );
    return response;
  }

    Future<http.Response> apiResendOtp(String email) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/resendOtp";  
    Map<String, String> body = {
      'email': email,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body), 
    );
    return response;
  }

  Future<http.Response> apiCheckEmailAndPhone(User user) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/checkEmailAndPhoneExistence";  // URL đăng ký
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),  
    );
    return response;
  }

  Future<http.Response> apiLogin(User user) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/login";    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),  
    );
    return response;
  }

Future<bool> updateCustomerInfo(
    String customerId, String name, String phone, String birthday, String gender, String token) async {
  
  print("✅ DEBUG: Token truyền vào API = $token"); // Kiểm tra token có bị lỗi không

  final response = await http.put(
    Uri.parse("http://10.0.2.2:8080/api/usermanagement/update-personal-info?customer_id=$customerId"),
    headers: {
      'Authorization': token,  // ✅ Đảm bảo gửi đúng token
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'FULLNAME': name,
      'PHONE': phone,
      'BIRTHDAY': birthday.isNotEmpty ? _formatDate(birthday) : "",
      'GENDER': gender,
    }),
  );

  print("✅ DEBUG: Response Code = ${response.statusCode}");
  print("✅ DEBUG: Response Body = ${response.body}");

  return response.statusCode == 200;
}


Future<Map<String, dynamic>> apiChangePassword(
    String customerId, String oldPassword, String newPassword, String confirmPassword, String token) async {

  const String url = "http://10.0.2.2:8080/api/usermanagement/change-password";

  try {
    // ✅ Chắc chắn customer_id được gửi dưới dạng String
    final response = await http.put(
      Uri.parse("$url?customer_id=${Uri.encodeComponent(customerId)}"), // 👈 Encode String để tránh lỗi URL
      headers: {
        'Authorization': '$token', // ✅ Đảm bảo token đúng định dạng
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {"status": "success", "message": "Đổi mật khẩu thành công!"};
    } else {
      final errorData = jsonDecode(response.body);
      return {
        "status": "error",
        "message": errorData["message"] ?? "Đổi mật khẩu thất bại!"
      };
    }
  } catch (e) {
    return {"status": "error", "message": "Lỗi kết nối server! Vui lòng thử lại."};
  }
}






String _formatDate(String date) {
  try {
    List<String> parts = date.split("/");
    if (parts.length == 3) {
      return "${parts[2]}-${parts[1]}-${parts[0]}"; // Chuyển sang định dạng YYYY-MM-DD
    }
  } catch (e) {
    print("❌ Lỗi định dạng ngày: $e");
  }
  return "";
}


}
