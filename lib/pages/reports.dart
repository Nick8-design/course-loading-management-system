import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

// Firestore Provider for Reports
final reportsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('courses').snapshots();
});

class ReportsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsStream = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Workload Reports')),
      body: reportsStream.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (reportsSnapshot) {
          if (reportsSnapshot.docs.isEmpty) {
            return Center(child: Text('No reports available.'));
          }

          return ListView(
            children: reportsSnapshot.docs.map((doc) {
              var report = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(report['title'] ?? "No Title"),
                subtitle: Text('Instructor: ${report['assignedInstructor'] ?? "Unassigned"}\nSchedule: ${report['schedule'] ?? "Not Set"}'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generatePDF(ref),
        child: Icon(Icons.picture_as_pdf),
      ),
    );
  }

  Future<void> _generatePDF(WidgetRef ref) async {
    final pdf = pw.Document();
    final reportsSnapshot = await FirebaseFirestore.instance.collection('courses').get();

    _sendReportNotification();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('Course Workload Report', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...reportsSnapshot.docs.map((doc) {
              var report = doc.data() as Map<String, dynamic>;
              return pw.Padding(
                padding: pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Text('Course: ${report['title'] ?? "No Title"} | Instructor: ${report['assignedInstructor'] ?? "Unassigned"} | Schedule: ${report['schedule'] ?? "Not Set"}'),
              );
            }).toList(),
          ],
        ),
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File('${output!.path}/workload_report.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(content: Text('PDF saved at ${file.path}')),
    );
  }

  void _sendReportNotification() {
    FirebaseMessaging.instance.subscribeToTopic('reports');

    FirebaseMessaging.instance.sendMessage(
      to: '/topics/reports',
      data: {"title": "New Report Available", "body": "A new workload report has been generated."},
    );
  }

}
