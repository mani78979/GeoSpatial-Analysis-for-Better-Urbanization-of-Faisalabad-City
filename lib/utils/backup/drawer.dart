import 'package:city_lens/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:city_lens/SignInScreen.dart';
import 'aboutus.dart';

class CustomDrawer extends StatelessWidget {

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.off(() => SignInScreen());
    ToastUtil.showToast('Loged Out');
  }
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey.shade400,
        child: Column(
          children: [
            SizedBox(height: 50),
            // Drawer Header with "Menu" text
            Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 20),

            // About Us button
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Center(
                  child: Text(
                    'About Us',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              onTap: () {
                Get.to(AboutUsScreen());
              },
            ),
            SizedBox(height: 5),

            // About Us button
            if (currentUser != null)

              ListTile(
              title: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
              onTap: () {
                _signOut();
              },
            ),
            Spacer(),

            // Social Media Icons Row
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Facebook Icon
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    onPressed: () {
                      // Handle Facebook link or functionality
                    },
                  ),
                  SizedBox(width: 10),
                  // Cancel Icon
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.times, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  SizedBox(width: 10),
                  // Pinterest Icon
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.pinterest, color: Colors.red),
                    onPressed: () {
                      // Handle Pinterest link or functionality
                    },
                  ),
                  SizedBox(width: 10),
                  // Dribbble Icon
                  IconButton(
                    icon: FaIcon(FontAwesomeIcons.dribbble, color: Colors.purple),
                    onPressed: () {
                      // Handle Dribbble link or functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
