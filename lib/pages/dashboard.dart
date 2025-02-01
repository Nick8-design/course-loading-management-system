import 'package:course_loading_system/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../components/color_button.dart';
import '../components/nav_drawer.dart';
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



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
  //  final userDao = ref.watch(userDaoProvider);


    return Scaffold(
      drawer: NavDrawer(),
      appBar:PreferredSize(
    preferredSize: Size.fromHeight(120), // Adjust the height
    child: ClipPath(
    clipper: WavyAppBarClipper(),
    child:

    AppBar(
      title: Text('Course Loading Management System'),
      elevation: 8.0,
      backgroundColor: Colors.blueAccent, //Theme.of(context).colorScheme.background,
      actions: [
        ThemeButton(
          changeThemeMode: changeTheme,
        ),
        ColorButton(
          changeColor: changeColor,
          colorSelected: colorSelected,
        ),
        IconButton(
            onPressed: () async {
              final userDao = ref.read(userDaoProvider); // Use read instead of watch to avoid unnecessary rebuilds
              await userDao.logout(); // Call the logout function
              //  if (mounted) {
              context.go('/login'); // Navigate immediately after logout
              //   }
            },
            icon: Icon(Icons.logout_sharp)
        ),

        //
        // Container(
        //   //  padding: EdgeInsets.all(8),
        //     child:
        // CircleAvatar(
        //   radius: 40,
        //   backgroundColor: Colors.blueAccent,
        //   child:
          IconButton(
            onPressed: () {
              // Your action here
            },
            icon: Icon(
              Icons.account_circle_outlined,
              size: 50, // Adjust size to fit within the circle
              color: Colors.white,
            ),
          ),


      //  )



      ],



    ),


    ),
          ),





      body: dashboardData.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Padding(

            padding: EdgeInsets.all(16),
        child:  Center(child: Text('Error: $err')),
        ),



        data: (data) => Padding(
          padding: const EdgeInsets.all(16.0),
          child:

          //Column(
          ListView(
            children: [

//barchart






              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildNavCard(context, 'Instructor Management', '/instructor', Icons.people, Colors.blue),
                  _buildNavCard(context, 'Course Scheduling', '/scheduling', Icons.schedule, Colors.green),
                  _buildNavCard(context, 'Conflict Detection', '/conflicts', Icons.warning, Colors.red),
                  _buildNavCard(context, 'Reports', '/reports', Icons.analytics, Colors.orange),
                ],
              ),


              SizedBox(height: 20),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, String route) {
    return ElevatedButton(
      onPressed: () => context.go(route), // Using GoRouter navigation
      child: Text(title),
    );
  }

  Widget _buildNavCard(BuildContext context, String title, String route, IconData icon, Color color) {
    return InkWell(
      onTap: () => context.go(route), // Use GoRouter for navigation
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }



}

