import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class MapPickerDestination extends StatefulWidget {
  const MapPickerDestination({super.key});

  @override
  State<MapPickerDestination> createState() => _MapPickerDestinationState();
}

class _MapPickerDestinationState extends State<MapPickerDestination> {
  final MapController _mapController = MapController();
  final TextEditingController _addressController = TextEditingController();
  LatLng? _selectedLocation;
  Timer? _debounce;
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
  _debounce?.cancel(); // Hủy bỏ Timer nếu có
  _mapController.dispose(); // Giải phóng bộ nhớ của MapController
  _addressController.dispose(); // Giải phóng bộ nhớ của TextEditingController
  super.dispose();
}


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
        debugPrint("🚩 Địa chỉ: $address + ${_selectedLocation}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi lấy địa chỉ: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

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

    setState(() {
      if (!mounted) return;
      _selectedLocation = latLng;
    });

    _mapController.move(latLng, 16);
    _getAddressFromLatLng(latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chọn điểm bạn muốn đến"),
        automaticallyImplyLeading: true,
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
            child: Icon(
              Icons.location_pin,
              color: _isMoving ? Colors.white : Colors.amber,
              size: 40,
            ),
          ),

          Positioned(
            left: 10,
            right: 20,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF35383F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    readOnly: true,
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag, color: Colors.amber),
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
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text(
                        "Xác nhận điểm đến",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
