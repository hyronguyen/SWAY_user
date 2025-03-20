import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/home/confirmation.dart';
import 'package:sway/page/home/map_picker.dart';
import 'package:sway/page/home/map_picker_des.dart';

import 'package:sway/Controller/favorite_controller.dart';

class TripPicker extends StatefulWidget {
  final String? initialAddress; // Nhận địa chỉ từ FavoriteScreen
   const TripPicker({super.key, this.initialAddress});
  
  @override
  _TripPickerState createState() => _TripPickerState();
  

}

class _TripPickerState extends State<TripPicker> {
  // LOCAL VARIBLES //////////////////////////////////////////////////////////////////////////////
  final TextEditingController _pickupController = TextEditingController();
  
  final TextEditingController _destinationController = TextEditingController();
  String? customerid;
  String mapboxAccessToken = map_box_token;
  LatLng? pickupLocation;
  LatLng? destinationLocation;
  List<Map<String, dynamic>> _suggestions = [];
  List<Map<String, dynamic>> _favoriteLocations = [];
   final FavoriteController _favoriteController = FavoriteController();
   List<Map<String, dynamic>> _favorites = [];


  // Chứa cả tên địa điểm & tọa độ
  TextEditingController? _activeController; // Lưu ô nhập liệu đang chọn

// INIT & DISPOSE //////////////////////////////////////////////////////////////////////////
@override
void initState() {
  super.initState();
  _loadCustomerId(); 
  _fetchFavorites();
  if (widget.initialAddress != null) {
      _destinationController.text = widget.initialAddress!; // Cập nhật ô nhập điểm đến
    } // Thay đổi từ _fetchFavoriteLocations() thành _fetchFavorites()
}


  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

// FUNCTIONS //////////////////////////////////////////////////////////////////////////////

  // Lấy CUSTOMER id từ SharePreferences
  Future<void> _loadCustomerId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedCustomerId = prefs.getString('customer_id');

      setState(() {
        customerid = storedCustomerId ?? "customer_id_test";
      });

      // Nếu customer_id là "customer_id_test", hiển thị thông báo
      if (storedCustomerId == "customer_id_test") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bạn đang ở chế độ test với ID: customer_id_test"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint("_loadCustomerId: $e");
    }
  }

  // Hàm gửi thông tin hành trình
  void _sendTripConfirmation(BuildContext context, String vehicle) {
    try {
      Navigator.pop(context); // Đóng bottom sheet
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Confirmation(
            pickupAddress: _pickupController.text,
            destinationAddress: _destinationController.text,
            pickupLocation: pickupLocation!,
            destinationLocation: destinationLocation!,
            vehicleType: vehicle,
            customer_id: customerid ?? 'null',
          ),
        ),
      );
    } catch (e) {
      debugPrint("_sendTripConfirmation: $e");
    }
  }

  // Hàm hiển thị menu chọn phương tiện
  void _showVehicleSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chọn phương tiện di chuyển",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.motorcycle_rounded, color: primary),
                title: const Text("Xe máy"),
                onTap: () => _sendTripConfirmation(context, "xemay"),
              ),
              ListTile(
                leading: Icon(Icons.directions_car, color: primary),
                title: const Text("4 chỗ"),
                onTap: () => _sendTripConfirmation(context, "4cho"),
              ),
              ListTile(
                leading: Icon(Icons.electric_car_outlined, color: primary),
                title: const Text("Luxury"),
                onTap: () => _sendTripConfirmation(context, "luxury"),
              ),
              ListTile(
                leading: Icon(Icons.bike_scooter, color: primary),
                title: const Text("Tiết kiệm"),
                onTap: () => _sendTripConfirmation(context, "tietkiem"),
              ),
            ],
          ),
        );
      },
    );
  }


 Future<void> _toggleFavorite(int index) async {
  final place = _suggestions[index];
  
  debugPrint("Địa điểm cần xóa: ${place['place_name']}, tọa độ: (${place['latitude']}, ${place['longitude']})");

  // Lấy tọa độ từ _suggestions
  double lat = place['latitude'];
  double lng = place['longitude'];

  // Kiểm tra xem địa điểm có trong danh sách yêu thích không
  bool isFav = _isFavorite(lat, lng);

  if (isFav) {
    debugPrint("🔥 Xóa khỏi danh sách yêu thích!");

    // Tìm ID từ danh sách yêu thích dựa trên tọa độ
    final favoriteLocation = _favoriteLocations.firstWhere(
  (fav) =>
    fav['coordinates']['lat'] == lat &&
    fav['coordinates']['lng'] == lng,
  orElse: () => {} // Trả về một Map rỗng nếu không tìm thấy phần tử
     );

    if (favoriteLocation != null) {
      final placeId = favoriteLocation['id']; // Lấy id của địa điểm yêu thích

      if (placeId != null) {
        debugPrint("Địa điểm cần xóa: $placeId");
        await _favoriteController.removeFavorite(placeId); // Gọi API xóa địa điểm yêu thích
      } else {
        debugPrint("ID của địa điểm yêu thích không hợp lệ!");
      }
    } else {
      debugPrint("Không tìm thấy địa điểm yêu thích trùng tọa độ!");
    }
  } else {
    debugPrint("⭐ Thêm vào danh sách yêu thích!");
    await _favoriteController.addToFavorite({
      "location_name": place['place_name'],
      "address": place['address'],
      "latitude": lat,
      "longitude": lng,
    });
  }

  // Cập nhật danh sách yêu thích từ API sau khi thay đổi
  await _fetchFavorites(); // Lấy lại danh sách yêu thích
  setState(() {}); // Cập nhật giao diện
}




