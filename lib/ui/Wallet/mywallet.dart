import 'package:flutter/material.dart';
import 'package:sway/ui/Wallet/deposit.dart';

void main() {
  runApp(WalletApp());
}

class WalletApp extends StatefulWidget {
  @override
  _WalletAppState createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  int _selectedIndex = 2; // Mặc định chọn "Wallet"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WalletScreen(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class WalletScreen extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  WalletScreen({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFEDAE10), // Màu mới
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 20),
              onPressed: () {},
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEDAE10), // Màu mới
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.search, color: Colors.black, size: 20),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEDAE10), // Màu mới
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(Icons.notifications, color: Colors.black, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Color(0xFFEDAE10), // Màu chữ mới
                      side: BorderSide(
                          color: Color(0xFFEDAE10), width: 2), // Màu viền mới
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFundsScreen()),
                      );
                    },
                    child: Text("Nạp tiền", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard("Số dư khả dụng", "\$500"),
                  _buildBalanceCard("Tổng chi tháng", "\$200"),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lịch sử",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: Color(0xFFEDAE10), // Màu chữ mới
                          ),
                          child: Text(
                            "Xem",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildTransactionItem("Nguyễn Minh Kha", "-\$570.00",
                              Colors.red, Colors.white, Icons.remove),
                          _buildTransactionItem("Nạp tiền", "+\$570.00",
                              Colors.green, Colors.white, Icons.add),
                          _buildTransactionItem("Lê Hữu Dũng", "-\$570.00",
                              Colors.red, Colors.white, Icons.remove),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFEDAE10), // Màu mới
        child: Icon(Icons.add, color: Colors.black),
        onPressed: () {},
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, // Màu đen của app
        selectedItemColor: Color(0xFFEDAE10), // Màu mới
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex, // Hiển thị mục đã chọn
        onTap: onItemTapped, // Xử lý khi người dùng chọn mục khác
        showUnselectedLabels: true, // Hiển thị tên của các biểu tượng
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favourite"),
          BottomNavigationBarItem(
            icon: selectedIndex == 2
                ? Icon(Icons.account_balance_wallet,
                    size: 40, color: Color(0xFFEDAE10)) // Màu mới
                : Icon(Icons.account_balance_wallet, color: Colors.white),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_offer), label: "Offer"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(String title, String amount) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF9C4), // Màu nền mới
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(amount,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String name, String amount, Color color,
      Color backgroundColor, IconData icon) {
    return Card(
      color: backgroundColor, // Đặt màu nền trắng cho các giao dịch
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(name, style: TextStyle(color: Colors.black, fontSize: 16)),
        subtitle: Text("09:20 AM", style: TextStyle(color: Colors.grey)),
        trailing: Text(
          amount,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
