import 'package:course_loading_system/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class NavDrawer extends StatefulWidget{

  @override
  State<NavDrawer> createState()=>_StateNavDrawer();

}

class _StateNavDrawer extends  State<NavDrawer> {
  static const double drawerWidth = 250.0;


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle

      ),

      width: drawerWidth,
      child: Drawer(
        child:
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(

              children: [
                _kaitem("/dashboard",Icons.holiday_village_outlined,"Dashboard"),
                line(),
                _kaitem("/instructor",Icons.directions_run_rounded,"Instructor Management"),
                line(),
                _kaitem("/scheduling",Icons.line_style_outlined,"Scheduling"),
                line(),
                _kaitem("/conflicts",Icons.warning,"Conflict Detection"),
                line(),
                _kaitem("/reports",Icons.print_rounded,"Reports"),
                line(),


                _kaitem("/help",Icons.live_help_outlined,"Help"),
                line(),
                _kaitem("/rate",Icons.star_border,"Rate us"),
                line(),
                _kaitem("/about",Icons.star_border,"About us"),
                line(),


              ],


            ),
          ),

        ),
      ),
    );
  }


  Widget _kaitem(String route,IconData icon,String name) {
    return Column(
      children: [
       sizeh5(),
    ListTile(
    onTap: () {
    context.go(route);
    },
    leading:  Icon(icon),
    title:  Text(name),

    ),
        sizeh5()

    ],
    );

  }
}