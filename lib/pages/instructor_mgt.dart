import 'dart:math';

import 'package:course_loading_system/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../components/color_button.dart';
import '../components/nav_drawer.dart';
import '../components/theme_button.dart';
import '../components/wavyappbarclipper.dart';
import '../constants.dart';

final instructorsProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('instructors').snapshots();
});

class InstructorMgt extends ConsumerStatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const InstructorMgt({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  @override
  _InstructorMgtState createState() => _InstructorMgtState();
}

class _InstructorMgtState extends ConsumerState<InstructorMgt> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void generateInstructors() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference instructorsCollection = firestore.collection('instructors');

    List<String> instructorNames = List.generate(28, (index) => 'Instructor ${index + 1}');

    for (var name in instructorNames) {
      await instructorsCollection.add({
        'name': name,
        'instructorID': 'INS${1000 + instructorNames.indexOf(name)}', // Unique ID
        'email': '${name.toLowerCase().replaceAll(" ", "")}@university.com',
        'assignedCourses': [], // Initially empty, courses will be assigned later
        'workload': 0, // Hours of courses assigned (updated when scheduling)
      });
    }

    print("✅ 28 Instructors added successfully.");
  }

  void assignCoursesToInstructors() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get all instructors
    QuerySnapshot instructorSnapshot = await firestore.collection('instructors').get();
    List<QueryDocumentSnapshot> instructors = instructorSnapshot.docs;

    // Get all courses that are unassigned
    QuerySnapshot courseSnapshot = await firestore.collection('courses')
        .where('assignedInstructor', isEqualTo: null) // Get only unassigned courses
        .get();
    List<QueryDocumentSnapshot> courses = courseSnapshot.docs;

    if (instructors.isEmpty || courses.isEmpty) {
      print("❌ No instructors or courses available for assignment.");
      return;
    }

    Random random = Random();

    for (var course in courses) {
      // Select a random instructor
      var instructor = instructors[random.nextInt(instructors.length)];
      var instructorData = instructor.data() as Map<String, dynamic>;

      // Update course with instructor
      await firestore.collection('courses').doc(course.id).update({
        'assignedInstructor': instructorData['name'],
      });

      // Update instructor's assigned courses list
      List<dynamic> assignedCourses = instructorData['assignedCourses'] ?? [];
      assignedCourses.add(course['title']);

      // Update workload (each course = 3 hours)
      int newWorkload = (instructorData['workload'] ?? 0) + 3;

      await firestore.collection('instructors').doc(instructor.id).update({
        'assignedCourses': assignedCourses,
        'workload': newWorkload,
      });
    }

    print("✅ Courses successfully assigned to instructors.");
  }


  @override
  Widget build(BuildContext context) {
    final instructorsStream = ref.watch(instructorsProvider);

    return Scaffold(
      drawer: NavDrawer(),

      appBar:  PreferredSize(
    preferredSize: Size.fromHeight(120),
    child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: "Instructor management"

      ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            //assignCoursesToInstructors(),
            //generateInstructors(),
          _showInstructorDialog(),
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 10),
            Expanded(child: _buildInstructorTable(instructorsStream)),
          ],
        ),
      ),
    );
  }

  /// 📌 **Search Bar**
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: "Search Instructor",
        hintText: "Search by ID, Name, Course, Email, Workload",
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() => _searchQuery = value.toLowerCase());
      },
    );
  }

  /// 📌 **Instructor Table**
  Widget _buildInstructorTable(AsyncValue<QuerySnapshot> instructorsStream) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:

      instructorsStream.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (instructorsSnapshot) {
        List<QueryDocumentSnapshot> instructors = instructorsSnapshot.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return data['instructorID'].toString().toLowerCase().contains(_searchQuery) ||
              data['name'].toString().toLowerCase().contains(_searchQuery) ||
              data['email'].toString().toLowerCase().contains(_searchQuery) ||
              data['workload'].toString().toLowerCase().contains(_searchQuery) ||
              (data['assignedCourses'] as List<dynamic>?)
                  !.any((course) => course.toString().toLowerCase().contains(_searchQuery)) ?? false;
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 15,
            columns: [
              DataColumn(label: Text("#")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("ID")),
              DataColumn(label: Text("Email")),
              DataColumn(label: Text("Courses")),
              DataColumn(label: Text("Workload")),
              DataColumn(label: Text("Actions")),
            ],
            rows: instructors.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var instructor = entry.value.data() as Map<String, dynamic>;

              return DataRow(cells: [
                DataCell(Text("$index")),
                DataCell(Text(instructor['name'] ?? "N/A")),
                DataCell(Text(instructor['instructorID'] ?? "N/A")),
                DataCell(Text(instructor['email'] ?? "N/A")),
                DataCell(Text((instructor['assignedCourses'] as List<dynamic>?)?.join(", ") ?? "N/A")),
                DataCell(Text("${instructor['workload'] ?? 0} hrs")),
                DataCell(Row(
                  children: [
                    IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showInstructorDialog(doc: entry.value)),
                    IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteInstructor(entry.value.id)),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      },
      )
    );
  }

  /// 📌 **Add or Edit Instructor Dialog**
  void _showInstructorDialog({QueryDocumentSnapshot? doc}) {
    final TextEditingController _idController = TextEditingController(text: doc?.get('instructorID') ?? '');
    final TextEditingController _nameController = TextEditingController(text: doc?.get('name') ?? '');
    final TextEditingController _emailController = TextEditingController(text: doc?.get('email') ?? '');
    final TextEditingController _workloadController = TextEditingController(text: doc?.get('workload')?.toString() ?? '');
    final TextEditingController _coursesController = TextEditingController(
      text: (doc?.get('assignedCourses') as List<dynamic>?)?.join(", ") ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc == null ? 'Add Instructor' : 'Edit Instructor'),
        content: SingleChildScrollView(
          child:
          Form(
            key:_formKey ,
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInputField(_idController, 'ID',false),
              _buildInputField(_nameController, 'Name',false),
              _buildInputField(_emailController, 'Email',false),
              _buildInputField(_coursesController, 'Courses (Comma Separated)',false),
              _buildInputField(_workloadController, 'Workload (hours)',true),
            ],
          ),

          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
             if( _formKey.currentState!.validate()) {
               if (doc == null) {
                 _addInstructor(_idController.text, _nameController.text,
                     _emailController.text, _coursesController.text,
                     _workloadController.text);
               } else {
                 _updateInstructor(
                     doc.id, _idController.text, _nameController.text,
                     _emailController.text, _coursesController.text,
                     _workloadController.text);
               }
               Navigator.pop(context);
             }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  /// 📌 **Helper Method for Input Fields**
  Widget _buildInputField(TextEditingController controller, String label, bool isNumeric ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,

        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,

        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value){
          if(value==null|| value.isEmpty){
            return 'Field cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  /// 📌 **Firestore CRUD Methods**
  void _addInstructor(String id, String name, String email, String courses, String workload) {
    FirebaseFirestore.instance.collection('instructors').add({
      'instructorID': id,
      'name': name,
      'email': email,
      'assignedCourses': courses.split(',').map((e) => e.trim()).toList(),
      'workload': int.tryParse(workload) ?? 0,
    });
  }

  void _updateInstructor(String docId, String id, String name, String email, String courses, String workload) {
    FirebaseFirestore.instance.collection('instructors').doc(docId).update({
      'instructorID': id,
      'name': name,
      'email': email,
      'assignedCourses': courses.split(',').map((e) => e.trim()).toList(),
      'workload': int.tryParse(workload) ?? 0,
    });
  }

  void _deleteInstructor(String id) {
    FirebaseFirestore.instance.collection('instructors').doc(id).delete();
  }
}
