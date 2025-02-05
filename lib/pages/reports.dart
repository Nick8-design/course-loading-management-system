import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

import '../components/app_bar.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';

class ReportScreen extends ConsumerWidget {

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ReportScreen({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar:  PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: App_Bar(
            changeTheme:changeTheme,
            changeColor:changeColor,
            colorSelected:colorSelected,
            title:'Instructor Reports'

        ),
      ),

     // appBar: AppBar(title: Text('Instructor Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
        //  crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInstructorTable(context)),
            SizedBox(height: 20),
            _buildPrintButton("Print Instructor Table", _printInstructorTable),
            SizedBox(height: 20),
            _buildScheduleAnalysis(),
            SizedBox(height: 20),
            _buildPrintButton("Print Schedule Summary", _printScheduleSummary),
          ],
        ),
      ),
    );
  }

  /// 📌 **Instructor Table**
  Widget _buildInstructorTable(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('instructors').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text("Instructor Name")),
              DataColumn(label: Text("Instructor ID")),
              DataColumn(label: Text("Total Workload")),
              DataColumn(label: Text("Courses Assigned")),
              DataColumn(label: Text("Actions")),
            ],
            rows: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> instructor = doc.data() as Map<String, dynamic>;
              return DataRow(cells: [
                DataCell(Text(instructor['name'] ?? "Unknown")),
                DataCell(Text(instructor['instructorID'] ?? doc.id)), // Instructor ID
                DataCell(Text("${instructor['workload'] ?? 0} hrs")),
                DataCell(Text("${(instructor['assignedCourses'] as List?)?.length ?? 0} courses")),
                DataCell(
                  ElevatedButton(
                    onPressed: () => _sendInstructorEmail(instructor),
                    child: Text("📩 Share"),
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  /// 📌 **Print Button**
  Widget _buildPrintButton(String title, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(Icons.print),
      label: Text(title),
      onPressed: onPressed,
    );
  }

  /// 📌 **Schedule Analysis Summary (Pie Chart + Detailed Information)**
  Widget _buildScheduleAnalysis() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        int totalCourses = snapshot.data!.docs.length;
        int scheduledCourses = snapshot.data!.docs.where((doc) => doc['room'] != null).length;
        int unscheduledCourses = totalCourses - scheduledCourses;
        int conflicts = snapshot.data!.docs.where((doc) => doc['conflict'] == true).length;
        int resolvedConflicts = totalCourses - conflicts;

        return Column(
          children: [
            Text("📊 Schedule Analysis Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: scheduledCourses.toDouble(), color: Colors.green, title: "Scheduled"),
                    PieChartSectionData(value: unscheduledCourses.toDouble(), color: Colors.red, title: "Unscheduled"),
                    PieChartSectionData(value: conflicts.toDouble(), color: Colors.orange, title: "Conflicted"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildSummaryDetails(scheduledCourses, unscheduledCourses, conflicts, resolvedConflicts),
          ],
        );
      },
    );
  }

  /// 📌 **Detailed Schedule Analysis Summary Below Pie Chart**
  Widget _buildSummaryDetails(int scheduled, int unscheduled, int conflicts, int resolvedConflicts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("✅ Scheduled Courses: $scheduled"),
        Text("❌ Unscheduled Courses: $unscheduled"),
        Text("⚠️ Conflicts Detected: $conflicts"),
        Text("✔️ Conflicts Resolved: $resolvedConflicts"),
      ],
    );
  }

  /// 📌 **Print Instructor Table as PDF (Fixed)**
  Future<void> _printInstructorTable() async {
    final pdf = pw.Document();
    List<List> instructorData = await _fetchInstructorDataForPrint(); // ✅ Await inside an async function

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text("Instructor Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              data: [
                ["Instructor Name", "Instructor ID", "Total Workload", "Courses Assigned"],
                ...instructorData, // ✅ No need for await here since data is already fetched
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }


  /// 📌 **Fetch Instructor Data for PDF Report**
  Future<List<List>> _fetchInstructorDataForPrint() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('instructors').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return [
        data['name'] ?? "Unknown",
        doc.id,
        "${data['workload'] ?? 0} hrs",
        "${(data['assignedCourses'] as List?)?.length ?? 0} courses",
      ];
    }).toList();
  }

  /// 📌 **Print Schedule Summary as PDF**
  void _printScheduleSummary() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
            children: [
            pw.Text("Schedule Summary Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text("This report shows scheduled vs unscheduled courses."),
        pw.Bullet(text: "Scheduled Courses: ${ _getScheduledCourses()}"),
        pw.Bullet(text: "Unscheduled Courses: ${ _getUnscheduledCourses()}"),
        pw.Bullet(text: "Conflicts Detected: ${ _getConflicts()}"),
        ],
      ),
    ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// 📌 **Send Email to Each Instructor**
  void _sendInstructorEmail(Map<String, dynamic> instructor) async {
    String emailBody = _generateInstructorEmailContent(instructor);

    final Email email = Email(
      body: emailBody,
      subject: "Your Course Assignments",
      recipients: [instructor['email'] ?? ""], // Ensure instructor has an email field
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      print("✅ Email Sent to ${instructor['name']}");
    } catch (e) {
      print("❌ Error Sending Email: $e");
    }
  }

  /// 📌 **Generate Email Content for Instructor**
  String _generateInstructorEmailContent(Map<String, dynamic> instructor) {
    List<dynamic> assignedCourses = instructor['assignedCourses'] ?? [];

    String courseDetails = assignedCourses.map((course) {
      return "- $course";
    }).join("\n");

    return '''
Dear ${instructor['name']},

Here is your assigned course schedule:

$courseDetails

Best regards,
Course Management Team
''';
  }

  /// 📌 **Dummy Functions for Summary Count (Replace with Firestore)**
  Future<int> _getScheduledCourses() async => 30;
  Future<int> _getUnscheduledCourses() async => 10;
  Future<int> _getConflicts() async => 5;
}
