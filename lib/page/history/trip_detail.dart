import 'package:flutter/material.dart';
import 'package:sway/config/colors.dart';
import 'history.dart'; // Đảm bảo bạn import đúng trang history
import 'package:intl/intl.dart';

class TripDetailPage extends StatelessWidget {
  final Trip trip;

  const TripDetailPage({super.key, required this.trip});
  // Hàm chuyển đổi định dạng ngày
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate); // Định dạng "23 th 2 2025"
  }

  String formatTime(String time) {
    DateTime parsedTime = DateTime.parse(time);
    return DateFormat('hh:mm a').format(parsedTime); // Định dạng "02:30 PM"
  }

    String formatPaymentMethod(String payment_method){
    switch (payment_method){
      case 'CASH':
        return 'Tiền mặt';
      case 'CREDIT_CARD':
        return 'Thẻ ngân hàng';
      case 'E-WALLET':
        return 'Ví';
      default:
        return 'Chưa xác định';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundblack, // Nền đen
      appBar: AppBar(
        title: Text(
          '${formatDate(trip.date)}, ${formatTime(trip.time)}', // Hiển thị thời gian chuyến đi
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundblack,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mã chuyến đi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Mã chuyến đi",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "${trip.id}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.copy, color: Colors.grey, size: 16),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Phương thức thanh toán
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.white),
                    title: Text(
                      formatPaymentMethod(trip.payment_method),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.money, color: Colors.white),
                    title: Text(
                      "Tổng tiền: ${trip.price}đ",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Điểm đi & Điểm đến
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.radio_button_checked, color: Colors.blue),
                    title: Text(
                      trip.origin,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      formatTime(trip.time),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text(
                      trip.destination,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      formatTime(trip.endTime),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
