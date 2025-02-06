import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../components/color_button.dart';
import '../components/nav_drawer.dart';
import '../components/profile.dart';
import '../components/theme_button.dart';
import '../components/wavyappbarclipper.dart';
import '../constants.dart';
import '../data/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ProfileEditDialog();
      },
    );
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDao = ref.watch(userDaoProvider);
    final userrol=ref.watch(userRoleProvider);

    return Scaffold(
      drawer: NavDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: ClipPath(
          clipper: WavyAppBarClipper(),
          child: AppBar(
            title: Text('Course Loading Management System'),
            elevation: 8.0,
            backgroundColor: Colors.blueAccent,
            actions: [
              ThemeButton(changeThemeMode: changeTheme),
              ColorButton(changeColor: changeColor, colorSelected: colorSelected),
              IconButton(
                onPressed: () async {
                  userDao.logout();
                  await Future.delayed(Duration(milliseconds: 1));
                  context.go('/login');
                },
                icon: Icon(Icons.logout_sharp),
              ),

              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Logged in as ${userrol.value}"),
                      duration: const Duration(microseconds: 500),
                    ),
                  );
                  _showProfileDialog(context);
                },
                icon: Icon(Icons.account_circle_outlined, size: 50, color: Colors.white),
              ),

            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('instructors').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            List<QueryDocumentSnapshot> instructors = snapshot.data!.docs;
            return ListView(
              children: [
                _buildAnimatedBarChart(instructors).animate().fadeIn(duration: 500.ms),
                SizedBox(height: 20),
                _buildAnimatedLineChart(instructors).animate().slideX(duration: 600.ms),
                SizedBox(height: 20),
                _buildPieCharts().animate().scale(duration: 600.ms),
                SizedBox(height: 20),
                _buildConflictStatisticsChart().animate().slideY(duration: 600.ms),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingConflictButton(),
    );
  }

  /// 📌 **Instructor Workload Bar Chart (Scrollable)**
  Widget _buildAnimatedBarChart(List<QueryDocumentSnapshot> instructors) {
    return Column(
      children: [
        Text("Instructor Workload (Hours)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 400,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: instructors.length * 60,
              child: BarChart(
                BarChartData(
                  barGroups: instructors.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return BarChartGroupData(
                      x: instructors.indexOf(doc),
                      barRods: [
                        BarChartRodData(
                          fromY: 0,
                          toY: (data['workload'] ?? 0).toDouble(),
                          width: 25,
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    );
                  }).toList(),
                  groupsSpace: 20,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < instructors.length) {
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(instructors[value.toInt()].get('name') ?? "Unknown",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📌 **Scrollable Line Chart (Courses Per Instructor)**
  Widget _buildAnimatedLineChart(List<QueryDocumentSnapshot> instructors) {
    return Column(
      children: [
        Text("Number of Courses Per Instructor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          height: 300,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // ✅ Enable horizontal scrolling
            child: SizedBox(
              width: instructors.length * 70, // ✅ Dynamically adjust width based on instructor count
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: instructors.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                        int courseCount = (data['assignedCourses'] != null) ? (data['assignedCourses'] as List).length : 0;

                        return FlSpot(instructors.indexOf(doc).toDouble(), courseCount.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < instructors.length) {
                            return Transform.rotate(
                              angle: -0.5,
                              child: Text(
                                instructors[value.toInt()].get('name') ?? "Unknown",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}'); // ✅ Y-Axis now correctly shows (0,1,2,...)
                        },
                      ),
                    ),
                  ),
                  minY: 0, // ✅ Y-axis starts from 0
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }



  /// 📌 **Animated Pie Charts with Legends**
  Widget _buildPieCharts() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData)         return Center(child: CircularProgressIndicator());


        int totalCourses = snapshot.data!.docs.length;
    int conflicts = snapshot.data!.docs.where((doc) => doc['conflict'] == true).length;
    int noConflicts = totalCourses - conflicts;

    return Column(
    children: [
    Text("System Performance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 10),
    Container(
    height: 200,
    child: PieChart(
    PieChartData(
    sections: [
    PieChartSectionData(value: conflicts.toDouble(), color: Colors.red, title: "Conflicted"),
    PieChartSectionData(value: noConflicts.toDouble(), color: Colors.green, title: "No Conflict"),
    ],
    ),
    ),
    ),
    SizedBox(height: 10),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.square, color: Colors.red),
    Text(" Conflicted"),
    SizedBox(width: 10),
    Icon(Icons.square, color: Colors.green),
    Text(" No Conflict"),
    ],
    ),
    ],
    );
  });
}

/// 📌 **Conflict Statistics Bar Chart**
Widget _buildConflictStatisticsChart() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance.collection('courses').snapshots(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      int conflicts = snapshot.data!.docs.where((doc) => doc['conflict'] == true).length;
      int noConflicts = snapshot.data!.docs.length - conflicts;

      return Column(
        children: [
          Text("Conflict Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: conflicts.toDouble(), color: Colors.red, width: 30),
                    ],
                    barsSpace: 15,
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: noConflicts.toDouble(), color: Colors.green, width: 30),
                    ],
                    barsSpace: 15,
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text("Conflicted", style: TextStyle(color: Colors.red));
                          case 1:
                            return Text("No Conflict", style: TextStyle(color: Colors.green));
                          default:
                            return Container();
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// 📌 **Floating Conflict Alert Button with Badge**
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
            child: Icon(Icons.notifications),
          ),
          if (conflictCount > 0)
            Positioned(
              right: 10,
              top: 10,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 10,
                child: Text('$conflictCount', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
        ],
      );
    },
  );
}
}

