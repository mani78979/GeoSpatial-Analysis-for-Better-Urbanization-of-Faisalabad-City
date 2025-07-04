import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.back(); // Navigate back
          },
        ),
        title: Text(
          'About Us',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image and Logo
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Geospatial Analysis for Better Urbanization',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Our Mission'),
                  _buildContentText(
                    'Our mission is to empower citizens, urban planners, and businesses with actionable insights through advanced geospatial data. By analyzing satellite imagery and local data, our app provides detailed information on land use, population density, infrastructure, and environmental trends across the city.'
                  ),
                  
                  SizedBox(height: 20),
                  _buildSectionTitle('What We Do'),
                  _buildContentText(
                    'Whether you\'re planning a new residential project, tracking agricultural patterns, or exploring urban growth, our platform helps you make data-driven decisions for sustainable development. We aim to foster smarter urban planning and informed policymaking for a thriving Faisalabad.'
                  ),
                  
                  SizedBox(height: 20),
                  _buildSectionTitle('Our Vision'),
                  _buildContentText(
                    'We envision a future where urban development is guided by precise data analysis, ensuring sustainable growth that balances economic development with environmental preservation. City Lens strives to be at the forefront of this transformation, providing cutting-edge tools for urban planning and analysis.'
                  ),
                  
                  SizedBox(height: 20),
                  _buildSectionTitle('The Team'),
                  SizedBox(height: 15),
                  
                  // Team Members
                  Row(
                    children: [
                      Expanded(child: _buildTeamMember('Muhammad Usman', 'Team Leader', Icons.person)),
                      SizedBox(width: 20),
                      Expanded(child: _buildTeamMember('Hamza Maqsood', 'Team Memeber', Icons.person)),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTeamMember('Muhammad Zubair Afzal', 'Project Supervisor', Icons.person)),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  _buildSectionTitle('Technology Stack'),
                  SizedBox(height: 15),
                  
                  // Technology Stack
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildTechChip('Flutter'),
                      _buildTechChip('Firebase'),
                      _buildTechChip('Google Maps API'),
                      _buildTechChip('Machine Learning'),
                      _buildTechChip('TensorFlow'),
                      _buildTechChip('Geospatial Analysis'),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  _buildSectionTitle('Contact Us'),
                  SizedBox(height: 15),
                  
                  // Contact Information
                  _buildContactItem(Icons.email, 'Email', 'citylens@gmail.com'),
                  _buildContactItem(Icons.phone, 'Phone', '+92 3189053287'),
                  _buildContactItem(Icons.location_on, 'Address', 'NUML, Faisalabad'),
                  
                  SizedBox(height: 30),
                  // Social Media Links
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
                  
                  SizedBox(height: 30),
                  // Copyright
                  Center(
                    child: Text(
                      '© 2025 City Lens. All rights reserved.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.lightBlue,
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildTeamMember(String name, String role, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.lightBlue.withOpacity(0.2),
            child: Icon(
              icon,
              size: 30,
              color: Colors.lightBlue,
            ),
          ),
          SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      backgroundColor: Colors.lightBlue,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.lightBlue,
            size: 24,
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 3),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
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
        width: 50,
        height: 50,
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
            size: 24,
          ),
        ),
      ),
    );
  }
}
