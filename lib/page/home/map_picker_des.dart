import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'package:sway/config/icon.dart';
import 'package:sway/config/colors.dart';

class MapPickerDestination extends StatefulWidget {
  const MapPickerDestination({super.key});

  @override
  State<MapPickerDestination> createState() => _MapPickerDestinationState();
}

class _MapPickerDestinationState extends State<MapPickerDestination> {
  // LOCAL VARIABLES -----------------------------------------------------------------------------------------------------------------
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  Timer? _debounce;
  bool _isMoving = false;

// LIFE CYCLE -----------------------------------------------------------------------------------------------------------------
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

// FUNCTIONS -----------------------------------------------------------------------------------------------------------------
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

        setState(() {
          if (!mounted) return;
          _addressController.text = address;
          _selectedLocation = latLng;
        });
        debugPrint("🚩 Địa chỉ điểm đón: $address + ${_selectedLocation}");
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

//Layout -----------------------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BẠN MUỐN ĐẾN ĐÂU?",
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
              onMapEvent: (event) {

                // Xử ly sự kiện di chuyển bản đồ
                setState(() => _isMoving = true);
                _debounce?.cancel();
                _debounce = Timer(const Duration(seconds: 1), () {
                  if (!mounted) return; // Kiểm tra widget đã bị hủy chưa
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
            ],
          ),

          // PIN CHỌN VỊ TRÍ
          Center(
            child: _isMoving ? pinoff_icon : pin_icon
          ),

          // Ô THÔNG TIN ĐỊNH VỊ VÀ NÚT XÁC NHẬN
          Positioned(
            left: 10,
            right: 20,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundblack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [

                  // Ô THÔNG TIN ĐỊNH VỊ 
                  TextField(
                    readOnly: true,
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag, color: Colors.amber),
                      hintText: "Địa chỉ của bạn",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: greymenu,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 10),

                  //NÚT XÁC NHẬN VỊ TRÍ
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
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "Xác nhận điểm đến",
                        style: TextStyle(
                          fontSize: 18,
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
        ],
      ),
    );
  }
}
