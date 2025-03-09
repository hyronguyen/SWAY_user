import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:http/http.dart' as http;

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
      return km <= 3 ? 10000 : 10000 + (km - 3) * 3000;
    } else if (vehicleType == 'tietkiem') {
      return km <= 3 ? 8000 : 8000 + (km - 3) * 2000;
    } else if (vehicleType == 'luxury') {
      return km <= 3 ? 20000 : 20000 + (km - 3) * 10000;
    } else if (vehicleType == '4cho') {
      return km <= 3 ? 16000 : 16000 + (km - 3) * 7000;
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
            weatherFee = 10000; // Thêm phí thời tiết
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
                        double distance = _calculateDistance( widget.pickupLocation, widget.destinationLocation);

                        debugPrint('Điếm đón: ${widget.pickupAddress}');
                        debugPrint('Điểm đến: ${widget.destinationAddress} - cách $distance km');
                        debugPrint('Phương tiện: ${widget.vehicleType}');
                        debugPrint('Phí cước: ${formatCurrency(fare)} + phí thời tiết: ${formatCurrency(weatherFee)}');
                        debugPrint('Phương thức thanh toán: $_selectedPaymentMethod');
                        debugPrint('Thời tiết: $weatherCondition');
                        debugPrint('ID khách hàng: ${widget.customer_id}');
          
                         
                      },
                      child: 
                      Text(
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
                            debugPrint('Tìm Tài Xế');
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
