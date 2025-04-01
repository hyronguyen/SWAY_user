import 'package:flutter/material.dart';
import 'package:sway/page/onboarding/welcome.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingStart extends StatefulWidget {
  const OnboardingStart({super.key});

  @override
  _OnboardingStartState createState() => _OnboardingStartState();
}

class _OnboardingStartState extends State<OnboardingStart> {
  final PageController _pageController = PageController();
  final List<Map<String, String>> pages = [
    {
      "image": "ob_1.png",
      "title": "ĐI ĐẾN BẤT CỨ ĐÂU",
      "description": "SWAY cung cấp dịch vụ xe công nghệ khắp mọi miền tổ quốc",
    },
    {
      "image": "ob_2.png",
      "title": "ĐI BẤT CỨ LÚC NÀO",
      "description":
          "Với các chuyến xe liên tục 24/7, đáp ứng mọi nhu cầu đi lại của mọi người",
    },
    {
      "image": "ob_3.png",
      "title": "BẮT TÀI NÀO!",
      "description":
          "Chúc bạn có trải nghiệm thật hài lòng với dịch vụ của chúng tôi",
    },
  ];

  int currentIndex = 0;

  void _nextPage() {
    if (currentIndex < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 32, 8, 32),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/${pages[index]["image"]}'),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          pages[index]["title"]!,
                          key: ValueKey(index),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          pages[index]["description"]!,
                          key: ValueKey("desc_$index"),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Hiển thị chỉ báo trang
            SmoothPageIndicator(
              controller: _pageController,
              count: pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Color(0xFFedae10),
                dotColor: Colors.grey,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 20),

            // Nút Next
            GestureDetector(
              onTap: _nextPage,
              child: Image.asset('assets/images/next.png'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
