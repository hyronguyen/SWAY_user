import 'package:flutter/material.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/authentication/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.end, // Đảm bảo các nút nằm dưới cùng
        children: <Widget>[
          // Phần chứa hình ảnh và tiêu đề nằm giữa màn hình
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset('assets/images/welcome.png'),
                ),
                const SizedBox(
                    height: 20), // Khoảng cách giữa hình ảnh và tiêu đề

                // Tiêu đề SWAY XIN CHÀO
                const Text(
                  'SWAY XIN CHÀO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                    height: 8), // Khoảng cách giữa tiêu đề và subtitle

                // Subtitle Hân hạnh được phục vụ bạn
                const Text(
                  'Tận hưởng những chuyến đi tuyệt vời cùng chúng tôi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Phần chứa các nút sẽ nằm dưới cùng
          Padding(
            padding: const EdgeInsets.all(
                32.0), // Khoảng cách giữa các nút và cạnh dưới
            child: Column(
              children: <Widget>[
                // Nút Đăng nhập
                FractionallySizedBox(
                  widthFactor: 1.0, // Chiều rộng bằng với màn hình
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 12),
                      backgroundColor: const Color(0xFFedae10),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 600),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  LoginScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin =
                                Offset(1.0, 0.0); // Đi từ bên phải vào
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child:
                        const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20), // Khoảng cách giữa hai nút

                // Nút Đăng ký
                FractionallySizedBox(
                  widthFactor: 1.0, // Chiều rộng bằng với màn hình
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 12),
                      backgroundColor: Colors.transparent,
                      foregroundColor: const Color(0xFFedae10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFedae10),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 600),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SignupScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin =
                                Offset(1.0, 0.0); // Đi từ bên phải vào
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child:
                        const Text('Đăng ký', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20), // Khoảng cách giữa hai nút
              ],
            ),
          ),
        ],
      ),
    );
  }
}
