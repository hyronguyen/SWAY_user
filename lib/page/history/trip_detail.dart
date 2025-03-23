import 'package:flutter/material.dart';
import 'history.dart'; // Đảm bảo bạn import đúng trang history

class TripDetailPage extends StatelessWidget {
  final Trip trip;

  TripDetailPage({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.time), // Hiển thị thời gian chuyến đi
        backgroundColor: Colors.amber,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại trang lịch sử cuốc xe
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Mã chuyến đi
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Mã chuyến đi: #${trip.id}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            // Các phần khác tiếp tục như trước...
          ],
        ),
      ),
    );
  }
}
