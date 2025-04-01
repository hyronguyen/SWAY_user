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
  List<Map<String, dynamic>> favoritePlaces = [
    {
      "name": "HUFLIT - Hóc Môn",
      "location": "Hóc Môn, TP.HCM",
      "imageUrl":
          "https://unizone.edu.vn/wp-content/uploads/2023/01/huflit-co-so-dao-tao.jpg",
      "lat": 10.891193,
      "lng": 106.604890,
    },
    {
      "name": "Phố đi bộ Nguyễn Huệ",
      "location": "Quận 1, TP.HCM",
      "imageUrl":
          "https://ik.imagekit.io/tvlk/blog/2023/01/pho-di-bo-nguyen-hue-15.jpg?tr=dpr-2,w-675",
      "lat": 10.775658,
      "lng": 106.703819,
    },
    {
      "name": "Nhà Bè",
      "location": "Nhà Bè, TP.HCM",
      "imageUrl":
          "https://cdnnews.mogi.vn/news/wp-content/uploads/2022/05/03101714/nha-be-o-dau-1.jpg",
      "lat": 10.695264,
      "lng": 106.740024,
    },
    {
      "name": "Quận 6",
      "location": "TP.HCM",
      "imageUrl":
          "https://th.bing.com/th/id/OIP.GMuCyHvNr5ZQoh0KxDMrUgHaFj?rs=1&pid=ImgDetMain",
      "lat": 10.748233,
      "lng": 106.635029,
    },
    {
      "name": "Nhà thờ Đức Bà",
      "location": "Quận 1, TP.HCM",
      "imageUrl":
          "https://media-cdn-v2.laodong.vn/Storage/NewsPortal/2020/3/1/787823/89Ed9078d6332d6d7422.jpg",
      "lat": 10.779785,
      "lng": 106.699018,
    },
  ];

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

      if (decodedToken.containsKey('data') &&
          decodedToken['data'].containsKey('CUSTOMER_ID')) {
        int tokenCustomerId = decodedToken['data']['CUSTOMER_ID'];

        if (storedCustomerId == tokenCustomerId) {
          Map<String, dynamic>? customerData =
              await userController.getCustomer(storedCustomerId, token);

          if (customerData != null) {
            String customerJson = json.encode(customerData);

            await prefs.setString('customer_data', customerJson);
            if (customerJson != null) {
              Map<String, dynamic> customerData = json.decode(customerJson);

              setState(() {
                fullname = customerData['FULLNAME'];
              });
            } else {
              print(
                  "Không tìm thấy thông tin khách hàng trong SharedPreferences.");
            }
            print(
                "Thông tin khách hàng đã được lưu vào SharedPreferences dưới dạng JSON.");
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
      payload =
          payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
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
                  image: AssetImage("assets/images/appbar_menu.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [myorange.withOpacity(0.8), primary.withOpacity(0.7)],
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
                  fontSize: 16, fontWeight: FontWeight.w400, color: greymenu),
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
                    _buildServiceOption(
                        "Giao hàng", Icons.delivery_dining_sharp),
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
// Tiêu đề
            Text(
              "Có thể bạn sẽ thích",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: favoritePlaces.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripPicker(),
                        settings: RouteSettings(
                          arguments: {
                            "address": favoritePlaces[index]
                                ['location'], // Chỉ gửi địa chỉ
                            "latitude": favoritePlaces[index]
                                ['lat'], // Tọa độ lat
                            "longitude": favoritePlaces[index]
                                ['lng'], // Tọa độ lng
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            favoritePlaces[index]['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image,
                                  size: 50, color: Colors.black);
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                favoritePlaces[index]['name'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                favoritePlaces[index]['location'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
