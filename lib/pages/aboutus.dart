import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/app_bar.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';

class AboutUsPage extends StatelessWidget {

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const AboutUsPage({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    // required this.isAdmin
  });

  /// 📌 **Open LinkedIn Profile**
  void _openLinkedIn() async {
    final Uri url = Uri.parse("https://www.linkedin.com/in/nick-dieda-a0b623250/"); // Replace with actual LinkedIn URL
    // if (await canLaunchUrl(url)) {
      await launchUrl(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  /// 📌 **Open Email Client**
  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: "nickeagle888@gmail.com",
      queryParameters: {'subject': 'Inquiry'},
    );
  //  if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
   // } else {
 //     throw 'Could not launch email';
 //   }
  }

  /// 📌 **Call Phone Number**
  void _callPhoneNumber() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: "+254700742362");
    // if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    // } else {
    //   throw 'Could not launch $phoneUri';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      drawer: NavDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: App_Bar(
          changeTheme: changeTheme,
          changeColor: changeColor,
          colorSelected: colorSelected,
          title: 'About Us',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text("Developed by: Nick Dieda Dieda (DND)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Email:comb01-048722022@student.mmust.ac.ke", style: TextStyle(fontSize: 16)),
            Text("Phone: +254700742362", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              "This system is designed to efficiently manage course scheduling, instructor workload, and conflict detection in academic institutions.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.link),
              label: Text("Visit LinkedIn"),
              onPressed: _openLinkedIn,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text("Send Email"),
              onPressed: _sendEmail,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.phone),
              label: Text("Call Now"),
              onPressed: _callPhoneNumber,
            ),
          ],
        ),
      ),
    );
  }
}
