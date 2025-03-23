import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';  // Use the necessary import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/mainpage.dart';  // Import SharedPreferences

class AddFundsScreen extends StatefulWidget {
  @override
  _AddFundsScreenState createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  String? selectedPaymentMethod = 'PayOS';
  TextEditingController amountController = TextEditingController();
  String qrData = '';  // Biến lưu trữ dữ liệu cho mã QR
  bool isLoading = false;  // Trạng thái đang tải

  Future<void> depositFunds() async {
    final amountText = amountController.text;
    double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || amount < 0.01 || amount > 10000000000) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Số tiền không hợp lệ.')));
      return;
    }

    setState(() {
      isLoading = true;  // Bắt đầu tải khi người dùng nhấn xác nhận
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Token không hợp lệ')));
        setState(() {
          isLoading = false;  // Dừng tải nếu không có token
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/WalletManagement/deposit-wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: jsonEncode({
          'amount': amount,
          'description': 'Nạp tiền vào ví',
          'status': 'PENDING',
          'paymentMethod': selectedPaymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String qrCode = data['paymentResponse']['qrCode'];
        setState(() {
          qrData = qrCode;
          isLoading = false;  // Dừng tải sau khi nhận dữ liệu
        });
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Lỗi xảy ra')));
        setState(() {
          isLoading = false;  // Dừng tải nếu có lỗi
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể kết nối đến server')));
      setState(() {
        isLoading = false;  // Dừng tải nếu gặp lỗi
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        title: const Text("Nạp tiền vào ví"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Nhập số tiền",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDAE10)),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              "Chọn phương thức",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedPaymentMethod = 'PayOS';
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'PayOS' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RadioListTile<String>(
                      value: 'PayOS',
                      groupValue: selectedPaymentMethod,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      },
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/images/payos.png',
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Thanh toán PayOS",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      activeColor: Color(0xFFEDAE10),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (qrData.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Mã QR thanh toán:",
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 320.0,
                      gapless: false,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            Expanded(child: Container()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDAE10),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : qrData.isEmpty
                      ? depositFunds  // Nếu chưa có mã QR, gọi hàm depositFunds
                      : () {
                          // Hiển thị pop-up với thông điệp
                          showDialog(
                            context: context,
                            barrierDismissible: false,  // Không thể đóng pop-up bằng cách nhấn bên ngoài
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,  // Đặt nền của dialog thành màu trắng
                                title: Text(
                                  'Thông báo',
                                  style: TextStyle(color: Colors.black),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Hệ thống đang kiểm tra giao dịch. Ví sẽ được cập nhật sau vài phút.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFEDAE10),  // Màu nút giống màu "Xác nhận"
                                      minimumSize: Size(double.infinity, 50),  // Đảm bảo kích thước nút giống nhau
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),  // Bo góc nút
                                      ),
                                    ),
                                    onPressed: () {
                                      // Chuyển đến Mainpage và thay thế màn hình hiện tại
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => Mainpage()),
                                      );
                                    },
                                    child: Text(
                                      'Quay về trang chủ',
                                      style: TextStyle(
                                        color: Colors.white,  // Màu chữ trắng
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      qrData.isEmpty ? "Xác nhận" : "Hoàn tất thanh toán",  // Hiển thị tên nút thay đổi
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),


            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}