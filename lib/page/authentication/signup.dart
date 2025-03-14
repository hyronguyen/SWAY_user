import 'package:flutter/material.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/data/model/user.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/authentication/signup_email_verify.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:sway/page/authentication/signup_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

////////////////////////////// KHAI BÁO BIẾN  ////////////////////////////////////////////////////////
  TextEditingController phoneTextController = TextEditingController(); // Số điện thoại
  TextEditingController nameTextController = TextEditingController(); // Họ và tên
  TextEditingController emailTextController = TextEditingController(); // Mail
  final UserController userController = UserController(); // Khởi tạo Usercontroller

  String? _selectedGender = "Nam"; //Giới tính 
  bool isTermsAccepted = false; //Điều khoản sử dụng
  String CountryNumber = "+84" ;
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
    // Dữ liệu tháng và năm cho dropdown
  List<int> months = List.generate(12, (index) => index + 1);
  List<int> years = List.generate(100, (index) => 1920 + index);
    // Lấy năm hiện tại
  int currentYear = DateTime.now().year;

  // Tạo danh sách các ngày
  List<int> days = List.generate(31, (index) => index + 1);

  TextEditingController phoneNumberController = TextEditingController();
  String _selectedCountryCode = '+84'; // Mã quốc gia mặc định (Việt Nam)

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Đăng ký"),
        centerTitle: true,
        backgroundColor: backgroundblack,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameTextController,
                      decoration: const InputDecoration(
                        labelText: "Họ và tên",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailTextController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1), // Viền cho toàn bộ thẻ
                        borderRadius: BorderRadius.circular(4), // Bo tròn viền
                      ),
                      child: Row(
                        children: [
                          // Chọn mã quốc gia và cờ quốc gia
                          Container(
                            width: 122,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.white, width: 1), // Đường kẻ ngăn giữa
                              ),
                            ),
                            child: CountryCodePicker(
                              onChanged: (country) {
                                setState(() {
                                  _selectedCountryCode = country.dialCode!;
                                });
                              },
                              initialSelection: 'VN',
                              showCountryOnly: true,
                              alignLeft: true,
                              dialogBackgroundColor: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneTextController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Số điện thoại', // Hiển thị khi không nhập gì
                                hintStyle: TextStyle(color: Colors.white), // Màu chữ của hint
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                border: InputBorder.none, // Loại bỏ đường viền dưới
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Chọn ngày sinh
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,  // Căn giữa toàn bộ row
                      children: [
                        // Chọn ngày
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1), // Viền trắng
                              borderRadius: BorderRadius.circular(8), // Bo góc (nếu muốn)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2), // Thêm padding vào trong từng ô
                              child: DropdownButton<int>(
                                hint: Align(
                                  alignment: Alignment.center,  // Căn giữa hint
                                  child: Text(
                                    'Ngày',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                value: _selectedDay,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDay = value;
                                  });
                                },
                                isExpanded: true, // Đảm bảo dropdown mở rộng
                                items: days
                                    .map((day) => DropdownMenuItem<int>(
                                          value: day,
                                          child: Align(
                                            alignment: Alignment.center,  // Căn giữa chữ
                                            child: Text(day.toString(), style: TextStyle(color: Colors.white)),
                                          ),
                                        ))
                                    .toList(),
                              )
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Chọn tháng
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1), // Viền trắng
                              borderRadius: BorderRadius.circular(8), // Bo góc (nếu muốn)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2), // Thêm padding vào trong từng ô
                              child: DropdownButton<int>(
                                hint: Align(
                                  alignment: Alignment.center,  // Căn giữa hint
                                  child: Text(
                                    'Tháng',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                value: _selectedMonth,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                },
                                isExpanded: true, // Đảm bảo dropdown mở rộng
                                items: months
                                    .map((month) => DropdownMenuItem<int>(
                                          value: month,
                                          child: Align(
                                            alignment: Alignment.center,  // Căn giữa chữ
                                            child: Text(month.toString(), style: TextStyle(color: Colors.white)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Chọn năm
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1), // Viền trắng
                              borderRadius: BorderRadius.circular(8), // Bo góc (nếu muốn)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2), // Thêm padding vào trong từng ô
                              child: DropdownButton<int>(
                                hint: Align(
                                  alignment: Alignment.center,  // Căn giữa hint
                                  child: Text(
                                    'Năm',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                value: _selectedYear,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                },
                                isExpanded: true, // Đảm bảo dropdown mở rộng
                                items: years
                                    .map((year) => DropdownMenuItem<int>(
                                          value: year,
                                          child: Align(
                                            alignment: Alignment.center,  // Căn giữa chữ
                                            child: Text(year.toString(), style: TextStyle(color: Colors.white)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        "Giới tính",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                    Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1), // Viền trắng
                                borderRadius: BorderRadius.circular(8), // Bo tròn góc nếu cần
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // Thêm padding cho Radio
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'MALE',
                                    groupValue: _selectedGender,
                                    activeColor: const Color(0xFFedae10),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Nam',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20), // Thêm khoảng cách giữa các Radio
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'FEMALE',
                                    groupValue: _selectedGender,
                                    activeColor: const Color(0xFFedae10),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Nữ',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'OTHER',
                                    groupValue: _selectedGender,
                                    activeColor: const Color(0xFFedae10),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                  ),
                                  const Text(
                                    'Khác',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      value: isTermsAccepted,
                      onChanged: (value) {
                        setState(() {
                          isTermsAccepted = value!;
                        });
                      },
                      title: const Text(
                        "Tôi đồng ý với các điều khoản và chính sách",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      activeColor: const Color(0xFFedae10),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero, 
                    ),
                    const SizedBox(height: 20),
                    FractionallySizedBox(
                      widthFactor: 1,
                      child:ElevatedButton(
                      onPressed:() => MakeSignup(context),
                      style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            backgroundColor: Color(0xFFedae10), // Đổi màu nền nút
                            foregroundColor: Colors.white, // Đổi màu chữ trên nút
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4), // Bo tròn viền nút
                            ),
                        ),
                    child:const Text("Đăng  Ký", style: TextStyle(fontSize: 16),)), 
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10), // Khoảng cách giữa Divider và chữ "or"
                          child: Text(
                            "or",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1), // Viền trắng
                              borderRadius: BorderRadius.circular(8), // Góc bo tròn nhẹ
                            ),
                            child: IconButton(
                              onPressed: () {
                                debugPrint("Đăng nhập với Facebook");
                              },
                              icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                debugPrint("Đăng nhập với Apple");
                              },
                              icon: const Icon(Icons.apple, color: Colors.white, size: 40),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                debugPrint("Đăng nhập với Google");
                              },
                              icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                      onPressed: () {
                        Navigator.push( context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 600),
                            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0); // Đi từ bên phải vào
                              const end = Offset.zero;
                              const curve = Curves.easeInOut;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Đã có tài khoản? ",
                              style: TextStyle(color: Colors.white), // Màu trắng cho phần đầu
                            ),
                            TextSpan(
                              text: "Đăng nhập ở đây",
                              style: TextStyle(color: Color(0xFFedae10), fontWeight: FontWeight.bold), // Màu vàng cho phần sau
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

void MakeSignup(BuildContext context) async {
  String email = emailTextController.text.trim();
  String phone = phoneTextController.text.trim();
  String fullname = nameTextController.text.trim();
  int? selectedDay = _selectedDay;
  int? selectedMonth = _selectedMonth;
  int? selectedYear = _selectedYear;

  // Kiểm tra nếu thông tin không đầy đủ
  if (fullname.isEmpty || email.isEmpty || phone.isEmpty || selectedDay == null || selectedMonth == null || selectedYear == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
    );
    return;
  }

  // Kiểm tra định dạng email
  if (!isValidEmail(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Địa chỉ email không hợp lệ")),
    );
    return;
  }

  // Kiểm tra định dạng số điện thoại
  if (!isValidPhone(phone)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Số điện thoại không hợp lệ")),
    );
    return;
  }

  // Kiểm tra sự tồn tại của email và số điện thoại
  bool isEmailAndPhoneExist = await userController.checkEmailAndPhone(email, phone);
  if (!isEmailAndPhoneExist) { // Nếu email hoặc phone đã tồn tại
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email hoặc số điện thoại đã tồn tại")),
    );
    return;
  }

  // Tạo ngày sinh từ các giá trị đã chọn (ngày, tháng, năm)
  DateTime birthdayDateTime = DateTime(selectedYear!, selectedMonth!, selectedDay!);
  
  // Chuyển DateTime thành String theo định dạng yyyy-MM-dd (chỉ lấy phần ngày)
  String birthdayString = "${birthdayDateTime.year}-${birthdayDateTime.month.toString().padLeft(2, '0')}-${birthdayDateTime.day.toString().padLeft(2, '0')}";

  // Kiểm tra _selectedGender không null
  if (_selectedGender == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng chọn giới tính")),
    );
    return;
  }

  // Tạo đối tượng User với các thông tin đã nhập
  User user = User(
    fullname: fullname,
    email: email,
    phone: phone,
    gender: _selectedGender!, // Sử dụng _selectedGender! vì đã kiểm tra null
    birthday: birthdayString, // Truyền birthday dưới dạng String
  );

  // Chuyển Map thành chuỗi JSON
  String userJson = json.encode(user.toJson());

  // Lưu thông tin vào SharedPreferences dưới dạng chuỗi JSON
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userInfo', userJson);

  // Chuyển đến màn hình SetPasswordScreen sau khi lưu
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => SetPasswordScreen(
        email: email,
        fullname: fullname,
        gender: _selectedGender!, // Kiểm tra null khi sử dụng
        phone: phone,
        birthday: birthdayString, // Truyền birthday dưới dạng String
      ),
    ),
  );
}


  // Hàm kiểm tra email
  bool isValidEmail(String email) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Hàm kiểm tra số điện thoại
  bool isValidPhone(String phone) {
    final RegExp regex = RegExp(r'^\d{10,11}$'); // Kiểm tra số điện thoại có 10-11 chữ số
    return regex.hasMatch(phone);
  }
}