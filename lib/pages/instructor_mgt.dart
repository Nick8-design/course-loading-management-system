
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/color_button.dart';
import '../components/theme_button.dart';
import '../constants.dart';

// Firestore Provider for Instructors List
final instructorsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('instructors').snapshots();
});

class InstructorMgt extends ConsumerWidget {

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const InstructorMgt({
  super.key,
  required this.changeTheme,
  required this.changeColor,
  required this.colorSelected,

  });

  //InstructorMgt({required this.changeTheme, required this.changeColor, required this.colorSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsStream = ref.watch(instructorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Instructor Management'),
    elevation: 8.0,
    backgroundColor: Theme.of(context).colorScheme.background,
    actions: [
    ThemeButton(
    changeThemeMode: changeTheme,
    ),
    ColorButton(
    changeColor: changeColor,
    colorSelected:colorSelected,
    ),
    ],
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInstructorDialog(context),
        child: Icon(Icons.add),
      ),
      body: instructorsStream.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (instructorsSnapshot) {
          if (instructorsSnapshot.docs.isEmpty) {
            return Center(child: Text('No instructors found.'));
          }
          return ListView(
            children: instructorsSnapshot.docs.map((doc) {
              var instructor = doc.data();
              return ListTile(
                title: Text(instructor['name']),
                subtitle: Text('Email: ${instructor['email']} - Workload: ${instructor['workload']} hrs'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showInstructorDialog(context, doc),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteInstructor(doc.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showInstructorDialog(BuildContext context, [QueryDocumentSnapshot? doc]) {
    final _nameController = TextEditingController(text: doc?.get('name') ?? '');
    final _emailController = TextEditingController(text: doc?.get('email') ?? '');
    final _workloadController = TextEditingController(text: doc?.get('workload')?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add Instructor' : 'Edit Instructor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _workloadController, decoration: InputDecoration(labelText: 'Workload (hrs)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {

              if (doc == null) {
                _addInstructor(_nameController.text, _emailController.text, _workloadController.text);
              } else {
                _updateInstructor(doc.id, _nameController.text, _emailController.text, _workloadController.text);
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addInstructor(String name, String email, String workload) {
    FirebaseFirestore.instance.collection('instructors').add({
      'name': name,
      'email': email,
      'workload': int.tryParse(workload) ?? 0,
    });
  }

  void _updateInstructor(String id, String name, String email, String workload) {
    FirebaseFirestore.instance.collection('instructors').doc(id).update({
      'name': name,
      'email': email,
      'workload': int.tryParse(workload) ?? 0,
    });
  }

  void _deleteInstructor(String id) {
    FirebaseFirestore.instance.collection('instructors').doc(id).delete();
  }
}
