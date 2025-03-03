import 'dart:convert';
import 'package:http/http.dart' as http;

class Usercontroller {
  Future<bool> login(String email, String password) async {
    // Construct the login payload
    Map<String, dynamic> user = {
      'email': email,
      'password': password,
    };

    // Send login request to the backend
    final response = await apiLogin(user);

    if (response.statusCode == 200) {
      // Successful login
      return true;
    } else {
      // Login failed
      return false;
    }
  }

  Future<http.Response> apiLogin(Map<String, dynamic> user) async {
    const String url = "http://10.0.2.2:8080/api/usermanagement/login";    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user),
    );
    return response;
  }
}
