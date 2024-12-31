import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController phoneTextController = TextEditingController(); // Số điện thoại
  TextEditingController nameTextController = TextEditingController(); // Họ và tên
  TextEditingController mailTextController = TextEditingController(); // Mail
  String? selectedGender; //Giới tính 
  bool isTermsAccepted = false; //Điều khoản sử dụng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(title: Text('Đăng ký'),automaticallyImplyLeading: false),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                          borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Số điện thoại
                    TextField(
                      controller: phoneTextController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
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
                          borderSide: BorderSide(color: Color(0xFFedae10), width: 1),
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
                                value: "Nam",
                                child: Text("Nam"),
                              ),
                              DropdownMenuItem(
                                value: "Nữ",
                                child: Text("Nữ"),
                              ),
                              DropdownMenuItem(
                                value: "Khác",
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
                                    BorderSide(color: Color(0xFFedae10), width: 1),
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

                    // Nút Đăng ký
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic khi nhấn nút Đăng ký
                          debugPrint("Đăng ký với:");
                          debugPrint("Họ và Tên: ${nameTextController.text}");
                          debugPrint("Số điện thoại: ${phoneTextController.text}");
                          debugPrint("Email: ${mailTextController.text}");
                          debugPrint("Giới tính: $selectedGender");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                          backgroundColor: const Color(0xFFedae10),
                          foregroundColor: Colors.white, // Màu chữ
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text("Đăng ký"),
                      ),
                    ),
                    
                  const SizedBox(height: 20),
                  
                  const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Facebook");
                        },
                        icon: const Icon(Icons.facebook, color: Colors.blue, size: 40),
                      ),
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Apple");
                        },
                        icon: const Icon(Icons.apple, color: Colors.white, size: 40),
                      ),
                      IconButton(
                        onPressed: () {
                          debugPrint("Đăng nhập với Google");
                        },
                        icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Đã có tài khoản? ",
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: "Đăng nhập",
                            style: const TextStyle(
                              color: Color(0xFFedae10),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                            Navigator.pushNamed(context, '/'); 
                          },
                          
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
}
