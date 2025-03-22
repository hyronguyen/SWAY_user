import 'package:flutter/material.dart';
import 'package:sway/page/Walletscreen/depositcard.dart';
import 'package:sway/config/colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isAmountVisible = true; // Biến để điều khiển hiển thị số tiền
  double totalAmount = 100000.0; // Tổng số tiền
  double totalSpending = 15000.0; // Tổng chi tiêu trong tháng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEDAE10), // Màu vàng cho AppBar
        automaticallyImplyLeading: false,
        flexibleSpace: Stack(
          children: [
            // Background image and gradient
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/appbar_menu.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    myorange.withOpacity(0.8),
                    primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tạo padding cho toàn bộ container
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Nền màu đen với opacity để tạo hiệu ứng mờ
            borderRadius: BorderRadius.circular(12), // Bo góc cho container
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8), // Tăng khoảng cách trên
              Row(
                children: [
                  Text(
                    "Tổng số dư",
                    style: TextStyle(
                      fontSize: 16, // Kích thước chữ phù hợp
                      fontWeight: FontWeight.w500, // Tạo cảm giác dễ đọc
                      color: Colors.white, // Màu chữ trắng để tương phản với nền đen mờ
                    ),
                  ),
                  const Spacer(), // Tách icon khỏi text "Tổng số dư"
                  IconButton(
                    icon: Icon(
                      _isAmountVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white, // Màu trắng cho icon
                    ),
                    onPressed: () {
                      setState(() {
                        _isAmountVisible = !_isAmountVisible; // Đổi trạng thái hiển thị
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _isAmountVisible
                    ? "****"
                    : "đ ${totalAmount.toStringAsFixed(0)}", // Hiển thị số dư hoặc dấu "****" khi ẩn
                style: TextStyle(
                  fontSize: 22, // Kích thước chữ lớn hơn cho số dư
                  fontWeight: FontWeight.w700, // Đậm hơn để nổi bật
                  color: Colors.white, // Màu trắng cho số tiền
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng chi tiêu tháng này:",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70, // Màu chữ nhạt hơn để dễ đọc
                    ),
                  ),
                  Text(
                    "đ ${totalSpending.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 16, // Tăng kích thước chữ để nổi bật hơn
                      fontWeight: FontWeight.w600, // Đậm hơn để nổi bật
                      color: Colors.white, // Màu trắng cho số tiền
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
          
        ),
        
        toolbarHeight: 180, // Điều chỉnh chiều cao của AppBar
        elevation: 0,
      ),
  
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút Nạp tiền
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFundsScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDAE10), // Màu vàng cho Nạp tiền
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFEDAE10)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Nạp tiền',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nút Rút tiền với màu xanh dương
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Màu xanh dương cho Rút tiền
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.orangeAccent),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Rút tiền',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem thêm',
                      style: TextStyle(
                        color: Color(0xFFF4BE05),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const TransactionItem(
              icon: Icon(Icons.arrow_circle_left_outlined, size: 40, color: Colors.red),  // Withdrawal icon (Rút tiền)
              name: 'Nguyễn Minh Kha',
              time: '09:20 - 20/03/2025',
              amount: '-\đ 150000',
              isBold: true,  // Bold background
            ),

            const TransactionItem(
              icon: Icon(Icons.arrow_circle_right_outlined, size: 40, color: Colors.green),  // Deposit icon (Nạp tiền)
              name: 'Nạp tiền',
              time: '09:20 - 20/03/2025',
              amount: '\đ 160000',
              isBold: false,  // Light background
            ),
            const TransactionItem(
              icon: Icon(Icons.arrow_circle_left_outlined, size: 40, color: Colors.red),  // Withdrawal icon (Rút tiền)
              name: 'Lê Hữu Dũng',
              time: '09:20 - 20/03/2025',
              amount: '-\đ 100000',
              isBold: true,  // Bold background
            ),           
          ],
        ),
      ),
    );
  }
}


class BalanceCard extends StatelessWidget {
  final String amount;
  final String label;

  const BalanceCard({
    super.key,
    required this.amount,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEC400)),
        color: const Color(0xFFFFFBE7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A5A5A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 21),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A5A5A),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Icon icon;  // Using an Icon type
  final String name;
  final String time;
  final String amount;
  final bool isBold;  // Parameter to alternate the background color

  const TransactionItem({
    super.key,
    required this.icon,
    required this.name,
    required this.time,
    required this.amount,
    required this.isBold,  // Make sure to pass this flag when calling the widget
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Tăng padding để giao diện thoải mái hơn
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Tạo khoảng cách giữa các item
      decoration: BoxDecoration(
        color: isBold ? const Color(0xFF2A2A2A) : const Color(0xFF1F1F1F), // Alternate background colors
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2), // Tạo bóng nhẹ cho phần tử
          ),
        ],
      ),
      child: Row(
        children: [
          icon,  // Display the passed icon
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isBold ? Colors.white : Colors.grey[400], // Alternate text color
                    fontSize: 16, // Kích thước chữ vừa phải
                    fontWeight: FontWeight.w600, // Đậm cho ô đậm
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4), // Khoảng cách giữa tên và thời gian
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0), // Màu xám nhạt cho thời gian
                    fontSize: 12, // Kích thước nhỏ cho thời gian
                    fontWeight: FontWeight.w400, // Mỏng hơn so với tên
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12), // Khoảng cách giữa tên và số tiền
          Text(
            amount,
            style: TextStyle(
              color: amount.startsWith('-') ? Colors.red : Colors.green, // Màu sắc số tiền tùy thuộc vào loại giao dịch
              fontSize: 16, // Kích thước chữ vừa phải cho số tiền
              fontWeight: FontWeight.w600, // Đậm để nổi bật
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
