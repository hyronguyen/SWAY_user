import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/mainpage.dart';
import 'package:sway/page/history/trip_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Trip {
  final int id;
  final String destination;
  final String origin;
  final String date;
  final String time;
  final String status;
  final String price;
  final String vehicleImage;
  final String serviceType;
  final String payment_method;
  final String endTime;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.status,
    required this.price,
    required this.vehicleImage,
    required this.serviceType,
    required this.payment_method,
    required this.endTime
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['TRIP_ID'],
      origin: json['PICKUP_POINT'],
      destination: json['DROPOFF_POINT'],
      date: json['START_TIME'],
      time: json['START_TIME'],  // You may adjust this based on your needs
      status: json['STATUS'],
      price: json['TOTAL_FARE'].toString(),
      vehicleImage: "assets/images/type_taxi.png", // You can adjust this to dynamically load images
      serviceType: json['PROMOTION_CODE'],  // Assuming service type is related to promotion code
      payment_method: json['PAYMENT_METHOD'],
      endTime: json['END_TIME'],

    );
  }
}

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedService = "Tất cả";
  List<Trip> trips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerIdAndTrips();
  }

  Future<void> _fetchCustomerIdAndTrips() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? customerIdString = prefs.getString('customer_id');  // Retrieve customer_id as String

    if (customerIdString != null) {
      // Chuyển đổi customer_id từ String sang int
      int? customerId = int.tryParse(customerIdString);

      if (customerId != null) {
        // Gọi hàm _fetchTrips với customer_id đã chuyển sang int
        await _fetchTrips(customerId);
      } else {
        // Xử lý trường hợp không thể chuyển đổi customer_id sang int
        print("Error: customer_id is not a valid integer");
      }
    } else {
      // Trường hợp không tìm thấy customer_id trong shared preferences
      print("No customer_id found in shared preferences");
    }
  }

  Future<void> _fetchTrips(int customerId) async {
    // Lấy token từ SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');  // Lấy token từ SharedPreferences

    if (token == null) {
      print("No token found in SharedPreferences");
      return;
    }

    // Tạo header cho yêu cầu HTTP
    Map<String, String> headers = {
      'Authorization': '$token',  // Thêm token vào header dưới dạng Bearer token
      'Content-Type': 'application/json'  // Đảm bảo kiểu nội dung là JSON
    };

    // Gửi yêu cầu HTTP với token trong header
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/TripManagement/get-trip-history?customer_id=$customerId'),
      headers: headers,  // Thêm headers vào yêu cầu
    );

    if (response.statusCode == 200) {
      List<dynamic> tripData = json.decode(response.body);
      setState(() {
        trips = tripData.map((json) => Trip.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error (e.g., show an error message to the user)
      print('Failed to load trips');
    }
  }

  // Hàm chuyển đổi định dạng ngày
  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('d MMM yyyy').format(parsedDate); // Định dạng "23 th 2 2025"
  }

  // Hàm chuyển đổi thời gian
  String formatTime(String time) {
    DateTime parsedTime = DateTime.parse(time);
    return DateFormat('HH:mm').format(parsedTime); // Định dạng "14:30"
  }

  // Hàm chuyển đổi trạng thái
  String formatStatus(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'FAILED':
        return 'Hủy';
      case 'ONGOING':
        return 'Trên đường';
      default:
        return 'Chưa xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách cuốc xe theo loại dịch vụ
    List<Trip> filteredTrips = trips.where((trip) {
      if (selectedService == "Tất cả") {
        return true;
      }
      return trip.serviceType == selectedService;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lịch sử hoạt động",
          style: TextStyle(
            color: Colors.white, 
          ),
        ),
        backgroundColor: backgroundblack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Mainpage()),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Bộ lọc dịch vụ cuộn ngang
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,  // Cuộn ngang
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text("Tất cả"),
                          selected: selectedService == "Tất cả",
                          selectedColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: selectedService == "Tất cả" ? Colors.black : Colors.white,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedService = "Tất cả";
                            });
                          },
                          showCheckmark: false,
                        ),
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text("Di chuyển"),
                          selected: selectedService == "Di chuyển",
                          selectedColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: selectedService == "Di chuyển" ? Colors.black : Colors.white,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedService = "Di chuyển";
                            });
                          },
                          showCheckmark: false,
                        ),
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text("Giao hàng"),
                          selected: selectedService == "Giao hàng",
                          selectedColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: selectedService == "Giao hàng" ? Colors.black : Colors.white,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedService = "Giao hàng";
                            });
                          },
                          showCheckmark: false,
                        ),
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text("Đồ ăn"),
                          selected: selectedService == "Đồ ăn",
                          selectedColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: selectedService == "Đồ ăn" ? Colors.black : Colors.white,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedService = "Đồ ăn";
                            });
                          },
                          showCheckmark: false,
                        ),
                        SizedBox(width: 8),
                        FilterChip(
                          label: Text("Quà tặng"),
                          selected: selectedService == "Quà tặng",
                          selectedColor: Colors.amber,
                          labelStyle: TextStyle(
                            color: selectedService == "Quà tặng" ? Colors.black : Colors.white,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              selectedService = "Quà tặng";
                            });
                          },
                          showCheckmark: false,
                        ),
                      ],
                    ),
                  ),
                ),
                // Danh sách các cuốc xe sau khi lọc
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      Color statusColor = trip.status == "COMPLETED" // Đảm bảo so khớp với giá trị trả về từ API
                          ? Colors.green // Màu xanh cho Hoàn thành
                          : (trip.status == "FAILED" // Kiểm tra trạng thái FAILED
                              ? Colors.red // Màu đỏ cho Hủy
                              : (trip.status == "ONGOING" // Kiểm tra trạng thái ONGOING
                                  ? Colors.orange // Màu cam cho Trên đường
                                  : Colors.grey)); // Màu mặc định nếu trạng thái không khớp

                      return Column(
                        children: [
                          ListTile(
                            leading: ClipOval(
                              child: Image.asset(
                                trip.vehicleImage,
                                width: 30,  // Điều chỉnh kích thước hình ảnh
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              'Từ ${trip.origin} đến ${trip.destination}',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${formatTime(trip.time)} - ${formatDate(trip.date)}',
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  formatStatus(trip.status),
                                  style: TextStyle(fontSize: 14, color: statusColor),
                                ),
                              ],
                            ),
                            trailing: Text(
                              trip.price + ' đ',
                              style: TextStyle(fontSize: 14, color: Colors.orangeAccent),
                            ),
                            onTap: () {
                              // Chuyển đến trang chi tiết cuốc xe
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailPage(trip: trip),
                                ),
                              );
                            },
                          ),
                          Divider(color: Colors.grey),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
