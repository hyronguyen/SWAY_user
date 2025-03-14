import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/model/user.dart';  

class UserController {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    User user = User(email: email, password: password);

    final response = await apiLogin(user);

    if (response.statusCode == 200) {
      // Parse the response body to extract the token and customer_id
      var responseData = json.decode(response.body);
      return responseData['data'];  // Return the data containing both the token and customer_id
    } else {
      return null;  // Return null if login fails
    }
  }

  Future<Map<String, dynamic>?> getCustomer(int customerId, String token) async {
    final response = await apiGetInformationCustomer(customerId, token);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      return responseData;  // Trả về dữ liệu khách hàng
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
  const String url = "http://10.0.2.2:8080/api/usermanagement/get-information-customer"; 
  
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
}
