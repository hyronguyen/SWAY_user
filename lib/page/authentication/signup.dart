import 'package:flutter/material.dart';
import 'package:sway/Controller/user_controller.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/authentication/signup_phone_verify.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

////////////////////////////// KHAI BÁO BIẾN  ////////////////////////////////////////////////////////
  
  TextEditingController phoneTextController = TextEditingController(); // Số điện thoại
  TextEditingController nameTextController = TextEditingController(); // Họ và tên
  TextEditingController mailTextController = TextEditingController(); // Mail
  String? selectedGender = "nam"; //Giới tính 
  bool isTermsAccepted = false; //Điều khoản sử dụng
  String CountryNumber = "+84" ;

////////////////////////////// LAYOUT ///////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Đăng ký'),
        automaticallyImplyLeading: false,
             centerTitle: true,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
         
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Họ và Tên
                    TextField(
                      controller: nameTextController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Họ và Tên",
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

                    // Số điện thoại
                    Row(
                    children: [
                      // Dropdown chọn mã quốc gia
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: CountryNumber,
                          items: ["+84", "+1", "+44", "+91", "+81"].map((String code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(code, style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                             setState(() {
                                CountryNumber = value!; // Cập nhật biến khi chọn mã quốc gia mới
                              });
                          },
                          dropdownColor: Colors.black,
                          underline: Container(),
                        ),
                      ),
                      const SizedBox(width: 8), // Khoảng cách giữa dropdown và ô nhập

                      // Ô nhập số điện thoại
                      Expanded(
                        child: TextField(
                          controller: phoneTextController,
                          keyboardType: TextInputType.number,
                          maxLength: 9, // Chỉ cho phép nhập 9 số
                          decoration: const InputDecoration(
                            labelText: "Số điện thoại",
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 2),
                            ),
                            counterText: "", // Ẩn bộ đếm ký tự
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                    const SizedBox(height: 20),

                    // Email
                    TextField(
                      controller: mailTextController,
                      keyboardType: TextInputType.emailAddress,
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

                    // Giới tính
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Giới tính:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            items: const [
                              DropdownMenuItem(
                                value: "nam",
                                child: Text("Nam"),
                              ),
                              DropdownMenuItem(
                                value: "nữ",
                                child: Text("Nữ"),
                              ),
                              DropdownMenuItem(
                                value: "khác",
                                child: Text("Khác"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Đồng ý điều khoản
                    CheckboxListTile(
                      value: isTermsAccepted,
                      onChanged: (value) {
                        setState(() {
                          isTermsAccepted = value!;
                        });
                      },
                      title: const Text(
                        "Tôi đồng ý với các điều khoản và chính sách.",
                        style: TextStyle(color: Color(0xFFedae10)),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFedae10),
                    ),

                    const SizedBox(height: 20),


                  FractionallySizedBox(
                    widthFactor: 1,
                    child:ElevatedButton(
                    onPressed:MakeSignup,
                    style: ElevatedButton.styleFrom(
                          
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          backgroundColor: Color(0xFFedae10), // Đổi màu nền nút
                          foregroundColor: Colors.white, // Đổi màu chữ trên nút
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bo tròn viền nút
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

                  // Đăng nhập bằng Socialmedia
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

                  const SizedBox(height: 20),
               
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
              ),
            ],
          ),
        ),
      ),
    );
  }
////////////////////////////// SUB-FUNCTIONS ////////////////////////////////////////////////////////////
  
  // Hàm kiểm tra email 
  bool isValidEmail(String email) {
  final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return regex.hasMatch(email);
}

// Hàm kiểm tra số điện thoại
  bool isValidPhone(String phone) {
    final RegExp regex = RegExp(r'^[0-9]{9}$');
    return regex.hasMatch(phone);
  }

  void MakeSignup ()async{
                      Usercontroller userController = Usercontroller();
                      String fullPhoneNumber = CountryNumber + phoneTextController.text;
                      debugPrint(fullPhoneNumber);
                      // Kiểm tra đã đồng ý điều khoản
                      if (!isTermsAccepted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Bạn phải đồng ý với điều khoản.")),
                        );
                        return;
                      }
                      // Kiểm tra email
                      if (!isValidEmail(mailTextController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email không hợp lệ.")),
                        );
                        return;
                      }

                      //Kiểm tra số điện thoại
                      if (!isValidPhone(phoneTextController.text.trim())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Số điện thoại không hợp lệ.")),
                        );
                        return;
                      }
                      
                      // Kiểm tra số điện thoại đã được đăng ký chưa
                      if (await userController.checkExistPhone(fullPhoneNumber)) 
                      {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Số điện thoại đã tồn tại!")),
                        );
                        return;
                      }
                      
                      if (!context.mounted) return;
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 600),
                            pageBuilder: (context, animation, secondaryAnimation) => SignupPhoneVerifyScreen(
                              phoneNumber: fullPhoneNumber,
                              name: nameTextController.text,  
                              mail: mailTextController.text, 
                              gender: selectedGender, 
                            ) ,
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0); // Đi từ bên phải vào
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
  }

}