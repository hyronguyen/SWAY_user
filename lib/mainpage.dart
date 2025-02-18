import 'package:flutter/material.dart';
import 'package:sway/page/favorite/favorite.dart';
import 'package:sway/page/home/home.dart';
import 'package:sway/page/walletscreen/wallet_screen.dart';
import 'page/defaultwidget.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm này trả về tên cho AppBar title và widget tương ứng
  _loadWidget(int index) {
    String nameWidgets = "Trang chủ";
    switch (index) {
      case 0:
        nameWidgets = "Trang chủ";
        return const HomeScreen();
      case 1:
        nameWidgets = "Yêu thích";
        return const FavoriteScreen();
      case 2:
        nameWidgets = "Ví";
        return const WalletScreen();
      case 3:
        nameWidgets = "Khuyến mãi";
        break;
      case 4:
        nameWidgets = "Hồ sơ";
        break;
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => Container(
            margin: EdgeInsets.fromLTRB(16, 8, 0, 7),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.amber[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.menu, size: 24),
              color: Colors.black,
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
              color: Colors.amber[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.search, size: 24),
              color: Colors.black,
              onPressed: () {},
            ),
          ),
          SizedBox(width: 16),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.amber[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications, size: 24),
              color: Colors.black,
              onPressed: () {},
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1F212A), // Thêm màu nền cho ListView
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF1F212A), // Màu nền của DrawerHeader,
                  border: Border(bottom: BorderSide(width: 0)),
                ),
                child: Column(
                  children: const [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        "https://googleflutter.com/sample_image.jpg",
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Nguyễn Hoàng Nghĩa',
                        style: TextStyle(color: Colors.white)),
                    Text("22DH112363@st.huflit.edu.vn",
                        style: TextStyle(color: Colors.white)),
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
                  Icons.location_on,
                  color: Colors.white, // Màu biểu tượng trắng
                ),
                title: const Text(
                  "Địa chỉ",
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
              icon: Icon(Icons.wallet),
              label: "Ví",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.percent),
              label: "Khuyến mãi",
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
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      body: _loadWidget(_selectedIndex),
    );
  }
}
