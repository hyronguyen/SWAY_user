import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/home/trip_picker.dart';
import 'dart:convert';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  String fullname = ''; 
  final UserController userController = UserController(); 

  @override
  void initState() {
    super.initState();
    _checkCustomer();  
  }

  Future<void> _checkCustomer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");  
    String? customerIdStr = prefs.getString("customer_id");  

    if (token != null && customerIdStr != null) {
      int storedCustomerId = int.parse(customerIdStr);

      Map<String, dynamic> decodedToken = _decodeJwt(token);
      
      if (decodedToken.containsKey('data') && decodedToken['data'].containsKey('CUSTOMER_ID')) {
        int tokenCustomerId = decodedToken['data']['CUSTOMER_ID'];

        if (storedCustomerId == tokenCustomerId) {
          Map<String, dynamic>? customerData = await userController.getCustomer(storedCustomerId, token);

          if (customerData != null) {
            String customerJson = json.encode(customerData);

            await prefs.setString('customer_data', customerJson);
            if (customerJson != null) {
              Map<String, dynamic> customerData = json.decode(customerJson);

              setState(() {
                fullname = customerData['FULLNAME'];
              });

            } else {
              print("Không tìm thấy thông tin khách hàng trong SharedPreferences.");
            }
            print("Thông tin khách hàng đã được lưu vào SharedPreferences dưới dạng JSON.");
          } else {
            print("Lỗi khi lấy thông tin khách hàng.");
          }
        } else {
          print("customer_id không khớp giữa SharedPreferences và token.");
        }
      } else {
        print("Token không chứa CUSTOMER_ID.");
      }
    } else {
      print("Không tìm thấy token hoặc customer_id trong SharedPreferences.");
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    List<String> parts = token.split('.');
    if (parts.length == 3) {
      String payload = parts[1];
      // Thêm padding nếu thiếu để giải mã Base64
      payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
      String decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded);
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundblack,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        automaticallyImplyLeading: false,
        flexibleSpace: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/images/appbar_menu.png"),
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
                        0.7) 
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
              "Xin chào, $fullname",
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
                    _buildServiceOption("Xe ô tô", Icons.directions_car),
                    SizedBox(width: 16),
                    _buildServiceOption("Đồ ăn", Icons.fastfood),
                    SizedBox(width: 16),
                    _buildServiceOption("Giao hàng", Icons.delivery_dining_sharp),
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

            Text("Có thể bạn sẽ thích",
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
