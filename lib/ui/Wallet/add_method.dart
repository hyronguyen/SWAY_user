import 'package:flutter/material.dart';
import 'package:sway/ui/Wallet/mywallet.dart'; // Import trang WalletScreen

void main() {
  runApp(AddPaymentMethodApp());
}

class AddPaymentMethodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AddPaymentMethodScreen(),
    );
  }
}

class AddPaymentMethodScreen extends StatefulWidget {
  @override
  _AddPaymentMethodScreenState createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final TextEditingController _methodController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();

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
            const Text(
              "Back",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        title: const Text(
          "Thêm phương thức",
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
              controller: _methodController,
              decoration: const InputDecoration(
                labelText: "Phương thức",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDAE10)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountController,
              decoration: const InputDecoration(
                labelText: "Số tài khoản/ Thẻ",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFEDAE10)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDAE10),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Thêm hành động khi nhấn nút "Thêm"
              },
              child: const Text(
                "Thêm",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildPaymentMethodItem(
                    "assets/images/visa.png",
                    "**** **** **** 8970",
                    "12/26",
                  ),
                  _buildPaymentMethodItem(
                    "assets/images/mastercard.png",
                    "**** **** **** 8970",
                    "12/26",
                  ),
                  _buildPaymentMethodItem(
                    "assets/images/paypal.png",
                    "mailaddress@mail.com",
                    "12/26",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(String logo, String method, String expires) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(logo, width: 40),
        title: Text(method, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          "Expires: $expires",
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
