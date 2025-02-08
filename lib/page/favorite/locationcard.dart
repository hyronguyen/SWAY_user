import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final String address;

  const LocationCard({
    Key? key,
    required this.title,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF35383F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFF1B1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            size: 24,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    color: Color(0xFFD0D0D0),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),  // Khoảng cách xung quanh biểu tượng
            decoration: BoxDecoration(
              color: Colors.red,  // Màu nền đỏ
              shape: BoxShape.circle,  // Để làm nền hình tròn
            ),
            child: Icon(
              Icons.remove,  // Biểu tượng dấu trừ
              size: 18,       // Kích thước biểu tượng
              color: Colors.white, // Màu sắc của biểu tượng (trắng)
            ),
          )
        ],
      ),
    );
  }
}