Future<void> _fetchFavorites() async {
  try {
    // Lấy danh sách yêu thích từ controller
    List<Map<String, dynamic>> locations = await _favoriteController.fetchFavoriteLocations();

    // Kiểm tra phản hồi và gán dữ liệu vào _favoriteLocations
    if (locations.isNotEmpty) {
      setState(() {
        _favoriteLocations = locations;
      });
    } else {
      debugPrint("Không có dữ liệu yêu thích.");
    }

    // In ra dữ liệu sau khi lấy được từ API
    debugPrint("Dữ liệu yêu thích từ API: $_favoriteLocations");

  } catch (e) {
    debugPrint("Lỗi khi lấy danh sách yêu thích: $e");
  }
}


Future<void> _addFavorite(int index, List<Map<String, dynamic>> suggestions) async {
  final place = suggestions[index];

  debugPrint("📌 Dữ liệu được chọn: $place"); // In log để kiểm tra dữ liệu

  if (place['place_name'] == null || place['place_name'].toString().trim().isEmpty) {
    debugPrint("⚠️ Lỗi: place_name bị null hoặc rỗng!");
    return;
  }

  if (place['latitude'] == null || place['longitude'] == null) {
    debugPrint("⚠️ Lỗi: Tọa độ không hợp lệ!");
    return;
  }

  debugPrint("📌 Đã kiểm tra xong, gửi dữ liệu lên API...");

  await _favoriteController.addToFavorite({
    "location_name": place['place_name'],
    "address": place['address'],
    "latitude": place['latitude'],
    "longitude": place['longitude'],
  });

  setState(() {}); // Cập nhật UI nếu cần
}



