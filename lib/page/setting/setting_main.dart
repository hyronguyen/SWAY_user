import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/setting/term.dart';
import 'package:sway/page/setting/change_language.dart';
import 'package:sway/page/setting/change_password.dart';
import 'package:sway/page/setting/delete_email.dart';
import 'package:sway/page/setting/information.dart';
import 'package:sway/page/setting/customer_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Xóa token khỏi bộ nhớ

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsItems = [
      {'title': 'Đổi mật khẩu', 'icon': Icons.lock, 'page': const ChangePasswordScreen()},
      {'title': 'Ngôn ngữ ứng dụng', 'icon': Icons.language, 'page': const LanguageScreen()},
      {'title': 'Điều khoản', 'icon': Icons.article, 'page': const TermsScreen()},
      {'title': 'Thông tin người dùng', 'icon': Icons.person, 'page': const CustomerProfileScreen()},
      {'title': 'Contact Us', 'icon': Icons.contact_support, 'page': const ContactScreen()},
      {'title': 'Xóa tài khoản', 'icon': Icons.delete_forever, 'page': const DeleteAccountScreen()},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,


      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: settingsItems.length + 1, // Thêm 1 item cho nút Đăng xuất
        itemBuilder: (context, index) {
          if (index < settingsItems.length) {
            return _buildSettingsItem(
              icon: settingsItems[index]['icon'],
              title: settingsItems[index]['title'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => settingsItems[index]['page']),
                );
              },
            );
          } else {
            // Nút Đăng xuất
            return _buildSettingsItem(
              icon: Icons.exit_to_app,
              title: "Đăng xuất",
              color: Colors.red,
              onTap: () => _logout(context),
            );
          }
        },
      ),
    );
  }

  // Widget tạo một mục cài đặt
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(
          title,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
