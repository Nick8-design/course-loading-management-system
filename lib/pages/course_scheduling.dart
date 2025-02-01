import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore Providers
final coursesProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('courses').snapshots();
});

final instructorsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('instructors').snapshots();
});

class CourseSchedulingScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesStream = ref.watch(coursesProvider);
    final instructorsStream = ref.watch(instructorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Course Scheduling')),
      body: coursesStream.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (coursesSnapshot) {
          if (coursesSnapshot.docs.isEmpty) {
            return Center(child: Text('No courses available.'));
          }
          return ListView(
            children: coursesSnapshot.docs.map((doc) {
              var course = doc.data();
              return ListTile(
                title: Text(course['title']),
                subtitle: Text(
                  'Instructor: ${course['assignedInstructor'] ?? "Unassigned"}\nSchedule: ${course['schedule'] ?? "Not Set"}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showScheduleDialog(context, doc, ref),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, QueryDocumentSnapshot courseDoc, WidgetRef ref) {
    final _scheduleController = TextEditingController(text: courseDoc.get('schedule') ?? '');
    String? selectedInstructor;

    showDialog(
      context: context,
      builder: (context) {
        final instructorsStream = ref.watch(instructorsProvider);
        return AlertDialog(
          title: Text('Schedule Course: ${courseDoc.get('title')}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _scheduleController, decoration: InputDecoration(labelText: 'Schedule')),
              instructorsStream.when(
                loading: () => CircularProgressIndicator(),
                error: (err, stack) => Text('Error loading instructors'),
                data: (instructorsSnapshot) {
                  return DropdownButton<String>(
                    hint: Text('Select Instructor'),
                    value: selectedInstructor,
                    isExpanded: true,
                    items: instructorsSnapshot.docs.map((instructorDoc) {
                      return DropdownMenuItem(
                        value: instructorDoc.id,
                        child: Text(instructorDoc.get('name')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedInstructor = value;
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _updateCourseSchedule(courseDoc.id, _scheduleController.text, selectedInstructor);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateCourseSchedule(String courseId, String schedule, String? instructorId) {
    FirebaseFirestore.instance.collection('courses').doc(courseId).update({
      'schedule': schedule,
      'assignedInstructor': instructorId,
    });
  }
}
