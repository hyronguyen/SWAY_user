import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sway/config/colors.dart';
import 'package:sway/mainpage.dart';
import 'package:sway/page/authentication/login.dart';
import 'package:sway/page/booking/driver_rate.dart';
import 'package:sway/testscreen.dart';
import 'package:sway/page/onboarding/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Sway user',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: backgroundblack,
        ),
        home: OnboardingStart());
  }
}
