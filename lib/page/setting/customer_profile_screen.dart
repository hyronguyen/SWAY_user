import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sway/page/setting/edit_profile_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  String selectedGender = "OTHER";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? customerId = prefs.getString("customer_id");

    if (token == null || customerId == null) {
      print("❌ Không tìm thấy token hoặc customer_id");
      return;
    }

    final String formattedToken = token.startsWith("Bearer ") ? token : "Bearer $token";

    final Uri url = Uri.http(
      "10.0.2.2:8080",
      "/api/UserManagement/get-infomation-customer",
      {"customer_id": customerId},
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": formattedToken,
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          _nameController.text = userData["FULLNAME"] ?? "Chưa cập nhật";
          _emailController.text = userData["EMAIL"] ?? "Chưa cập nhật";
          _phoneController.text = userData["PHONE"] ?? "Chưa cập nhật";
          _birthdayController.text = _formatDate(userData["BIRTHDAY"] ?? "");
          selectedGender = userData["GENDER"] ?? "OTHER";
        });
      } else {
        print("❌ Lỗi API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception khi gọi API: $e");
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return "";
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "";
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen(
        name: _nameController.text,
        phone: _phoneController.text,
        birthday: _birthdayController.text,
        gender: selectedGender,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Thông tin khách hàng", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildTextField("Tên", _nameController),
            _buildTextField("Email", _emailController, enabled: false),
            _buildTextField("Số điện thoại", _phoneController),
            _buildTextField("Ngày sinh", _birthdayController),
            _buildGenderField(),
            const SizedBox(height: 20),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        enabled: false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: TextEditingController(text: selectedGender),
        enabled: false,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          labelText: "Giới tính",
          labelStyle: TextStyle(color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
          ),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _editProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: const Color(0xFFedae10),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text("Chỉnh sửa thông tin", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
