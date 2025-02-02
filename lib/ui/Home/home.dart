import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'account':
        // Navigate to account screen
        break;
      case 'settings':
        // Navigate to settings screen
        break;
      case 'logout':
        // Handle logout action
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Home'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFFedae10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFedae10), width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.search),
              color: Colors.black,
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color(0xFFedae10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFedae10), width: 2),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              color: Colors.black,
              onPressed: () {},
            ),
          ),
        ],
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          onSelected: _handleMenuSelection,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'account',
              child: Text('Tài khoản'),
            ),
            const PopupMenuItem<String>(
              value: 'settings',
              child: Text('Cài đặt'),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(10.7769, 106.7009),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/hothanhgiang9/cm6n57t2u007201sg15ac9swb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
                  additionalOptions: const {
                    'access_token':
                        'pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
                  },
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.black,
            selectedItemColor: Color(0xFFedae10),
            unselectedItemColor: Colors.white,
            showSelectedLabels: true,
            iconSize: 30,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            elevation: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Yêu Thích',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.wallet),
                label: 'Ví ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Tài khoản',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
