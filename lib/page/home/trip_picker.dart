import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/page/home/confirmation.dart';
import 'package:sway/page/home/map_picker.dart';
import 'package:sway/page/home/map_picker_des.dart';
import 'package:sway/page/home/trip_confirmation.dart';

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
  List<Map<String, dynamic>> _suggestions = []; // Chứa cả tên địa điểm & tọa độ
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
          _suggestions =
              (data['features'] as List).map<Map<String, dynamic>>((item) {
            return {
              'place_name': item['place_name'],
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
          // Danh sách gợi ý trải dài đến cuối màn hình
          Expanded(child: _buildSuggestionsList()),

          // Nút xác nhận hành trình
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
                    _showVehicleSelection(context); // Hiển thị menu chọn phương tiện
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

          SizedBox(height: 20),
        ],
      ),
    );
  }

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

  // Build Widget danh sách gợi ý
  Widget _buildSuggestionsList() {
    return Container(
      color: backgroundblack,
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.location_on, color: Colors.white),
            title: Text(
              _suggestions[index]['place_name'],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Lat: ${_suggestions[index]['latitude']}, Lng: ${_suggestions[index]['longitude']}",
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              if (_activeController != null) {
                _activeController!.text = _suggestions[index]['place_name'];

                // Nếu là ô nhập điểm đón thì gán pickupLocation
                if (_activeController == _pickupController) {
                  pickupLocation = LatLng(
                    _suggestions[index]['latitude'],
                    _suggestions[index]['longitude'],
                  );
                }

                // Nếu là ô nhập điểm đến thì gán destinationLocation
                if (_activeController == _destinationController) {
                  destinationLocation = LatLng(
                    _suggestions[index]['latitude'],
                    _suggestions[index]['longitude'],
                  );
                }
              }
              setState(() => _suggestions = []);
            },
          );
        },
      ),
    );
  }

  void _showVehicleSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350 ,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Chọn phương tiện di chuyển",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.directions_car, color: primary),
                title: const Text("Xe máy"),
                onTap: () => _sendTripConfirmation(context, "xemay"),
              ),
              ListTile(
                leading: Icon(Icons.directions_bike, color: primary),
                title: const Text("4 chỗ"),
                onTap: () => _sendTripConfirmation(context, "4cho"),
              ),
              ListTile(
                leading: Icon(Icons.pedal_bike, color: primary),
                title: const Text("Luxury"),
                onTap: () => _sendTripConfirmation(context, "luxury"),
              ),
              ListTile(
                leading: Icon(Icons.pedal_bike, color: primary),
                title: const Text("Tiết kiệm"),
                onTap: () => _sendTripConfirmation(context, "tietkiem"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendTripConfirmation(BuildContext context, String vehicle) {
    Navigator.pop(context); // Đóng bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Confirmation(
          pickupAddress: _pickupController.text,
          destinationAddress: _destinationController.text,
          pickupLocation: pickupLocation!,
          destinationLocation: destinationLocation!,
          vehicleType:vehicle, // Gửi thông tin phương tiện qua màn hình tiếp theo
        ),
      ),
    );
  }
}
