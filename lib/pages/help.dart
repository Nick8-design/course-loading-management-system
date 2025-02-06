import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/app_bar.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';
import '../data/providers.dart';

class HelpPage extends ConsumerWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
final bool isAdmin;
  const HelpPage({
    super.key,
    required this.isAdmin,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
   // required this.isAdmin
  });





  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return Scaffold(

      drawer: NavDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: App_Bar(
          changeTheme: changeTheme,
          changeColor: changeColor,
          colorSelected: colorSelected,
          title: 'Help & Support',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle("📖 System Overview"),
            _buildText("The Course Loading Management System helps administrators and instructors manage course schedules efficiently, avoiding conflicts and ensuring proper workload distribution."),

            SizedBox(height: 20),
            _buildSectionTitle("👨‍🏫 Instructor Guide"),
            _buildInstructorGuide(),

            if (isAdmin) ...[
              SizedBox(height: 20),
              _buildSectionTitle("🛠️ Admin Guide"),
              _buildAdminGuide(),
            ],

            SizedBox(height: 20),
            _buildSectionTitle("🔑 Role-Based Access"),
            _buildText(isAdmin
                ? "✅ You are an **Admin**. You have full control over the system, including managing courses, instructors, and schedules."
                : "🔒 You are an **Instructor**. You can view schedules, track your workload, and access reports."),

            SizedBox(height: 20),
            _buildSectionTitle("📝 FAQs & Troubleshooting"),
            _buildFAQs(),

            SizedBox(height: 20),
            _buildSectionTitle("📩 Contact Support"),
            ElevatedButton.icon(
              icon: Icon(Icons.email),
              label: Text("Send Support Email"),
              onPressed: () => _sendSupportEmail(),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 **Reusable Section Title Widget**
  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent));
  }

  /// 📌 **Reusable Text Widget**
  Widget _buildText(String text) {
    return Text(text, style: TextStyle(fontSize: 14, color: Colors.black87));
  }

  /// 📌 **Instructor Guide**
  Widget _buildInstructorGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText("🔹 **View Your Schedule**: Navigate to the **Dashboard** to see your assigned courses and workload."),
        _buildText("🔹 **Access Reports**: Instructors can view their teaching schedule and workload under the **Reports** section."),
        _buildText("🔹 **Conflict Alerts**: If a scheduling conflict is detected, instructors will receive a notification."),
      ],
    );
  }

  /// 📌 **Admin Guide**
  Widget _buildAdminGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText("🔹 **Add & Manage Instructors**: Go to the **Instructor Management** page to add, edit, or remove instructors."),
        _buildText("🔹 **Assign Courses**: Navigate to **Course Scheduling** to assign instructors to courses and resolve conflicts."),
        _buildText("🔹 **Generate & Clear Schedules**: Use the scheduling tool to **automatically generate** conflict-free schedules."),
        _buildText("🔹 **Monitor System Performance**: Admins can view **detailed analytics**, including workload distribution and scheduling conflicts."),
      ],
    );
  }

  /// 📌 **FAQs & Troubleshooting**
  Widget _buildFAQs() {
    return ExpansionTile(
      title: Text("Click to Expand FAQs"),
      children: [
        ListTile(title: Text("Q: How do I reset my password?"), subtitle: Text("A: Click 'Forgot Password' on the login screen and follow the instructions.")),
        ListTile(title: Text("Q: What should I do if my schedule is incorrect?"), subtitle: Text("A: Contact your administrator or check the schedule for conflicts.")),
        ListTile(title: Text("Q: How can I request a schedule change?"), subtitle: Text("A: Instructors should contact the admin for scheduling modifications.")),
        ListTile(title: Text("Q: How can I print my schedule?"), subtitle: Text("A: Go to **Reports**, click **Print**, and select your preferred format (PDF/Excel).")),
      ],
    );
  }

  /// 📌 **Send Support Email**
  void _sendSupportEmail() async {
    // Simulating sending an email (Replace with actual email sender logic)
    print("✅ Support email sent to support@university.edu");
  }
}
