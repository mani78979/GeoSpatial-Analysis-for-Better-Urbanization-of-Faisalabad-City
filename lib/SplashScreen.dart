import 'package:city_lens/SIgnupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'BottomNavBar.dart';


class SplahScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplahScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 1));

    Get.to(SignUpScreen());


    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Get.off(() => Bottombar());
    } else {
      Get.off(() => SignUpScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Image.asset('assets/splashlogo.png',
            height: 280,
            width:280,
          )
      ),
    );
  }
}
