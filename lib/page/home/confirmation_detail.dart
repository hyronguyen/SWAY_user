import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sway/config/colors.dart';

// ATRIBUTES //////////////////////////////////////////////////////////////////////////////
class TripConfirmationDetail extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double distance;
  final String vehicleType;
  final String weatherCondition;
  final double weatherFee;
  final double fare;
  final String selectedPaymentMethod;

// CONTRUCTOR //////////////////////////////////////////////////////////////////////////////
  TripConfirmationDetail({
    required this.pickupAddress,
    required this.destinationAddress,
    required this.distance,
    required this.vehicleType,
    required this.weatherCondition,
    required this.weatherFee,
    required this.fare,
    required this.selectedPaymentMethod,
  });

  @override
  _TripConfirmationDetailState createState() => _TripConfirmationDetailState();
}

class _TripConfirmationDetailState extends State<TripConfirmationDetail> {
   

// INIT & DISPOSE //////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
  
  }

  @override
  void dispose() {
    super.dispose();
  }

// Function //////////////////////////////////////////////////////////////////////////////


  
// LAYOUT ////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    
    String formattedFare =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(widget.fare);

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

            _buildRouteCard(widget.pickupAddress, widget.destinationAddress, widget.distance),
            SizedBox(height: 20),


            // Nút Quay lại TripConfirmation
            FractionallySizedBox(
              widthFactor: 1,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text('Quay lại'),  
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

// BUID WIDGETS ////////////////////////////////////////////////////////////////////////////////
 
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
                Text("${widget.vehicleType}",
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
                Text(widget.weatherCondition, style: TextStyle(fontSize: 16)),
              ],
            ),

            if (widget.weatherFee > 0)
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.green),
                  SizedBox(width: 8),
                  Text("Chi phí thời tiết:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ')
                        .format(widget.weatherFee),
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
                      .format(widget.weatherFee),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
