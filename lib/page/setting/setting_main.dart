import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> settingsItems = [
      {'title': 'Đổi mật khẩu'},
      {'title': 'Đổi ngôn ngữ'},
      {'title': 'Điều khoản'},
      {'title': 'Chế độ màn hình sáng'},
      {'title': 'Contact Us'},
      {'title': 'Xóa tài khoản'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: settingsItems.length,
        itemBuilder: (context, index) {
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
              title: Text(
                settingsItems[index]['title']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
              onTap: () {
                // Handle tap for each setting item
                switch (index) {
                  case 0:
                    // Handle change password
                    break;
                  case 1:
                    // Handle change language
                    break;
                  case 2:
                    // Handle terms and conditions
                    break;
                  case 3:
                    // Handle screen brightness mode
                    break;
                  case 4:
                    // Handle contact us
                    break;
                  case 5:
                    // Handle delete account
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }
}