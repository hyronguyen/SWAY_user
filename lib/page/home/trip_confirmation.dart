import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:sway/config/api_token.dart';
import 'package:sway/config/colors.dart';
import 'package:http/http.dart' as http;

class TripConfirmation extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final LatLng pickupLocation;
  final LatLng destinationLocation;

  TripConfirmation({
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  @override
  _TripConfirmationState createState() => _TripConfirmationState();
}

class _TripConfirmationState extends State<TripConfirmation> {
  final Distance distance = Distance();
  String selectedPaymentMethod = 'Tiền mặt';
  String weatherCondition = "Đang tải...";
  double weatherFee = 0;
  double fare = 0;

  @override
  void initState() {
    super.initState();
    getWeatherCondition(widget.pickupLocation);
  }

  final List<Map<String, dynamic>> paymentMethods = [
    {"name": "Tiền mặt", "icon": Icons.money, "color": Colors.green},
    {
      "name": "Momo",
      "icon": Icons.account_balance_wallet,
      "color": Colors.pink
    },
    {"name": "ZaloPay", "icon": Icons.credit_card, "color": Colors.blue},
    {"name": "Thẻ ngân hàng", "icon": Icons.payment, "color": Colors.orange},
  ];

  double calculateDistance() {
    double km = distance.as(LengthUnit.Kilometer, widget.pickupLocation,
        widget.destinationLocation);
    return double.parse(km.toStringAsFixed(2));
  }

  double calculateFare(double km) {
    return km <= 3 ? 16000 : 16000 + (km - 3) * 5000;
  }

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
          double km = calculateDistance();
          fare = calculateFare(km) + weatherFee;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy dữ liệu thời tiết: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double km = calculateDistance();
    String formattedFare =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(fare);

    return Scaffold(
      appBar: AppBar(title: Text('Xác nhận chuyến đi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Giá cuốc xe", style: TextStyle(fontSize: 30)),
            Text(
              formattedFare,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: primary),
            ),
            SizedBox(height: 20),

            _buildRouteCard(
                widget.pickupAddress, widget.destinationAddress, km),
            SizedBox(height: 20),

            // Ô bấm chọn phương thức thanh toán (hiện popup)
            GestureDetector(
              onTap: () {
                _showPaymentOptions(context);
              },
              child: _buildPaymentSelectionBox(),
            ),
            SizedBox(height: 20),

            FractionallySizedBox(
              widthFactor: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint(
                      'Xác nhận: $formattedFare, Thanh toán: $selectedPaymentMethod');
                },
                icon: Icon(Icons.arrow_back),
                label: Text('Xác nhận chuyến đi'),  
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 16,color: backgroundblack),
                  backgroundColor: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget gộp cả điểm đón và điểm đến vào một card
  Widget _buildRouteCard(String pickup, String destination, double km) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 8),
                Text("Điểm đón", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text(pickup, style: TextStyle(fontSize: 16)),
            ),
            Row(
              children: [
                Icon(Icons.flag, color: Colors.blue),
                SizedBox(width: 8),
                Text("Điểm đến", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 32),
              child: Text(destination, style: TextStyle(fontSize: 16)),
            ),
            Divider(),
            Row(
              children: [
                Icon(Icons.directions_car, color: Colors.green),
                SizedBox(width: 8),
                Text("Khoảng cách",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text("$km km",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),

            Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.blue),
                SizedBox(width: 8),
                Text("Thời tiết:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(weatherCondition, style: TextStyle(fontSize: 16)),
              ],
            ),

            if (weatherFee > 0)
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Chi phí thời tiết:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                        .format(weatherFee),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

            SizedBox(height: 8), // Thêm khoảng cách giữa 2 dòng
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green),
                SizedBox(width: 8),
                Text("Chi phí thời tiết:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                      .format(weatherFee),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Ô bấm chọn phương thức thanh toán
  Widget _buildPaymentSelectionBox() {
    Map<String, dynamic> selectedMethod = paymentMethods
        .firstWhere((method) => method["name"] == selectedPaymentMethod);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(selectedMethod["icon"],
                    color: selectedMethod["color"], size: 30),
                SizedBox(width: 10),
                Text(
                  selectedMethod["name"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Icon(Icons.keyboard_arrow_down, size: 28),
          ],
        ),
      ),
    );
  }

  // Hiển thị popup chọn phương thức thanh toán
  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Chọn phương thức thanh toán",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Column(
                children: paymentMethods.map((method) {
                  return ListTile(
                    leading:
                        Icon(method["icon"], color: method["color"], size: 30),
                    title: Text(method["name"], style: TextStyle(fontSize: 16)),
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method["name"];
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
