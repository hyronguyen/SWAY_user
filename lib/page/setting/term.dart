import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Điều khoản sử dụng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              _buildTermSection(
                '1. Điều kiện sử dụng dịch vụ:',
                'Người dùng cần đăng ký tài khoản và cung cấp thông tin cá nhân chính xác. Chỉ những người từ 18 tuổi trở lên mới được sử dụng ứng dụng.',
              ),

              _buildTermSection(
                '2. Phạm vi hoạt động:',
                'Ứng dụng chỉ cung cấp dịch vụ đặt xe trong các khu vực được hỗ trợ.',
              ),

              _buildTermSection(
                '3. Trách nhiệm của người dùng:',
                'Người dùng chịu trách nhiệm kiểm tra phạm vi hoạt động trước khi sử dụng. Không được sử dụng ứng dụng để thực hiện hành vi vi phạm pháp luật.',
              ),

              _buildTermSection(
                '4. Thanh toán và huỷ chuyến:',
                'Người dùng phải thanh toán đầy đủ cước phí sau mỗi chuyến đi. Hủy chuyến quá số lần quy định có thể dẫn đến phí phạt hoặc khóa tài khoản tạm thời.',
              ),

              _buildTermSection(
                '5. Quyền lợi của tài xế:',
                'Tài xế có quyền từ chối cung cấp dịch vụ nếu phát hiện hành vi gian lận hoặc nguy hiểm từ phía khách hàng.',
              ),

              _buildTermSection(
                '6. Bảo vệ dữ liệu cá nhân:',
                'Ứng dụng cam kết bảo vệ thông tin cá nhân của người dùng và không chia sẻ với bên thứ ba nếu không có sự đồng ý.',
              ),

              _buildTermSection(
                '7. Chính sách hoàn tiền:',
                'Trong trường hợp có lỗi hệ thống hoặc khiếu nại hợp lý, khách hàng có thể yêu cầu hoàn tiền theo chính sách của công ty.',
              ),

              SizedBox(height: 30), // Điều chỉnh khoảng cách cuối trang
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          children: [
            TextSpan(
              text: '$title ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
