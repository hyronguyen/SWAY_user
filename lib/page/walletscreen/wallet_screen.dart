import 'package:flutter/material.dart';
import 'package:sway/page/Walletscreen/depositcard.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Chuyển hướng sang AddFundsScreen khi nhấn nút "Nạp tiền"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddFundsScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: const Color(0xFFEDAE10),
                        side: const BorderSide(color: Color(0xFFEDAE10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Expanded(
                      child: BalanceCard(
                          amount: '\$500', label: 'Số dư khả dụng')),
                  SizedBox(width: 30),
                  Expanded(
                      child: BalanceCard(
                          amount: '\$200', label: 'Tổng chi tháng')),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lịch sử',
                    style: TextStyle(
                      color: Color(0xFF414141),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem',
                      style: TextStyle(
                        color: Color(0xFFF4BE05),
                        fontSize: 12,
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
                image: 'assets/images/income.png',
                name: 'Nguyễn Minh Kha',
                time: '09:20 am',
                amount: '-\$570.00'),
            const SizedBox(height: 16),
            const TransactionItem(
                image: 'assets/images/outcome.png',
                name: 'Nạp tiền',
                time: '09:20 am',
                amount: '\$570.00'),
            const SizedBox(height: 16),
            const TransactionItem(
                image: 'assets/images/income.png',
                name: 'Lê Hữu Dũng',
                time: '09:20 am',
                amount: '-\$570.00'),
            const SizedBox(height: 66),
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
  final String image;
  final String name;
  final String time;
  final String amount;

  const TransactionItem({
    super.key,
    required this.image,
    required this.name,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEC400), width: 0.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(image, width: 40, height: 40, fit: BoxFit.contain),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF121212),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF5A5A5A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: Color(0xFF121212),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
