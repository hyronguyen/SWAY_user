import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:http/http.dart' as http;
import 'package:sway/config/price_chart.dart';
import 'package:sway/page/Tracking/trip_tracking.dart';

///////////////////////////////// ATTRIBUTE ////////////////////////////////////////
class Confirmation extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final String vehicleType;
  final String customer_id;

///////////////////////////////// CONTRUCTOR ////////////////////////////////////////
  Confirmation({
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.vehicleType,
    required this.customer_id,
  });

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
///////////////////////////////// BIẾN CỤC BỘ ////////////////////////////////////////

  final MapController _mapController = MapController(); // Điều khiển bản đồ
  String _selectedPaymentMethod = 'Tiền mặt'; // Phương thức thanh toán
  String weatherCondition = "Đang tải..."; // Thông tin thời tiết
  double weatherFee = 0; // Phí thời tiết
  double fare = 0; // Tiền cước
  bool findingDriver = true;
  StreamSubscription<DocumentSnapshot>? _rideSubscription;
  Set<String> _blockedDrivers = {}; // Danh sách tài xế bị chặn cục bộ
  bool _isFindingDialogShowing = false;


///////////////////////////////// INIT & DiSPOSE ////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    getWeatherCondition(widget.pickupLocation);
    getRoute();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToBounds();
    });
  }

  @override
  void dispose() {
    _blockedDrivers.clear(); // Xóa danh sách khi widget bị dispose
    _rideSubscription?.cancel();
    super.dispose();
  }

