import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';









// Firestore Provider for Courses
final coursesProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('courses').snapshots();
});

class ConflictDetectionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesStream = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Conflict Detection')),
      body: coursesStream.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (coursesSnapshot) {
          if (coursesSnapshot.docs.isEmpty) {
            return Center(child: Text('No courses available.'));
          }

          // Check for conflicts (overlapping schedules)
          List<QueryDocumentSnapshot> conflicts = _detectConflicts(coursesSnapshot.docs);

          return conflicts.isEmpty
              ? Center(child: Text('No schedule conflicts detected.'))
              : ListView(
            children: conflicts.map((doc) {
              var course = doc.data() as Map<String, dynamic>; // FIX: Explicit Cast
              return ListTile(
                title: Text(course['title'] ?? "No Title"), // FIX: Handle null title
                subtitle: Text(
                  'Instructor: ${course['assignedInstructor'] ?? "Unassigned"}\nSchedule: ${course['schedule'] ?? "Not Set"}',
                ), // FIX: Handle null instructor & schedule
                trailing: IconButton(
                  icon: Icon(Icons.warning, color: Colors.red),
                  onPressed: () => _resolveConflict(context, doc),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> _detectConflicts(List<QueryDocumentSnapshot> courses) {
    Map<String, List<QueryDocumentSnapshot>> scheduleMap = {};

    for (var doc in courses) {

      var course = doc.data() as Map<String, dynamic>; // FIX: Explicit Cast

      _sendConflictNotification(course['title']);
      String? schedule = course['schedule'] as String?;
      if (schedule == null) continue;

      if (scheduleMap.containsKey(schedule)) {
        scheduleMap[schedule]!.add(doc);
      } else {
        scheduleMap[schedule] = [doc];
      }
    }

    return scheduleMap.values.where((list) => list.length > 1).expand((list) => list).toList();
  }

  void _resolveConflict(BuildContext context, QueryDocumentSnapshot doc) {
    final _scheduleController = TextEditingController(text: doc.get('schedule') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resolve Conflict: ${doc.get('title') ?? "No Title"}'), // FIX: Handle null title
        content: TextField(controller: _scheduleController, decoration: InputDecoration(labelText: 'New Schedule')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateSchedule(doc.id, _scheduleController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateSchedule(String courseId, String newSchedule) {
    FirebaseFirestore.instance.collection('courses').doc(courseId).update({
      'schedule': newSchedule,
    });
  }


  void _sendConflictNotification(String courseTitle) {
    FirebaseMessaging.instance.subscribeToTopic('conflicts'); // Subscribe to the topic

    FirebaseMessaging.instance.sendMessage(
      to: '/topics/conflicts',
      data: {"title": "Schedule Conflict", "body": "Conflict detected in $courseTitle"},
    );
  }

}
