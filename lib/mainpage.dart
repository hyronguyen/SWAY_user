import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/favorite/favorite.dart';
import 'package:sway/page/home/map_picker.dart';
import 'package:sway/page/home/menu.dart';
import 'package:sway/page/setting/setting_main.dart';
import 'package:sway/page/walletscreen/wallet_screen.dart';
import 'page/defaultwidget.dart';
import 'dart:convert';


class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  String fullname = ''; 
  String email = ''; 
  final MainMenu mainMenu = MainMenu();
  final MapPicker mappicker = MapPicker();
  final WalletScreen walletScreen = WalletScreen();
  final SettingsScreen settingsScreen = SettingsScreen();
  final FavoriteScreen favoriteScreen = FavoriteScreen();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

   @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

    Future<void> _loadCustomerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerJson = prefs.getString('customer_data');

    if (customerJson != null) {
      Map<String, dynamic> customerData = json.decode(customerJson);

      setState(() {
        fullname = customerData['FULLNAME'];
        email = customerData['EMAIL'];

      });

    } else {
      print("Không tìm thấy thông tin khách hàng trong SharedPreferences.");
    }
  }

  // Hàm này trả về tên cho AppBar title và widget tương ứng
  _loadWidget(int index) {
    String nameWidgets = "Trang chủ";
    switch (index) {
      case 0:
        nameWidgets = "Trang chủ";
        return mainMenu;
      case 1:
        nameWidgets = "Yêu thích";
        return favoriteScreen;
      case 2:
        nameWidgets = "Ví";
        return walletScreen;
      case 3:
        nameWidgets = "Khuyến mãi";
        break;
      case 4:
        nameWidgets = "Hồ sơ";
        return settingsScreen;
      default:
        nameWidgets = "None";
        break;
    }
    return DefaultWidget(title: nameWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => Container(
            margin: EdgeInsets.fromLTRB(16, 8, 0, 7),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.menu, size: 24),
              color: backgroundblack,
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        title: Text(
          _selectedIndex == 0
              ? ''
              : _selectedIndex == 1
                  ? 'Yêu thích'
                  : _selectedIndex == 2
                      ? 'Ví'
                      : _selectedIndex == 3
                          ? 'Khuyến mãi'
                          : _selectedIndex == 4
                              ? 'Hồ sơ'
                              : '',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, size: 24),
              color: backgroundblack,
              onPressed: () {},
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,

      // SIDE BAR MENU
      drawer: Drawer(
        child: Container(
          color: backgroundblack, // Thêm màu nền cho ListView
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 233, 134, 42),
                      const Color.fromARGB(255, 243, 192, 24)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ), // Màu nền của DrawerHeader,
                  border: Border(bottom: BorderSide(width: 0)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        "https://static.tvtropes.org/pmwiki/pub/images/got_tyrion_lannister.png",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(fullname,
                        style: TextStyle(color: backgroundblack)),
                    Text(email,
                        style: TextStyle(color: greymenu)),
                  ],
                ),
              ),
              // Các ListTile cho mục trong Drawer
              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Tài khoản",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 0;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.favorite,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Yêu thích",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 1;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Lịch sử",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 2;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.report,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Góp ý",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 3;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.settings,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Cài đặt",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 4;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.question_mark,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Hỗ trợ",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 5;
                  setState(() {});
                },
              ),
              const Divider(color: Colors.white),
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Đăng xuất",
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
                onTap: () {
                  Navigator.pop(context);
                  _selectedIndex = 0;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 75,
        height: 85,
        child: ClipPath(
          clipper: HexagonClipper(),
          child: Material(
            color: Colors.amber,
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () {
                _onItemTapped(2);
              },
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Colors.black,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Trang chủ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Yêu thích",
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(), // Ẩn biểu tượng ở vị trí giữa
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: "Tin nhắn",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Hồ sơ",
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[400],
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      body: _loadWidget(_selectedIndex),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    Path path = Path();

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75); 
    path.lineTo(w * 0.5, h); 
    path.lineTo(0, h * 0.75); 
    path.lineTo(0, h * 0.25); 
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
