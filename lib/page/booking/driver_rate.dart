import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sway/mainpage.dart';
import '../../controller/user_controller.dart'; // đường dẫn phù hợp với project bạn

class DriverRatingScreen extends StatefulWidget {
  final String tripId; // Thêm tripId vào constructor

  const DriverRatingScreen(
      {super.key, required this.tripId}); // Nhận tripId trong constructor

  @override
  State<DriverRatingScreen> createState() => _DriverRatingScreenState();
}

class _DriverRatingScreenState extends State<DriverRatingScreen> {
  int rating = 5;
  int? selectedTipAmount;
  final TextEditingController _reviewController = TextEditingController();
  final UserController _userController = UserController();
  final List<int> tipAmounts = [1, 2, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chuyến đi',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Driver info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nguyễn Minh Kha',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.9 (531 reviews)',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/car.png', // Add your car image here
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chọn số sao
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                "Bạn đánh giá chuyến đi này như thế nào?",
                style: TextStyle(color: Colors.grey[200], fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Viết đánh giá
              TextField(
                controller: _reviewController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Viết cảm nhận của bạn...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Chọn tip
              const Text("Tip cho tài xế",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: tipAmounts.map((amount) {
                  return ChoiceChip(
                    label: Text("\$$amount",
                        style: TextStyle(
                            color: selectedTipAmount == amount
                                ? Colors.black
                                : Colors.white)),
                    selected: selectedTipAmount == amount,
                    selectedColor: Colors.amber,
                    backgroundColor: Colors.grey[900],
                    onSelected: (_) {
                      setState(() {
                        selectedTipAmount = amount;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Nút gửi đánh giá
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => submitRating(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Gửi đánh giá",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void submitRating(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token") ?? "";
    int customerId = int.tryParse(prefs.getString("customer_id") ?? "0") ?? 0;

    print(customerId);
    int driverId = 1;
    int tripId = int.parse(widget.tripId); // Sử dụng tripId từ widget

    if (token.isEmpty || customerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Thiếu thông tin đăng nhập. Vui lòng đăng nhập lại.")),
      );
      return;
    }

    final success = await _userController.rateDriver(
      customerId: customerId,
      driverId: driverId,
      tripId: tripId,
      rating: rating.toDouble(),
      review: _reviewController.text,
      token: token,
    );

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Cảm ơn bạn"),
          content: const Text("Bạn đã đánh giá tài xế thành công!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Mainpage()));
              },
              child: const Text("Đóng"),
            )
          ],
        ),
      );
    } else if (success == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đánh giá đã tồn tại, vui lòng thử lại.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Gửi đánh giá thất bại, vui lòng thử lại.")),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