///////////////////////////////// FUNCTION ////////////////////////////////////////
  // Hiển thị menu chọn phương thức thanh toán
  void _showPaymentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Tiền mặt'),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'Tiền mặt';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Thẻ tín dụng'),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'Thẻ tín dụng';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text('Ví điện tử'),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'Ví điện tử';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Tính khoản các giữa 2 điểm
  double _calculateDistance(LatLng start, LatLng end) {
    return Distance().as(LengthUnit.Kilometer, start, end);
  }

  // Tính tiền cước
  double _calculateFare(double km, String vehicleType) {
    if (vehicleType == 'xemay') {
      return km <= 3 ? km_xemay : km_xemay + (km - 3) * above_km_xemay;
    } else if (vehicleType == 'tietkiem') {
      return km <= 3 ? km_tietkiem : km_tietkiem + (km - 3) * above_km_tietkiem;
    } else if (vehicleType == 'luxury') {
      return km <= 3 ? km_luxury : km_luxury + (km - 3) * above_km_luxury;
    } else if (vehicleType == '4cho') {
      return km <= 3 ? km_4cho : km_4cho + (km - 3) * above_km_4cho;
    } else {
      throw ArgumentError('Invalid vehicle type: $vehicleType');
    }
  }

  // Lấy thôn tin thời tiết
  Future<void> getWeatherCondition(LatLng location) async {
    final String url =
        "http://api.weatherapi.com/v1/current.json?key=$weather_api_token&q=${location.latitude},${location.longitude}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String condition = data['current']['condition']['text'];

        debugPrint('Thời tiết: $condition');

        setState(() {
          if (!mounted) return;
          // Kiểm tra điều kiện thời tiết
          if (condition.contains("Rain") || condition.contains("Storm")) {
            weatherCondition = condition;
            weatherFee = weather_price; // Thêm phí thời tiết
          } else {
            weatherCondition = "Bình thường";
            weatherFee = 0;
          }

          // Cập nhật giá cước sau khi có phí thời tiết
          double km = _calculateDistance(
              widget.pickupLocation, widget.destinationLocation);
          fare = _calculateFare(km, widget.vehicleType) + weatherFee;
          debugPrint('Tổng cộng: $fare');
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy dữ liệu thời tiết: $e");
    }
  }

  // Hàm format tiền
  String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }

  // Di chuyển bản đồ đến vị trí của 2 điểm
  void _fitMapToBounds() {
    final bounds =
        LatLngBounds(widget.pickupLocation, widget.destinationLocation);
    final center =
        LatLng(widget.pickupLocation.latitude, widget.pickupLocation.longitude);
    _mapController.move(center, _calculateZoomLevel(bounds));
  }

  // Lấy tuyến đường từ điểm A đến điểm B
  Future<List<LatLng>> getRoute() async {
    List<LatLng> routePoints = [];
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${widget.pickupLocation.longitude},${widget.pickupLocation.latitude};${widget.destinationLocation.longitude},${widget.destinationLocation.latitude}?geometries=geojson&access_token=$map_box_token';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coordinates = data['routes'][0]['geometry']['coordinates'];

        routePoints =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        debugPrint("Lấy tuyến đường thành công");
        return routePoints;
      } else {
        debugPrint("Lỗi khi lấy tuyến đường: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi: $e");
    }
    return routePoints;
  }

  // Tính mức zoom cho bản đồ
  double _calculateZoomLevel(LatLngBounds bounds) {
    double distance =
        Distance().as(LengthUnit.Kilometer, bounds.northEast, bounds.southWest);

    // Giới hạn khoảng cách
    double minDistance = 1; // 1 km - zoom cao nhất
    double maxDistance = 50; // 50 km - zoom nhỏ nhất

    // Giới hạn mức zoom
    double maxZoom = 16.0; // Zoom lớn nhất
    double minZoom = 8.0; // Zoom nhỏ nhất

    // Đảm bảo khoảng cách nằm trong khoảng hợp lệ
    distance = distance.clamp(minDistance, maxDistance);

    // Tính zoom theo công thức tuyến tính
    double zoom = maxZoom -
        ((distance - minDistance) / (maxDistance - minDistance)) *
            (maxZoom - minZoom);

    return zoom;
  }

  // Gửi yêu cầu đặt xe đến Firebase
  Future<void> _sendRequesttoFirebase(String driverId) async {
    try {
      CollectionReference rideRequests =
          FirebaseFirestore.instance.collection('RIDE_REQUESTS');

      // 📌 Tạo một cuốc xe mới trong Firestore
      DocumentReference rideDocRef = await rideRequests.add({
        'pickup_address': widget.pickupAddress,
        'destination_address': widget.destinationAddress,
        'pickup_location': {
          'latitude': widget.pickupLocation.latitude,
          'longitude': widget.pickupLocation.longitude,
        },
        'destination_location': {
          'latitude': widget.destinationLocation.latitude,
          'longitude': widget.destinationLocation.longitude,
        },
        'vehicle_type': widget.vehicleType,
        'fare': fare,
        'weather_fee': weatherFee,
        'payment_method': _selectedPaymentMethod,
        'weather_condition': weatherCondition,
        'customer_id': widget.customer_id,
        'driver_id': driverId,
        'timestamp': FieldValue.serverTimestamp(),
        'request_status': 'pending'
      });

      debugPrint(
          '🚖 Yêu cầu đặt xe đã được gửi thành công với tài xế ID: $driverId');

      // 📌 Bắt đầu theo dõi trạng thái cuốc xe
      _trackRideStatus(rideDocRef.id, driverId);
    } catch (e) {
      debugPrint('⚠️ Lỗi khi gửi yêu cầu đặt xe: $e');
    }
  }

  // Hàm chọn tài xế
  Future<void> _choseDriver(LatLng userLocation, String vehicleType) async {
  findingDriver = true;
  _showFindingDriverDialog(context); // Chỉ hiển thị nếu chưa có dialog

  while (findingDriver) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('AVAILABLE_DRIVERS')
        .where('status', isEqualTo: 'available')
        .where('vehicle', isEqualTo: vehicleType)
        .get();

    List<Map<String, dynamic>> nearbyDrivers = [];

    for (var doc in snapshot.docs) {
      String driverId = doc.id;

      if (_blockedDrivers.contains(driverId)) continue;

      double driverLat = doc['latitude'];
      double driverLng = doc['longitude'];
      double kmDistance = Distance().as(
          LengthUnit.Kilometer, userLocation, LatLng(driverLat, driverLng));

      if (kmDistance <= 5.0) {
        nearbyDrivers.add({
          'id': driverId,
          'distance_km': kmDistance,
        });
      }
    }

    if (nearbyDrivers.isNotEmpty) {
      nearbyDrivers.sort((a, b) => a['distance_km'].compareTo(b['distance_km']));
      String driverId = nearbyDrivers.first['id'];

      debugPrint("✅ Đã chọn tài xế ID: $driverId");

      await _sendRequesttoFirebase(driverId); // Gửi yêu cầu

      findingDriver = false;
      return;
    } else {
      debugPrint("⚠️ Không tìm thấy tài xế, thử lại sau 5 giây...");
      await Future.delayed(Duration(seconds: 5));
    }
  }

  debugPrint("❌ Đã hủy tìm tài xế.");
  if (Navigator.canPop(context)) {
    _isFindingDialogShowing = false; // Cập nhật trạng thái dialog
    Navigator.pop(context);
  }
}


  // Kiểm tra trạng thái yêu cầu
  void _trackRideStatus(String rideId, String driverId) {
  _rideSubscription?.cancel();
  _rideSubscription = FirebaseFirestore.instance
      .collection('RIDE_REQUESTS')
      .doc(rideId)
      .snapshots()
      .listen((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      String requestStatus = snapshot.get('request_status');

      if (requestStatus == 'accepted') {
        debugPrint("🟢 Tài xế đã chấp nhận chuyến xe!");

        findingDriver = false;
        _isFindingDialogShowing = false; // Cập nhật trạng thái dialog

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

      } else if (requestStatus == 'denied') {
        debugPrint("⛔ Tài xế từ chối chuyến xe! Đưa vào danh sách chặn.");
        _blockedDrivers.add(driverId);

        FirebaseFirestore.instance
            .collection('RIDE_REQUESTS')
            .doc(rideId)
            .delete()
            .then((_) {
          debugPrint("🗑️ Đã xóa RIDE_REQUESTS của tài xế $driverId.");

          // Đợi 2 giây rồi tìm tài xế mới mà không đóng dialog
          Future.delayed(Duration(seconds: 2), () {
            _choseDriver(widget.pickupLocation, widget.vehicleType);
          });
        }).catchError((error) {
          debugPrint("⚠️ Lỗi khi xóa RIDE_REQUESTS: $error");
        });
      }
    }
  }, onError: (error) {
    debugPrint("⚠️ Lỗi khi theo dõi trạng thái chuyến xe: $error");
  });
}


  // Hiện popup chờ
  void _showFindingDriverDialog(BuildContext context) {
  if (_isFindingDialogShowing) return; // Nếu đã hiển thị, không gọi lại

  _isFindingDialogShowing = true; // Đánh dấu dialog đang hiển thị

  showDialog(
    context: context,
    barrierDismissible: false, // Không cho phép bấm ra ngoài để đóng
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: backgroundblack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: primary, size: 28),
            SizedBox(width: 10),
            Text(
              "Đang tìm tài xế...",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            CircularProgressIndicator(color: primary),
            SizedBox(height: 20),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                findingDriver = false;
                _isFindingDialogShowing = false; // Cập nhật trạng thái dialog
                Navigator.pop(context); // Đóng dialog
              },
              icon: Icon(Icons.close, color: Colors.white),
              label: Text(
                "Hủy tìm",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: greymenu,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
        ],
      );
    },
  ).then((_) {
    _isFindingDialogShowing = false; // Khi dialog đóng, cập nhật lại biến cờ
  });
}


