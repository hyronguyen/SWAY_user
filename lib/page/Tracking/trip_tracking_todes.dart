import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sway/config/colors.dart';
import 'package:http/http.dart' as http;
import 'package:sway/page/booking/driver_rate.dart';
import 'package:sway/page/defaultwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/page/history/history.dart';

class TripTrackingToDes extends StatefulWidget {
  final String rideId;
  final LatLng destinationLocation;
  final LatLng pickupLocation;
  final String driversId;

  const TripTrackingToDes(
      {Key? key,
      required this.rideId,
      required this.destinationLocation,
      required this.pickupLocation,
      required this.driversId})
      : super(key: key);

  @override
  _TripTrackingToDesState createState() => _TripTrackingToDesState();
}

class _TripTrackingToDesState extends State<TripTrackingToDes> {
  // LOCAL VARIBLE ////////////////////////////////////////////////////////////////////////
  late final MapController _mapController = MapController();
  LatLng _currentPosition = LatLng(10.7769, 106.7009);
  late LatLng _driverPosition = LatLng(10.7769, 106.7009);
  late StreamSubscription<Position> _positionStream;
  late StreamSubscription _driverStream;
  List<LatLng> routePoints = [];

  // LIFE CYCLE /////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    _currentPosition = widget.pickupLocation; // Đặt vị trí ban đầu
    _startTracking();
    _trackDriverLocation();
    listenForTripStatus();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _driverStream.cancel(); // Hủy lắng nghe vị trí tài xế
    super.dispose();
  }

  // FUNCTION /////////////////////////////////////////////////////////////////////////////

  Future<void> updateBookingDriver() async {
    try {
      // Step 1: Retrieve the token from shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(
          'token'); // Assuming the token is stored under the key 'token'

      if (token == null) {
        // Handle the case when there is no token stored
        print("No token found!");
        return;
      }

      // Step 2: Make the HTTP PUT request with the token
      final response = await http.put(
        Uri.parse(
            'http://10.0.2.2:8080/api/userManagement/update-booking-driver'),
        headers: {
          'Authorization':
              '$token', // Add the token in the Authorization header
          'Content-Type':
              'application/json', // Set the content type if necessary
        },
        // Include any request body if necessary, for example:
        // body: json.encode({...}),
      );

      if (response.statusCode == 200) {
        print('Booking driver updated successfully!');
        // Handle successful response
      } else {
        print('Failed to update booking driver: ${response.statusCode}');
        // Handle failure response
      }
    } catch (e) {
      print('Error updating booking driver: $e');
    }
  }

  void listenForTripStatus() {
    FirebaseFirestore.instance
        .collection("TRACKING_TRIP")
        .doc(widget.rideId)
        .snapshots()
        .listen((snapshot) async {
      // Mark this function as 'async'
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null && data['tracking_status'] == 'done') {
          // Call updateBookingDriver() and wait for it to complete
          await updateBookingDriver();

          // After updating the booking driver, navigate to the HistoryPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryPage(),
            ),
          );
        }
      }
    });
  }

  // Theo dõi vị trí khách hàng
  void _startTracking() {
    debugPrint("BẮT ĐẦU THEO DÕI KHÁCH HÀNG");

    var locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Cập nhật khi di chuyển trên 10m
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, _mapController.camera.zoom);
        // Di chuyển bản đồ theo vị trí mới
      });
    });
  }

  void _trackDriverLocation() {
    debugPrint("BẮT ĐẦU THEO DÕI TÀI XẾ");

    _driverStream = FirebaseFirestore.instance
        .collection("AVAILABLE_DRIVERS")
        .doc(widget.driversId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null &&
            data['latitude'] != null &&
            data['longitude'] != null) {
          double lat = data['latitude'];
          double lng = data['longitude'];

          debugPrint("📍 Tài xế cập nhật vị trí: Lat: $lat, Lng: $lng");

          setState(() {
            _driverPosition = LatLng(lat, lng);
          });
        } else {
          debugPrint("⚠️ Dữ liệu tài xế bị thiếu latitude hoặc longitude.");
        }
      } else {
        debugPrint("⚠️ Không tìm thấy tài xế với ID: ${widget.driversId}");
      }
    });
  }

  // Lấy tuyến đường từ tài xế đến khách hàng
  Future<List<LatLng>> getRoute() async {
    List<LatLng> routePoints = [];
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${_driverPosition.longitude},${_driverPosition.latitude};${widget.destinationLocation.longitude},${widget.destinationLocation.latitude}?geometries=geojson&access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        routePoints =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        debugPrint("✅ Lấy tuyến đường thành công");
        return routePoints;
      } else {
        debugPrint("⚠️ Lỗi khi lấy tuyến đường: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Lỗi: $e");
    }
    return routePoints;
  }

// LAYOUR //////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ĐI ĐẾN ĐÍCH'),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: FutureBuilder<List<LatLng>>(
                future: getRoute(), // Gọi API để lấy tuyến đường
                builder: (context, snapshot) {
                  List<LatLng> routePoints = snapshot.data ?? [];

                  return FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition,
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.mapbox.com/styles/v1/hothanhgiang9/cm6n57t2u007201sg15ac9swb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
                      ),

                      // Vẽ tuyến đường nếu dữ liệu đã sẵn sàng
                      if (snapshot.connectionState == ConnectionState.done &&
                          routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: routePoints,
                              color: Colors.pink,
                              strokeWidth: 4.0,
                            ),
                          ],
                        ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: widget.destinationLocation,
                            child: const Icon(
                              Icons.flag,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _driverPosition,
                            child: const Icon(
                              Icons.directions_car,
                              color: myorange,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            //Thông tin hành trình
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: greymenu,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          "https://static.tvtropes.org/pmwiki/pub/images/got_tyrion_lannister.png", // Thay bằng URL ảnh đại diện thật
                        ),
                      ),
                      title: Text(
                        "Nguyễn Văn A", // Thay bằng tên tài xế từ Firebase
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "⭐ 4.8 | Toyota Vios - Trắng"), // Đánh giá + Loại xe
                          Text("Biển số: 51H-12345"), // Biển số xe
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "Lat: ${_driverPosition.latitude.toStringAsFixed(5)}"),
                          Text(
                              "Lng: ${_driverPosition.longitude.toStringAsFixed(5)}"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.call),
                          label: Text("Gọi tài xế"),
                          onPressed: () {
                            // Gọi tài xế (có thể dùng URL launcher để gọi số điện thoại)
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.message),
                          label: Text("Nhắn tin"),
                          onPressed: () {
                            // Nhắn tin tài xế (có thể tích hợp chat)
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
