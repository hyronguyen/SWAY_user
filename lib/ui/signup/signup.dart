import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                
                Padding(
                  padding:const EdgeInsets.all(22) ,
                  child: Column(
                    children: [
                      TextField(
                        controller: phoneTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:"Số điện thoại" ,
                          labelStyle: TextStyle(color: Colors.white), 
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), 
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          ),
                          border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), 
                          ),
                          ),
                        style: TextStyle(color: Colors.white), 
                        ),

                      SizedBox(height: 20),

                       TextField(
                        controller: nameTextController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:"Họ và Tên" ,
                          labelStyle: TextStyle(color: Colors.white), 
                          enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), 
                          ),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), 
                          ),
                          border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1), 
                          ),
                          ),
                        style: TextStyle(color: Colors.white), 
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