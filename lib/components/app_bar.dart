import 'package:course_loading_system/components/theme_button.dart';
import 'package:course_loading_system/components/wavyappbarclipper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../data/providers.dart';
import 'color_button.dart';

class App_Bar extends ConsumerStatefulWidget{
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
  ConsumerState<App_Bar> createState() {
 return _StateAppBar();
  }

}
class _StateAppBar extends ConsumerState<App_Bar> {
  @override
  Widget build(BuildContext context) {
    final userDao = ref.watch(userDaoProvider);
   return

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
               userDao.logout();
               await Future.delayed(Duration(milliseconds: 1));
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