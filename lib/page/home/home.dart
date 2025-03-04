import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  List<Map<String, dynamic>> _availableDrivers = [];
  String selectedButton = "";

////////////////////////////////////FUNCTION///////////////////////////////////////////
  Future<void> _findNearbyDrivers(LatLng userLocation) async {
    final double searchRadius = 5.0; // Bán kính 1km
    final Distance distance = Distance(); // Thư viện tính khoảng cách

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('AVAILABLE_DRIVERS')
          .where('status', isEqualTo: 'available') // Chỉ lấy tài xế rảnh
          .get();

      debugPrint("🔥 Lấy danh sách tài xế từ Firestore:");
      for (var doc in snapshot.docs) {
        debugPrint("📌 Tài xế ID: ${doc.id} | Dữ liệu: ${doc.data()}");
      }

      List<Map<String, dynamic>> nearbyDrivers = [];

      for (var doc in snapshot.docs) {
        double driverLat = doc['latitude'];
        double driverLng = doc['longitude'];

        LatLng driverLocation = LatLng(driverLat, driverLng);
        double kmDistance =
            distance.as(LengthUnit.Kilometer, userLocation, driverLocation);

        if (kmDistance <= searchRadius) {
          nearbyDrivers.add({
            'id': doc.id,
            'latitude': driverLat,
            'longitude': driverLng,
            'distance': kmDistance,
          });
        }
      }

      setState(() {
        _availableDrivers = nearbyDrivers;
      });

      debugPrint("👱 Tìm thấy ${nearbyDrivers.length} tài xế gần đó.");
    } catch (e) {
      debugPrint("Lỗi tìm tài xế: $e");
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";

        // Loại bỏ dấu ",,," dư thừa
        address = address.replaceAll(RegExp(r',\s*,+'), ',').trim();
        debugPrint(" 🚩 Địa chỉ: $address");
        _findNearbyDrivers(latLng);

        setState(() {
          _addressController.text = address;
        });
      }
    } catch (e) {
      print("Lỗi lấy địa chỉ: $e");
    }
  }

  // Lấy vị trí hiện tại và cập nhật địa chỉ
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra quyền truy cập vị trí
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Lấy tọa độ vị trí hiện tại
    Position position = await Geolocator.getCurrentPosition();
    LatLng latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _selectedLocation = latLng;
    });

    _mapController.move(latLng, 16);
    _getAddressFromLatLng(latLng);
  }

  // Tìm kiếm vị trí theo địa chỉ nhập vào
  Future<void> _searchLocationByAddress() async {
    String address = _addressController.text;
    if (address.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng latLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = latLng;
        });

        _mapController.move(latLng, 16);
      }
    } catch (e) {
      print("Lỗi tìm vị trí: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(10.7769, 106.7009),
              initialZoom: 13,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                _getAddressFromLatLng(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/hothanhgiang9/cm6n57t2u007201sg15ac9swb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 30,
                      height: 30,
                      child: const Icon(Icons.location_pin,
                          color: Colors.amber, size: 30),
                    ),
                  ],
                ),
            ],
          ),

          // Ô nhập địa chỉ
          Positioned(
            left: 10,
            right: 20,
            bottom: 50,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF35383F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.white),
                      hintText: "Địa chỉ của bạn?",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF35383F),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: "Bạn đang muốn đi đâu?",
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF35383F),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedButton = "move";
                            });
                            debugPrint("🚀 Di chuyển");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedButton == "move"
                                ? Colors.amber
                                : Colors.transparent,
                            foregroundColor: selectedButton == "move"
                                ? Colors.white
                                : Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              
                            ),
                          ),
                          child: const Text("Di chuyển"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedButton = "ship";
                            });
                            debugPrint("🚀 Xếp hàng");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedButton == "ship"
                                ? Colors.amber
                                : Colors.transparent,
                            foregroundColor: selectedButton == "ship"
                                ? Colors.white
                                : Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Ship hàng"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Nút tìm vị trí hiện tại
          Positioned(
            bottom: 260,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF35383F),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
