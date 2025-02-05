

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/app_bar.dart';
import '../components/mybutton.dart';
import '../components/nav_drawer.dart';
import '../constants.dart';
import '../main.dart';
import 'course_scheduling.dart';

class ConflictDetectionScreen extends ConsumerWidget {

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ConflictDetectionScreen({
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
            title:"Conflict Resolution"

        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),


        child: CustomScrollView(
          slivers: [
           SliverToBoxAdapter( child:_buildConflictPieChart() ,) ,
           SliverToBoxAdapter(child:SizedBox(height: 20)),
         SliverToBoxAdapter(child:    _buildConflictList()),
            SliverToBoxAdapter(child:SizedBox(height: 20)),
       SliverToBoxAdapter(child:    _buildConflictActions(context)),
          ],


        ),



      ),
    );
  }

  /// 📌 **Conflict Pie Chart**
  Widget _buildConflictPieChart() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        int totalCourses = snapshot.data!.docs.length;
        int conflictedCourses =
            snapshot.data!.docs.where((doc) => doc['conflict'] == true).length;
        int nonConflictedCourses = totalCourses - conflictedCourses;

        return Column(
          children: [
            Text("Overall Performance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.5,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: conflictedCourses.toDouble(),
                      title: "Conflicted ($conflictedCourses)",
                      color: Colors.red,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: nonConflictedCourses.toDouble(),
                      title: "No Conflict ($nonConflictedCourses)",
                      color: Colors.green,
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 📌 **List of Conflicts**
  Widget _buildConflictList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('conflict', isEqualTo: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return Center(child: Text("No Conflicts Found"));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Types of Conflicts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView(
              shrinkWrap: true,
              children:
        //           SingleChildScrollView(
        //
        // child:
        snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text("${data['courseCode']} - ${data['assignedInstructor']}"),
                  subtitle: Text("Room: ${data['room']}, Time: ${data['time']}"),
                  trailing: ElevatedButton(
                    onPressed: () => _showFixConflictDialog(context, doc.id, data),
                    child: Text("Fix"),
                  ),
                );
              }).toList(),


           ),
          ]
        );
      },
    );
  }

  /// 📌 **Conflict Resolution Actions**
  Widget _buildConflictActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ScheduleOperationWidget(
          icon: Icons.auto_fix_high,
          name: 'Auto-Fix Conflicts',
          onTap: () {
            _autoFixConflicts();
          },
        ),
        // ElevatedButton.icon(
        //   icon: Icon(Icons.auto_fix_high),
        //   label: Text("Auto-Fix Conflicts"),
        //   onPressed: () => _autoFixConflicts(),
        // ),
        SizedBox(height: 30),
        // ElevatedButton.icon(
        //   icon: Icon(Icons.edit),
        //   label: Text("Fix Manually"),
        //   onPressed: () {},
        // ),
      ],
    );
  }

  /// 📌 **Fix Conflict Manually**
  void _showFixConflictDialog(BuildContext context, String courseId, Map<String, dynamic> data) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot instructorSnapshot = await firestore.collection('instructors').get();
    List<QueryDocumentSnapshot> instructors = instructorSnapshot.docs;

    String? selectedInstructor;
    String? selectedRoom;
    String? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Fix Conflict for ${data['courseCode']}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Change Instructor"),
                    items: instructors.map((instructor) {
                      return DropdownMenuItem<String>( // ✅ Explicitly set to String
                        value: instructor['name'] as String,  // ✅ Ensure it's a String
                        child: Text(instructor['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedInstructor = value;
                      });
                    },
                  ),

                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Change Room"),
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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Change Time Slot"),
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
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    await firestore.collection('courses').doc(courseId).update({
                      'assignedInstructor': selectedInstructor ?? data['assignedInstructor'],
                      'room': selectedRoom ?? data['room'],
                      'time': selectedTime ?? data['time'],
                      'conflict': false,

                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Conflict Fixed Successfully!")),
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

  /// 📌 **Auto-Fix Conflicts**
  void _autoFixConflicts() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot courseSnapshot = await firestore
        .collection('courses')
        .where('conflict', isEqualTo: true)
        .get();

    for (var doc in courseSnapshot.docs) {
      String newRoom = roomList[Random().nextInt(roomList.length)];
      String newTime = timeSlots[Random().nextInt(timeSlots.length)];

      await firestore.collection('courses').doc(doc.id).update({
        'room': newRoom,
        'time': newTime,
        'conflict': false,
      });
    }

    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(content: Text("All conflicts fixed automatically!")),
    );
  }


}
