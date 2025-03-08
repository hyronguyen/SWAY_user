import 'package:flutter/material.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/home/trip_picker.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String customer = "Nguyễn Văn A";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundblack,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Set transparent to see the image
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/images/appbar_menu.png"), // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    myorange.withOpacity(0.8),
                    primary.withOpacity(
                        0.7) // Nếu `primary` là `const`, cần tạo một bản sao với opacity
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            )
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Xin chào, $customer",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: greymenu),
            ),
            Text(
              "Hôm nay bạn muốn đi đâu ?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: backgroundblack),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // Adjust opacity for visibility
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TripPicker(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0); // Đi từ bên phải vào
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Nhập điểm đến!",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
        toolbarHeight: 150,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Hàng loại dịch vụ
            SizedBox(
              height: 100,
              child: Center(
                // Centers the ListView horizontally
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildServiceOption("Xe máy", Icons.motorcycle),
                    SizedBox(width: 16), // Space between items
                    _buildServiceOption("Xe 4 chỗ", Icons.directions_car),
                    SizedBox(width: 16),
                    _buildServiceOption("Xe Vip", Icons.local_taxi),
                    SizedBox(width: 16),
                    _buildServiceOption("Tiết Kiệm", Icons.electric_car),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            // Danh mục tin tức
            Text("Sự kiện",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Container(
              height: 170,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(
                      "assets/images/banner_evt.png"), // Hình ảnh từ thư mục assets
                  fit: BoxFit.cover, // Căn chỉnh ảnh phủ toàn bộ Container
                ),
              ),
              alignment: Alignment.center,
            ),
            const SizedBox(height: 20),
            // Địa điểm yêu thích

            Text("Địa điểm yêu thích",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: greymenu,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text("Địa điểm ${index + 1}",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceOption(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: backgroundblack,
                    blurRadius: 4,
                    offset: Offset(0, 2)),
              ],
            ),
            padding: EdgeInsets.all(15),
            child: Icon(icon, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
