import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:sway/config/colors.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({super.key});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  Timer? _debounce;
  bool _isMoving = false;
  List<Marker> _nearbyDriversMarkers = [];

// INIT & DISPOSE /////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Hủy bỏ Timer nếu có
    _mapController.dispose(); // Giải phóng bộ nhớ của MapController
    _addressController.dispose(); // Giải phóng bộ nhớ của TextEditingController
    super.dispose();
  }
  // FUNCTIONS  /////////////////////////////////////////////////

// Hàm tìm tài xế gần điểm đón
  Future<void> _findNearbyDrivers(LatLng userLocation) async {
    setState(() {
      _nearbyDriversMarkers = [];
    });

    final double searchRadius = 5.0;
    final Distance distance = Distance();

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('AVAILABLE_DRIVERS')
          .where('status', isEqualTo: 'available')
          .get();

      List<Marker> markers = [];

      for (var doc in snapshot.docs) {
        double driverLat = doc['latitude'];
        double driverLng = doc['longitude'];

        LatLng driverLocation = LatLng(driverLat, driverLng);
        double kmDistance =
            distance.as(LengthUnit.Kilometer, userLocation, driverLocation);

        if (kmDistance <= searchRadius) {
          markers.add(
            Marker(
              point: driverLocation,
              width: 40,
              height: 40,
              child: Icon(
                Icons.location_history,
                color: myorange,
                size: 30,
              ),
            ),
          );
        }
      }

      setState(() {
        _nearbyDriversMarkers = markers;
      });

      debugPrint("👱 Tìm thấy ${markers.length} tài xế gần bạn.");
    } catch (e) {
      debugPrint("Lỗi tìm tài xế: $e");
    }
  }

// Hàm lấy địa chỉ từ tọa độ (lat, lng)
  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        List<String?> addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((part) => part != null && part.isNotEmpty).toList();

        String address = addressParts.join(", ");
        _findNearbyDrivers(latLng);

        setState(() {
          if (!mounted) return;
          _addressController.text = address;
          _selectedLocation = latLng;
        });
        debugPrint("🚩 Địa chỉ: $address + ${_selectedLocation}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi lấy địa chỉ: $e");
    }
  }

// Hàm lấy vị trí hiện tại
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    _showLoadingDialog(context);
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      LatLng latLng = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _selectedLocation = latLng;
      });

      _mapController.move(latLng, 16);
      _getAddressFromLatLng(latLng);
    } catch (e) {
      debugPrint("_getCurrentLocation: $e");
    }
    Future.delayed(Duration(milliseconds: 500), () {
      _hideLoadingDialog(context);
    });
  }

// Hàm hiển thị popup loading
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Ngăn người dùng tắt popup khi nhấn ra ngoài
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.amber), // Màu vàng
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Đang lấy vị trí...",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Hàm hiển thị popup loading
  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop(); // Đóng popup
  }

// Layout /////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VỊ TRÍ CỦA BẠN",
          style: TextStyle(color: backgroundblack, fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(
          color: backgroundblack, // Đổi màu icon về đen
        ),
        automaticallyImplyLeading: true,
        backgroundColor: primary,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(21.028511, 105.804817),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              // Bắt sự kiện di chuyển bản đồ
              onMapEvent: (event) {
                setState(() => _isMoving = true);
                _debounce?.cancel();
                // khi pin dừng lai 1s thì xác định vị trí
                _debounce = Timer(const Duration(seconds: 1), () {
                  if (!mounted) return;
                  LatLng center = event.camera.center;
                  _getAddressFromLatLng(center);
                  setState(() => _isMoving = false);
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/hothanhgiang9/cm6n57t2u007201sg15ac9swb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
              ),
              MarkerLayer(markers: _nearbyDriversMarkers),
            ],
          ),

          // PIN CHỌN VỊ TRÍ
          Center(
            child: Icon(
              Icons.location_pin,
              color: _isMoving ? Colors.white : primary,
              size: 40,
            ),
          ),

          // Thông tin đia chỉ
          Positioned(
            left: 10,
            right: 20,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundblack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_pin, color: Colors.white),
                      hintText: "Địa chỉ của bạn",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF35383F),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Xác nhận địa chỉ
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedLocation != null) {
                          Navigator.pop(context, {
                            'address': _addressController.text,
                            'latitude': _selectedLocation!.latitude,
                            'longitude': _selectedLocation!.longitude,
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: myorange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "Xác nhận điểm đón",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: backgroundblack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút lấy vị trí hiện tại
          Positioned(
            bottom: 170,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
