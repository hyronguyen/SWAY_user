import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/page/setting/customer_profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String birthday;
  final String gender;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.birthday,
    required this.gender,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late String selectedGender;
  bool isLoading = false; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _birthdayController = TextEditingController(text: widget.birthday);
    selectedGender = widget.gender;

    _checkSharedPreferences(); // Debug thông tin đã lưu
  }

  void _checkSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id');
    String? token = prefs.getString('token');

    print("DEBUG: Customer ID: $customerId");
    print("DEBUG: Token: $token");
  }

  void _saveChanges() async {
    String updatedName = _nameController.text.trim();
    String updatedPhone = _phoneController.text.trim();
    String updatedBirthday = _birthdayController.text.trim();
    String updatedGender = selectedGender;

    setState(() {
      isLoading = true;
    });

    // ✅ Lấy customerId và token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerId = prefs.getString('customer_id');
    String? token = prefs.getString('token');

    // ✅ Kiểm tra nếu không có token hoặc customerId
    if (customerId == null || token == null || token.isEmpty) {
      print(
          "❌ DEBUG: Không tìm thấy token hoặc customer_id trong SharedPreferences.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại!")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    // ✅ Đảm bảo token có prefix "Bearer "
    String authToken = token.startsWith("Bearer ") ? token : "Bearer $token";

    print("✅ DEBUG: Customer ID = $customerId");
    print("✅ DEBUG: Token trước khi gửi = $authToken");

    // 🟢 Gọi API thông qua UserController
    bool success = await UserController().updateCustomerInfo(
      customerId,
      updatedName,
      updatedPhone,
      updatedBirthday,
      updatedGender,
      authToken, // ✅ Đảm bảo gửi token đúng
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thông tin thành công!")),
      );
      // Chuyển về màn hình hiển thị thông tin khách hàng (ProfileScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerProfileScreen(),
        ),
      ); // Đảm bảo '/profile' có trong routes
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại. Vui lòng thử lại!")),
      );
    }
  }

  /// Widget hiển thị ô nhập thông tin
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
      ),
    );
  }

  /// Widget hiển thị dropdown chọn giới tính
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white, fontSize: 18),
        decoration: InputDecoration(
          labelText: "Giới tính",
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
        items: ["MALE", "FEMALE", "OTHER"].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedGender = value!;
          });
        },
      ),
    );
  }

  /// Widget hiển thị nút "Lưu" và "Hủy"
  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 3),
                  )
                : const Text("Lưu",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Hủy",
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa thông tin"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField("Họ và tên", _nameController),
            _buildTextField("Số điện thoại", _phoneController),
            _buildTextField("Ngày sinh", _birthdayController),
            _buildGenderDropdown(),
            const SizedBox(height: 20),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }
}
