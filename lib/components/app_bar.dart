import 'package:course_loading_system/components/theme_button.dart';
import 'package:course_loading_system/components/wavyappbarclipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import 'color_button.dart';

class App_Bar extends StatefulWidget{
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  final title;

   App_Bar({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
    required this.title,
  });
  @override
  State<App_Bar> createState() {
 return _StateAppBar();
  }

}
class _StateAppBar extends State<App_Bar> {
  @override
  Widget build(BuildContext context) {
   return
   // Container(
   //   width: 120,
   //   child:
   //

     ClipPath(
       clipper: WavyAppBarClipper(),
       child: AppBar(
         title: Text(widget.title),
         elevation: 8.0,
         backgroundColor: Colors.blueAccent,
         actions: [
           ThemeButton(changeThemeMode: widget.changeTheme),
           ColorButton(changeColor: widget.changeColor, colorSelected: widget.colorSelected),
           IconButton(
             onPressed: () async {
               context.go('/login');
             },
             icon: Icon(Icons.logout_sharp),
           ),
         ],
       ),
   //  ),


    // ),


   );

  }

}