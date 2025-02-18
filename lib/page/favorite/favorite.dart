import 'package:flutter/material.dart';
import 'package:sway/page/favorite/locationcard.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      LocationCard(
                        title: 'Nhà Huy',
                        address: '8299 Huỳnh Tấn Phát, Nhà Bè, Tp Hồ Chí Minh',
                      ),
                      const SizedBox(height: 24),
                      LocationCard(
                        title: 'Nhà Giảng',
                        address: '1716 Huỳnh Tấn Phát, Nhà Bè, Tp Hồ Chí Minh',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
