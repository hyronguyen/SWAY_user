import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/home/map_picker.dart';
import 'package:sway/page/home/map_picker_des.dart';

class TripPicker extends StatefulWidget {
  @override
  _TripPickerState createState() => _TripPickerState();
}

class _TripPickerState extends State<TripPicker> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final String mapboxAccessToken = map_box_token;

  LatLng? pickupLocation;
  LatLng? destinationLocation;
  List<String> _suggestions = [];
  TextEditingController? _activeController; // Lưu ô nhập liệu đang chọn

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
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(query)}.json'
        '?access_token=$mapboxAccessToken&autocomplete=true&types=address,place,neighborhood,locality&country=VN';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _suggestions = data['features']
              .map<String>((item) => item['place_name'] as String)
              .toList();
        });
      } else {
        debugPrint("Lỗi API Mapbox: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    }
  }

//////////////////////////////////////////////LAYOUT///////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 233, 134, 42), const Color.fromARGB(255, 243, 192, 24)],
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
          // Danh sách gợi ý trải dài đến cuối màn hình
          Expanded(child: _buildSuggestionsList()),

          // Nút xác nhận hành trình
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 20), // Căn lề trái phải 16px
            child: FractionallySizedBox(
              widthFactor: 1, // Đảm bảo nút rộng theo toàn bộ phần còn lại
              child: ElevatedButton(
                onPressed: () {
                  debugPrint(
                      "Điểm đón: ${_pickupController.text} + ${pickupLocation}");
                  debugPrint(
                      "Điểm đến: ${_destinationController.text}+ ${destinationLocation}");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14), // Tạo chiều cao thoải mái cho nút
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

          SizedBox(height: 20),
        ],
      ),
    );
  }

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

  // Hàm hiện thị danh sách gợi ý
  Widget _buildSuggestionsList() {
    return Container(
      color: backgroundblack,
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading:
                Icon(Icons.flag, color: Colors.white), // Icon lá cờ bên trái
            title: Text(
              _suggestions[index],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              if (_activeController != null) {
                _activeController!.text =
                    _suggestions[index]; // Điền vào ô nhập hiện tại
              }
              setState(() => _suggestions = []);
            },
          );
        },
      ),
    );
  }
}
