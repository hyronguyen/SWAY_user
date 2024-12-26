import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //Khai báo biến cục bộ
  TextEditingController phoneTextController =TextEditingController();
  TextEditingController nameTextController =TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Image.asset(
                  "assets/images/logo.png"),

                const Text(
                 "Tạo tài khoản",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ), 
                ),
                
              // field nhập
                Padding(
                  padding:const EdgeInsets.all(22) ,
                  child: Column(
                    children: [
                      // Ô Nhập số điện thoại 
                      TextField(
                        controller: phoneTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:"Số điện thoại" ,
                          labelStyle: TextStyle(color: Colors.white), // Màu chữ cho label
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền khi không được chọn
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền khi được chọn
                          ),
                          border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền mặc định
                          ),
                          ),
                        style: TextStyle(color: Colors.white), // Màu chữ khi nhập
                        ),

                      SizedBox(height: 20),

                      // Ô nhấp Mật khẩu
                       TextField(
                        controller: nameTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:"Họ và Tên" ,
                          labelStyle: TextStyle(color: Colors.white), // Màu chữ cho label
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền khi không được chọn
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền khi được chọn
                          ),
                          border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), // Viền mặc định
                          ),
                          ),
                        style: TextStyle(color: Colors.white), // Màu chữ khi nhập
                        ), 
                    ],
                  ),
                )
                 
            ],
          )
        )
      ),
    );
  }
}