Future<void> _removeFavorite(int locationId) async {
  await _favoriteController.removeFavorite(locationId);
  setState(() {}); // Cập nhật UI sau khi xóa
}

  //Hàm mở map picker
  Future<void> _openMapPickerPickup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPicker()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _pickupController.text = result['address'];
        pickupLocation = LatLng(
          result['latitude'] as double,
          result['longitude'] as double,
        );
      });
    }
  }

 bool _isFavorite(double lat, double lng) {
  return _favoriteLocations.any((fav) {
    // Kiểm tra xem có tọa độ hay không trong dữ liệu yêu thích
    var favoriteLat = fav['coordinates'] != null ? fav['coordinates']['lat'] : fav['latitude'];
    var favoriteLng = fav['coordinates'] != null ? fav['coordinates']['lng'] : fav['longitude'];

    return favoriteLat == lat && favoriteLng == lng;
  });
}



  //Hàm mở map picker_ điểm đến
  Future<void> _openMapPickerDes() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerDestination()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _destinationController.text = result['address'];
        destinationLocation = LatLng(
          result['latitude'] as double,
          result['longitude'] as double,
        );
      });
    }
  }


  // Hàm lấy gợi ý từ Mapbox/Geocoding API
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) return;

    final url =
        'https://api.mapbox.com/search/geocode/v6/forward?q=${Uri.encodeComponent(query)}&proximity=ip&country=VN&language=vi&access_token=$mapboxAccessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _suggestions =
              (data['features'] as List).map<Map<String, dynamic>>((item) {
            return {
              'place_name': item['properties']['name'],
              'address': item['properties']['full_address'],
              'latitude': item['geometry']['coordinates'][1],
              'longitude': item['geometry']['coordinates'][0],
            };
          }).toList();
        });
      } else {
        debugPrint("Lỗi API Mapbox: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    }
  }

  //LAUOUT --------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 233, 134, 42),
                  const Color.fromARGB(255, 243, 192, 24)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child:
                          Icon(Icons.close, color: backgroundblack, size: 30),
                    ),
                    if (_activeController ==
                        _pickupController) // Chỉ hiển thị khi chọn ô nhập điểm đón
                      GestureDetector(
                        onTap: () {
                          debugPrint("Chọn điểm đón trên bản đồ");
                          _openMapPickerPickup();
                        },
                        child: Icon(Icons.map_rounded,
                            color: Colors.black, size: 30),
                      ),
                    if (_activeController ==
                        _destinationController) // Chỉ hiển thị khi chọn ô nhập điểm đến
                      GestureDetector(
                        onTap: () {
                          debugPrint("Chọn điểm đến trên bản đồ");
                          _openMapPickerDes();
                        },
                        child: Icon(Icons.map_rounded,
                            color: Colors.black, size: 30),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _pickupController,
                  hint: "Nhập điểm đón",
                  icon: Icons.location_on,
                ),
                SizedBox(height: 10),
                _buildInputField(
                  controller: _destinationController,
                  hint: "Nhập điểm đến",
                  icon: Icons.flag,
                ),
              ],
            ),
          ),

          SizedBox(height: 10),
          // Các nút chức năng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(Icons.home, "Nhà"),
              _buildActionButton(Icons.business, "Văn phòng"),
              _buildActionButton(Icons.favorite, "Yêu thích"),
              _buildActionButton(Icons.flight, "Sân bay"),
            ],
          ),

          Divider(
            color: greymenu, // Màu của đường kẻ
            thickness: 1, // Độ dày của đường kẻ
            height: 20, // Khoảng cách giữa các thành phần trên và dưới Divider
          ),

          // Danh sách gợi ý hoặc Danh sách lịch sử
          Expanded(
            child: _activeController == _pickupController ||
                    _activeController == _destinationController
                ? _buildSuggestionsList()
                : _buildHistoryList(),
          ),

         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  child: FractionallySizedBox(
    widthFactor: 1,
    child: ElevatedButton(
      onPressed: () {
  if (_pickupController.text.isEmpty ||
      _destinationController.text.isEmpty ||
      pickupLocation == null ||
      destinationLocation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter your trip details')),
    );
  } else {
    // Kiểm tra nếu pickupLocation và destinationLocation không null
    if (pickupLocation != null && destinationLocation != null) {
      // Chuyển đến trang Confirmation với các tham số không null
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Confirmation(
            pickupAddress: _pickupController.text,
            destinationAddress: _destinationController.text,
            pickupLocation: pickupLocation!,
            destinationLocation: destinationLocation!,
            vehicleType: "default", // Loại phương tiện có thể là mặc định hoặc do bạn chọn
            customer_id: "customer_id",  // Thay thế "customer_id" bằng ID thực tế
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select valid locations')),
      );
    }
  }
},
      
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, // Thay thế `primary` nếu cần
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text(
        "Xác nhận hành trình",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  ),
),

        ],
      ),
    );
  }
