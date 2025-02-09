import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điều khoản',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điều khoản sử dụng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildTermSection(
                'Điều kiện sử dụng dịch vụ:',
                'Người dùng cần đăng ký tài khoản và cung cấp thông tin cá nhân chính xác. Chỉ những người từ 18 tuổi trở lên mới được sử dụng ứng dụng.',
              ),
              SizedBox(height: 12),
              _buildTermSection(
                'Phạm vi hoạt động:',
                'Ứng dụng chỉ cung cấp dịch vụ đặt xe trong các khu vực hỗ trợ.',
              ),
              SizedBox(height: 12),
              _buildTermSection(
                'Người dùng chịu trách nhiệm:',
                'kiểm tra phạm vi trước khi sử dụng.',
              ),
              SizedBox(height: 12),
              _buildTermSection(
                'Thanh toán và huỷ chuyến:',
                'Người dùng phải thanh toán đầy đủ cước phí sau mỗi chuyến đi. Huỷ chuyến quá số lần quy định có thể dẫn đến phí phạt hoặc khoá tài khoản tạm thời.',
              ),
              SizedBox(height: 40),
              Container(
                height: 5,
                width: 135,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2.5),
                ),
                margin: EdgeInsets.symmetric(horizontal: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 16),
        children: [
          TextSpan(
            text: title + ' ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: content),
        ],
      ),
    );
  }
}