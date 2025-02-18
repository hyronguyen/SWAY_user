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
  int _selectedMethodIndex =
      0; // Chỉ số của phương thức được chọn mặc định là 0

  final List<Map<String, String>> paymentMethods = [
    {
      'logo': 'assets/images/visa.png',
      'method': '**** **** **** 8970',
      'expires': '12/26',
    },
    {
      'logo': 'assets/images/mastercard.png',
      'method': '**** **** **** 8970',
      'expires': '12/26',
    },
    {
      'logo': 'assets/images/paypal.png',
      'method': 'mailaddress@mail.com',
      'expires': '12/26',
    },
  ];

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
          "Nạp My Wallet",
          style: TextStyle(color: Colors.white, fontSize: 16),
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
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddPaymentMethodScreen()), // Chuyển đúng trang cần mở
                  );
                },
                child: Text(
                  "Thêm phương thức",
                  style: TextStyle(color: Color(0xFFEDAE10)),
                ),
              ),
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
            Expanded(
              child: ListView.builder(
                itemCount:
                    paymentMethods.length, // Số lượng phương thức thanh toán
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMethodIndex = index;
                      });
                    },
                    child: PaymentMethodCard(
                      logo: paymentMethods[index]['logo']!,
                      method: paymentMethods[index]['method']!,
                      expires: paymentMethods[index]['expires']!,
                      isSelected: _selectedMethodIndex == index,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDAE10), // Màu nền vàng
                minimumSize: Size(double.infinity, 50), // Kích thước nút
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Góc bo tròn
                ),
              ),
              onPressed: () {},
              child: Text(
                "Confirm",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16), // Màu chữ trắng và kích thước chữ
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String logo;
  final String method;
  final String expires;
  final bool isSelected;

  PaymentMethodCard({
    required this.logo,
    required this.method,
    required this.expires,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected
          ? Color(0xFFFFF9C4)
          : Colors.grey[900], // Màu nền khi được chọn
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? Color(0xFFEDAE10)
              : Colors.transparent, // Màu viền khi được chọn
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(logo, width: 40), // Hiển thị logo
        title: Text(method,
            style: TextStyle(color: Colors.black)), // Màu chữ khi được chọn
        subtitle: Text(
          "Expires: $expires",
          style: TextStyle(color: Colors.black54), // Màu chữ phụ khi được chọn
        ),
      ),
    );
  }
}
