import 'package:flutter/material.dart';
import 'package:sway/page/Walletscreen/addmethod.dart'; // Import trang AddPaymentMethodScreen

class WalletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: WalletScreen(
      //   selectedIndex: 2,
      //   onItemTapped: (index) {}, // Hàm xử lý khi chọn mục khác
      // ),
    );
  }
}

class AddFundsScreen extends StatefulWidget {
  @override
  _AddFundsScreenState createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  // Gán giá trị mặc định là 'PayOS'
  String? selectedPaymentMethod = 'PayOS'; // Đặt giá trị mặc định là 'PayOS'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Màu nền đen
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
        title: const Text(
          "Nạp tiền vào ví",
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
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
                // Phương thức thanh toán PayOS
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
                            'assets/images/payos.png', // Hình ảnh PayOS
                            width: 30, // Đặt kích thước cho ảnh
                            height: 30,
                          ),
                          SizedBox(width: 16),
                          Text(
                            "Thanh toán PayOS",
                            style: TextStyle(color: Colors.black), // Màu chữ đen khi chọn
                          ),
                        ],
                      ),
                      activeColor: Color(0xFFEDAE10), // Màu vàng khi được chọn
                    ),
                  ),
                ),
                // Các phương thức thanh toán khác có thể thêm vào đây nếu cần
              ],
            ),
            SizedBox(height: 16),
            Expanded(child: Container()), // Khoảng trống
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDAE10), // Màu nền vàng
                minimumSize: Size(double.infinity, 50), // Kích thước nút
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Góc bo tròn
                ),
              ),
              onPressed: () {
                // Xử lý xác nhận khi chọn phương thức thanh toán
                if (selectedPaymentMethod != null) {
                  // Tiến hành thanh toán hoặc xác nhận
                } else {
                  // Hiển thị thông báo nếu chưa chọn phương thức thanh toán
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng chọn phương thức thanh toán')),
                  );
                }
              },
              child: Text(
                "Xác nhận",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16), // Màu chữ trắng và kích thước chữ
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
