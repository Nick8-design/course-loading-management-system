import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../components/app_bar.dart';
import '../components/mybutton.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';
import '../data/providers.dart';

// Firestore Provider for Courses
final coursesProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance.collection('courses').snapshots();
});

// List of 15 Fixed Rooms
final List<String> roomList = [
  "Spd 004", "Room 102", "Room 103", "Room 104", "Room 105",
  "Room 106", "Room 107", "Room 108", "Room 109", "Room 110",
  "Room 111", "Room 112", "Room 113", "Room 114", "Room 115"
];

// List of Available Time Slots (Each Course Takes 3 Hours)
final List<String> timeSlots = ["7:00 AM", "10:00 AM", "1:00 PM", "4:00 PM"];

class CourseSchedulingScreen extends ConsumerWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
final bool isAdmin;

  const CourseSchedulingScreen({
    super.key,
    required this.isAdmin,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });







  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool admin=true;

    final coursesStream = ref.watch(coursesProvider);

    return Scaffold(
      drawer: NavDrawer(),

      appBar:  PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: App_Bar(
            changeTheme:changeTheme,
            changeColor:changeColor,
            colorSelected:colorSelected,
            title: 'Course Scheduling'

        ),
      ),




      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildActionButtons(context,admin),
            SizedBox(height: 20),
            Expanded(child: _buildScheduleTable(ref, coursesStream)),
            SizedBox(height: 16),
            _buildScheduleSummary(),
            SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingConflictButton(),
    );
  }

  /// 📌 **Top Action Buttons**
  Widget _buildActionButtons(BuildContext context,role) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