// WIDGETS --------------------------------------------------------------------------------
  // Build Widget ô nhập liệu
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      onTap: () {
        setState(() => _activeController = controller); // Xác định ô đang chọn
      },
      onChanged: (value) => _getSuggestions(value),
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.black),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

Widget _buildSuggestionsList() {
  return Container(
    color: backgroundblack,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Danh sách gợi ý",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            padding: EdgeInsets.zero, // Loại bỏ padding mặc định
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.location_on, color: Colors.white),
                title: Text(
                  _suggestions[index]['place_name'],
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _suggestions[index]['address'], // Địa chỉ
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "Lat: ${_suggestions[index]['latitude']}, Lng: ${_suggestions[index]['longitude']}", // Toạ độ
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
             trailing: IconButton(
  icon: Icon(
    _isFavorite(
            _suggestions[index]['latitude'], _suggestions[index]['longitude'])
        ? Icons.favorite
        : Icons.favorite_border,
    color: _isFavorite(
            _suggestions[index]['latitude'], _suggestions[index]['longitude'])
        ? Colors.red
        : Colors.white, // Màu đỏ nếu đã yêu thích, trắng nếu chưa
  ),
  onPressed: () async {
    if (_isFavorite(
        _suggestions[index]['latitude'], _suggestions[index]['longitude'])) {
      debugPrint("❌ Xóa khỏi danh sách yêu thích: ${_suggestions[index]}");
      await _toggleFavorite(index); // Xóa khỏi danh sách yêu thích
    } else {
      debugPrint("✅ Thêm vào danh sách yêu thích: ${_suggestions[index]}");
      await _toggleFavorite(index); // Thêm vào danh sách yêu thích
    }

    setState(() {}); // Cập nhật UI
  },
),

                onTap: () {
  debugPrint("✅ Đã chọn địa điểm: $_suggestions[index]");

  if (_activeController != null) {
    _activeController!.text = _suggestions[index]['place_name'] ?? "";

    if (_activeController == _pickupController) {
      pickupLocation = LatLng(
        _suggestions[index]['latitude'] ?? 0.0,
        _suggestions[index]['longitude'] ?? 0.0,
      );
    }

    if (_activeController == _destinationController) {
      destinationLocation = LatLng(
        _suggestions[index]['latitude'] ?? 0.0,
        _suggestions[index]['longitude'] ?? 0.0,
      );
    }
  }
  setState(() => _suggestions = []);
},
              );
            },
          ),
        ),
      ],
    ),
  );
}


// Build Widget danh sách gợi ý
  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: greymenu,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // Build Widget danh sách lịch sử tìm kiếm
  Widget _buildHistoryList() {
    // Danh sách dữ liệu demo
    List<Map<String, dynamic>> demoHistory = [
      {
        "place_name": "Hồ Gươm, Hà Nội",
        "latitude": 21.0285,
        "longitude": 105.8520
      },
      {
        "place_name": "Chợ Bến Thành, TP HCM",
        "latitude": 10.7722,
        "longitude": 106.6983
      },
      {
        "place_name": "Cầu Rồng, Đà Nẵng",
        "latitude": 16.0605,
        "longitude": 108.2270
      },
      {
        "place_name": "Nhà thờ Đức Bà, TP HCM",
        "latitude": 10.7794,
        "longitude": 106.6992
      },
    ];

    return Container(
      color: backgroundblack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Đã tìm kiếm gần đây",
              style: TextStyle(
                color: primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.zero, // Loại bỏ padding mặc định
              itemCount: demoHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.history, color: Colors.white),
                  title: Text(
                    demoHistory[index]['place_name'],
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Lat: ${demoHistory[index]['latitude']}, Lng: ${demoHistory[index]['longitude']}",
                    style: TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    debugPrint(
                        "Chọn địa điểm: ${demoHistory[index]['place_name']}");
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