////////////////////////////////// LAYOUT /////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cuốc xe'),
      ),
      body: Column(
        children: [
          // PHẦN HIỆM THỊ BẢN ĐỒ
          Expanded(
            flex: 3,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.pickupLocation,
                initialZoom: 13.0,
              ),
              children: [
                // BẢN ĐỒ
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/hothanhgiang9/cm6n57t2u007201sg15ac9swb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaG90aGFuaGdpYW5nOSIsImEiOiJjbTZuMnhsbWUwMmtkMnFwZDhtNmZkcDJ0In0.0OXsluwAO14jJxPMUowtaA',
                ),
                MarkerLayer(
                  // MARKET ĐIỂM ĐÓ Đón
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: widget.pickupLocation,
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    // MARKET ĐIỂM ĐÓ Đến
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: widget.destinationLocation,
                      child: Icon(
                        Icons.flag,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                // Vẽ tuyến đường
                FutureBuilder<List<LatLng>>(
                  future: getRoute(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi khi tải tuyến đường'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('Không có dữ liệu tuyến đường'));
                    }

                    return PolylineLayer(
                      polylines: [
                        Polyline(
                          points: snapshot.data!,
                          strokeWidth: 3.0,
                          color: primary, // Màu đường đi
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // PHẦN HIỆM THỊ THÔNG TIN
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: backgroundblack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đường kẻ ngăn cách
                    GestureDetector(
                      onTap: () {
                        double distance = _calculateDistance(
                            widget.pickupLocation, widget.destinationLocation);

                        debugPrint('Điếm đón: ${widget.pickupAddress}');
                        debugPrint(
                            'Điểm đến: ${widget.destinationAddress} - cách $distance km');
                        debugPrint('Phương tiện: ${widget.vehicleType}');
                        debugPrint(
                            'Phí cước: ${formatCurrency(fare)} + phí thời tiết: ${formatCurrency(weatherFee)}');
                        debugPrint(
                            'Phương thức thanh toán: $_selectedPaymentMethod');
                        debugPrint('Thời tiết: $weatherCondition');
                        debugPrint('ID khách hàng: ${widget.customer_id}');
                      },
                      child: Text(
                        'Xem thêm',
                        style: TextStyle(color: greymenu, fontSize: 16),
                      ),
                    ),
                    Divider(color: greymenu),
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.red),
                        SizedBox(width: 8),
                        Text(widget.pickupAddress,
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.flag, color: Colors.green),
                        SizedBox(width: 8),
                        Text(widget.destinationAddress,
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.directions_car, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(widget.vehicleType,
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Phương thức thanh toán
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Phương thức thanh toán:',
                            style: TextStyle(fontSize: 16)),
                        Spacer(),
                        TextButton(
                          onPressed: _showPaymentMenu,
                          child: Text(
                            _selectedPaymentMethod,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Divider(color: primary),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Tổng cộng: ',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Text('${formatCurrency(fare)}',
                            style: TextStyle(
                                fontSize: 16,
                                color: primary,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            LatLng pickup = LatLng(
                                widget.pickupLocation.latitude,
                                widget.pickupLocation.longitude);
                            _choseDriver(pickup, widget.vehicleType);
                          },
                          child: Text('Tìm tài xế',
                              style: TextStyle(
                                  fontSize: 16, color: backgroundblack)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
