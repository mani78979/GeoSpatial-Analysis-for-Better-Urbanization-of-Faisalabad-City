import 'package:city_lens/HomeScreen.dart';
import 'package:city_lens/ProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../SignInScreen.dart';
import 'aboutus.dart';
import 'toast.dart';

class CustomDrawer extends StatelessWidget {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.off(() => SignInScreen());
    ToastUtil.showToast('Logged Out Successfully');
  }

  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ToastUtil.showToast('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade200, Colors.lightBlue.shade50],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 50, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.location_city,
                      size: 60,
                      color: Colors.lightBlue,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'City Lens',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        currentUser?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 10),
                children: [
                  // _buildDrawerItem(
                  //   icon: Icons.home,
                  //   title: 'Home',
                  //   onTap: () {
                  //    // Get.to(const Homescreen());
                  //     Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => Homescreen()));
                  //
                  //   },
                  // ),

                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About Us',
                    onTap: () {
                      Get.to(AboutUsScreen());
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'History',
                    onTap: () {
                    //  Get.to(ProfileScreen());
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileScreen()));

                    },
                  ),


                  if (currentUser != null)
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: _signOut,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
            Divider(height: 1),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: FontAwesomeIcons.facebook,
                        color: Colors.blue.shade800,
                        onTap: () => _launchURL('https://facebook.com'),
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.twitter,
                        color: Colors.lightBlue,
                        onTap: () => _launchURL('https://twitter.com'),
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.instagram,
                        color: Colors.purple,
                        onTap: () => _launchURL('https://instagram.com'),
                      ),
                      SizedBox(width: 20),
                      _buildSocialButton(
                        icon: FontAwesomeIcons.linkedin,
                        color: Colors.blue.shade900,
                        onTap: () => _launchURL('https://linkedin.com'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.grey.shade700,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      hoverColor: Colors.lightBlue.withOpacity(0.1),
      selectedTileColor: Colors.lightBlue.withOpacity(0.1),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }
}
