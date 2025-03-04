import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/model/user.dart';  

class UserController {
  Future<bool> login(String email, String password) async {
    User user = User(email: email, password: password);  

    final response = await apiLogin(user);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
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
}