isAdmin?
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          ScheduleOperationWidget(
            icon: Icons.add,
            name: 'Manually',
            onTap: () {
              _showManualScheduleDialog(context);
            },
          ),
          sizew8(),
          ScheduleOperationWidget(
            name: 'Generate',
            icon: Icons.shuffle,
            onTap: () {
              smartScheduleCourses();
            },
          ),
          sizew8(),

          ScheduleOperationWidget(
            icon: Icons.delete_forever,
            name: 'Clear',
            onTap: () {
              _clearSchedule();
            },
          ),




      ],
    )
        :
    Text("General Schedule",style: TextStyle(fontSize: 22),)


    );

  }

  /// 📌 **Schedule Table with Conflict Highlighting**
  Widget _buildScheduleTable(WidgetRef ref, AsyncValue<QuerySnapshot> coursesStream) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
    child:


      coursesStream.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (coursesSnapshot) {
        List<QueryDocumentSnapshot> courses = coursesSnapshot.docs;

        return SingleChildScrollView(
          child: DataTable(
            columns: [
              DataColumn(label: Text("Room")),
              ...timeSlots.map((slot) => DataColumn(label: Text(slot))),
            ],
            rows: roomList.map((room) {
              return DataRow(cells: [
                DataCell(Text(room)),
                ...timeSlots.map((timeSlot) {
                  QueryDocumentSnapshot<Object?>? course = courses.firstWhereOrNull(
                        (course) {
                      var data = course.data() as Map<String, dynamic>? ?? {};
                      return data.isNotEmpty &&
                          data.containsKey('room') &&
                          data.containsKey('time') &&
                          data['room'] == room &&
                          data['time'] == timeSlot;
                    },
                  );

                  bool isConflicted = course != null && (course.data() as Map<String, dynamic>)['conflict'] == true;

                  return DataCell(
                    course == null
                        ? Text("Available")
                        : Text(
                      "${(course.data() as Map<String, dynamic>)['courseCode']} - "
                          "${(course.data() as Map<String, dynamic>)['assignedInstructor'] ?? 'Unassigned'}",
                      style: TextStyle(color: isConflicted ? Colors.red : Colors.black, fontWeight: isConflicted ? FontWeight.bold : FontWeight.normal),
                    ),
                  );
                }),
              ]);
            }).toList(),
          ),
        );
      },



    )

    );



  }

  /// 📌 **Smart Scheduling Function**
  void smartScheduleCourses() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch all instructors
    QuerySnapshot instructorSnapshot = await firestore.collection('instructors').get();
    List<QueryDocumentSnapshot> instructors = instructorSnapshot.docs;

    // Fetch all courses
    QuerySnapshot courseSnapshot = await firestore.collection('courses').get();
    List<QueryDocumentSnapshot> courses = courseSnapshot.docs;

    if (instructors.isEmpty || courses.isEmpty) {
      print("❌ No instructors or courses available for scheduling.");
      return;
    }

    Map<String, List<String>> instructorSchedule = {}; // Tracks assigned courses by time slot

    for (var course in courses) {
      var courseData = course.data() as Map<String, dynamic>? ?? {};

      // Assign an instructor if none is assigned
      if (courseData['assignedInstructor'] == null) {
        instructors.sort((a, b) {
          int aWorkload = (a.data() as Map<String, dynamic>?)?['workload'] ?? 0;
          int bWorkload = (b.data() as Map<String, dynamic>?)?['workload'] ?? 0;
          return aWorkload.compareTo(bWorkload);
        });

        var assignedInstructor = instructors.first;
        courseData['assignedInstructor'] = (assignedInstructor.data() as Map<String, dynamic>)['name'];

        await firestore.collection('instructors').doc(assignedInstructor.id).update({
          'workload': (assignedInstructor.data() as Map<String, dynamic>?)?['workload'] + 3,
          'assignedCourses': FieldValue.arrayUnion([courseData['title']]),
        });
      }

      // Assign a room and time slot
      String room = roomList[Random().nextInt(roomList.length)];
      String time = timeSlots[Random().nextInt(timeSlots.length)];

      // Detect Instructor Scheduling Conflicts
      String instructor = courseData['assignedInstructor'];
      if (instructorSchedule.containsKey(instructor) && instructorSchedule[instructor]!.contains(time)) {
        courseData['conflict'] = true;
      } else {
        courseData['conflict'] = false;
        instructorSchedule.putIfAbsent(instructor, () => []).add(time);
      }

      // Save the updated course details
      await firestore.collection('courses').doc(course.id).update({
        'assignedInstructor': courseData['assignedInstructor'],
        'room': room,
        'time': time,
        'conflict': courseData['conflict'],
      });
    }
  }

  /// 📌 **Schedule Summary**
  Widget _buildScheduleSummary() {
    return Column(
      children: [
        _buildSummaryCard("Available Courses", "courses"),
        _buildSummaryCard("Scheduled Courses", "courses", filter: (doc) => doc['room'] != null),
        _buildSummaryCard("Conflicted Courses", "courses", filter: (doc) => doc['conflict'] == true),
        _buildSummaryCard("Unscheduled Courses", "courses", filter: (doc) => doc['room'] == null),
      ],
    );
  }


  Widget _buildSummaryCard(String title, String collection, {bool Function(QueryDocumentSnapshot)? filter}) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        int count = filter == null ? snapshot.data!.docs.length : snapshot.data!.docs.where(filter).length;

        return Card(
          child: ListTile(
            title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text("$count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  /// 📌 **Floating Conflict Button with Badge**
  Widget _buildFloatingConflictButton() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').where('conflict', isEqualTo: true).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        int conflictCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          alignment: Alignment.topRight,
          children: [
            FloatingActionButton(
              onPressed: () => GoRouter.of(context).go('/conflicts'),
              child: Icon(Icons.warning, color: Colors.white),
              backgroundColor: Colors.red,
            ),
            if (conflictCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Text('$conflictCount', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 📌 **Generate Random Schedule**
  void _generateRandomSchedule() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final coursesSnapshot = await firestore.collection('courses').get();

    for (var course in coursesSnapshot.docs) {
      String room = roomList[Random().nextInt(roomList.length)];
      String time = timeSlots[Random().nextInt(timeSlots.length)];

      await firestore.collection('courses').doc(course.id).update({
        'room': room,
        'time': time,
        'conflict': false,
      });
    }
  }

  void _showManualScheduleDialog(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch available courses, instructors, and rooms
    QuerySnapshot coursesSnapshot = await firestore.collection('courses').where('room', isEqualTo: null).get();
    QuerySnapshot instructorsSnapshot = await firestore.collection('instructors').get();

    List<QueryDocumentSnapshot> courses = coursesSnapshot.docs;
    List<QueryDocumentSnapshot> instructors = instructorsSnapshot.docs;

    if (courses.isEmpty || instructors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No available courses or instructors!")),
      );
      return;
    }

    // Local variables for dropdown selections
    String? selectedCourseId;
    String? selectedInstructorId;
    String? selectedRoom;
    String? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Manually Assign Schedule"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Course Selection Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Course"),
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourseId = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  // Instructor Selection Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Instructor"),
                    items: instructors.map((instructor) {
                      return DropdownMenuItem(
                        value: instructor.id,
                        child: Text(instructor['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedInstructorId = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  // Room Selection Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Room"),
                    items: roomList.map((room) {
                      return DropdownMenuItem(
                        value: room,
                        child: Text(room),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRoom = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),

                  // Time Slot Selection Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Time Slot"),
                    items: timeSlots.map((time) {
                      return DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTime = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCourseId == null ||
                        selectedInstructorId == null ||
                        selectedRoom == null ||
                        selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select all fields!")),
                      );
                      return;
                    }

                    // Update course in Firestore
                    await firestore.collection('courses').doc(selectedCourseId).update({
                      'assignedInstructor': instructors
                          .firstWhere((inst) => inst.id == selectedInstructorId)['name'],
                      'room': selectedRoom,
                      'time': selectedTime,
                      'conflict': false, // Assume no conflict initially
                    });

                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Schedule Assigned Successfully!")),
                    );
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }




  void _clearSchedule() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('courses').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        firestore.collection('courses').doc(doc.id).update({'room': null, 'time': null, 'conflict': false});
      }
    });
  }


  void preventConflictsBeforeScheduling() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot instructorSnapshot = await firestore.collection('instructors').get();
    List<QueryDocumentSnapshot> instructors = instructorSnapshot.docs;

    QuerySnapshot courseSnapshot = await firestore.collection('courses').get();
    List<QueryDocumentSnapshot> courses = courseSnapshot.docs;

    if (instructors.isEmpty || courses.isEmpty) {
      print("❌ No instructors or courses available for scheduling.");
      return;
    }

    print("📢 Starting conflict prevention...");

    Map<String, List<String>> instructorSchedule = {};
    Map<String, String> roomSchedule = {};

    for (var course in courses) {
      var courseData = course.data() as Map<String, dynamic>? ?? {};

      if (courseData['assignedInstructor'] == null) {
        instructors.sort((a, b) {
          int aWorkload = (a.data() as Map<String, dynamic>?)?['workload'] ?? 0;
          int bWorkload = (b.data() as Map<String, dynamic>?)?['workload'] ?? 0;
          return aWorkload.compareTo(bWorkload);
        });

        var assignedInstructor = instructors.first;
        courseData['assignedInstructor'] = (assignedInstructor.data() as Map<String, dynamic>)['name'];

        // Ensure assignedCourses is always a List<String>
        List<dynamic> currentCourses = (assignedInstructor.data() as Map<String, dynamic>?)?['assignedCourses'] ?? [];
        if (currentCourses is! List) {
          currentCourses = []; // Ensure it's a list
        }

        await firestore.collection('instructors').doc(assignedInstructor.id).update({
          'workload': (assignedInstructor.data() as Map<String, dynamic>?)?['workload'] + 3,
          'assignedCourses': FieldValue.arrayUnion([courseData['title']]), // ✅ Fixed
        });

        print("✅ Assigned ${courseData['title']} to ${courseData['assignedInstructor']}");
      }

      String selectedRoom = "";
      String selectedTime = "";
      bool roomAssigned = false;

      for (String room in roomList) {
        for (String time in timeSlots) {
          String roomKey = "$room-$time";
          String instructorKey = "${courseData['assignedInstructor']}-$time";

          if (!roomSchedule.containsKey(roomKey) && !instructorSchedule.containsKey(instructorKey)) {
            selectedRoom = room;
            selectedTime = time;
            roomSchedule[roomKey] = courseData['title'];
            instructorSchedule[instructorKey] = courseData['title'];
            roomAssigned = true;
            break;
          }
        }
        if (roomAssigned) break;
      }

      if (roomAssigned) {
        await firestore.collection('courses').doc(course.id).update({
          'room': selectedRoom,
          'time': selectedTime,
          'conflict': false,
        });

        print("✅ Scheduled ${courseData['title']} in $selectedRoom at $selectedTime");
      } else {
        await firestore.collection('courses').doc(course.id).update({
          'conflict': true,
        });

        print("❌ Conflict detected for ${courseData['courseCode']} - No available room/time slot.");
      }
    }

    print("✅ Conflict Prevention Applied Successfully!");
  }






}
