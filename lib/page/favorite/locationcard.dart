import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String title;
  final String address;
  final VoidCallback onRemove;
  final VoidCallback onTap; // 👈 Thêm onTap để chọn địa điểm

  const LocationCard({
    super.key,
    required this.title,
    required this.address,
    required this.onRemove,
    required this.onTap, // 👈 Nhận sự kiện onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👈 Bấm vào cả thẻ là chọn địa điểm
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF35383F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.24),
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, size: 24, color: Colors.white),
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
            // Nút xoá
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint("🔥 Nút xóa được bấm!");
                  onRemove();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.remove, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
