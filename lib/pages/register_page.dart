
import 'dart:async';

import 'package:course_loading_system/components/reg_form.dart';
import 'package:course_loading_system/data/providers.dart';
import 'package:course_loading_system/data/streams.dart';
import 'package:course_loading_system/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../components/login_form.dart';

/// Credential Class


class RegisterPage extends ConsumerStatefulWidget {
  RegisterPage({super.key});





  @override
  ConsumerState<RegisterPage> createState() => _StateLoginPage();


}

class _StateLoginPage extends   ConsumerState<RegisterPage> {
  Stream<String> _selectedButton = datastream.stream;


  void changename(){
    ( ref.watch(selectedNameProvider)=='Admin')?
    setState(() {
      is_active=false;
    }):setState(() {
      is_active= true;
    });

  }
bool phn=false;

  @override
  Widget build(BuildContext context) {


    changename();
    var width4 = MediaQuery
        .of(context)
        .size
        .width / 2;
    return Scaffold(

//
//       appBar: AppBar(
// leading:
// IconButton(
//     onPressed: (){
//      Navigator.push(context,
//          MaterialPageRoute(builder:(context)=> LoginPage()
//          )
//
//      );
//     },
//     icon: Icon(Icons.arrow_back_sharp)
// ),
//
//
//       ),
//


      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 700) {

              phn=false;

            return  Stack(
              children: [


                Container(
                  margin: const EdgeInsets.only(right: 100.0),
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      // borderRadius: BorderRadius.circular(16.0),
                      image: DecorationImage(
                          image: AssetImage("assets/mmust.jpg"),
                          fit: BoxFit.cover)),
                ),
                Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: SizedBox(
                      width: width4,
                      child:
                      ListView(
                          children: [
                         RegForm()
                          ]


                      ),


                    )
                ),

                Positioned(
                  left: 16,
                  top: 16,

                  child: IconButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder:(context)=> LoginPage()
                            )

                        );
                      },
                      icon: Icon(Icons.arrow_back_sharp)
                  ),


                ),

                Positioned(
                  top: phn? 64:45,
                  right: phn?8:16,
                  child: adminbtn(),
                ),


              ],
            );
          } else {

              phn=true;

            // Display Mobile View
            return Scaffold(
                body:

                Stack(
                    children: [


                      Column(
                        children: [
                          Expanded(

                            child:
                            ListView(
                                children: [
                                 RegForm()
                                ]


                            ),

                          ),
                        ],

                      ),
                      Positioned(
                          top: 32,
                          right: 16,
                          child:Container(
                            margin: EdgeInsets.only(top: 25),
                            child:    adminbtn(),
                          )


                      ),
      Positioned(
          left: 16,
          top: 16,

          child: IconButton(
          onPressed: (){
          Navigator.push(context,
          MaterialPageRoute(builder:(context)=> LoginPage()
          )

          );
          },
          icon: Icon(Icons.arrow_back_sharp)
          ),


          )
                    ]
                )
            );
          }
        },
      ),
    );
  }

  Widget adminbtn() {
    return Row(

      children: [
        adbtn(),

        SizedBox(width: 4),


        tuitorbtn()
      ],
    );
  }

  bool is_active = false;



  Widget adbtn() {
    return GestureDetector(

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0,5),
                  blurRadius: 10
              )
            ],

            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
            color: Colors.white,
            border: !is_active ?

            Border(
                left: BorderSide(color: !is_active ?
                Colors.yellow : Colors.grey,
                    width: 4),


                bottom: BorderSide(
                    color: !is_active ? Colors.yellow : Colors.grey,
                    width: 4),
                right: BorderSide.none,
                top: BorderSide.none
            )
                :
            Border(
                left: BorderSide.none,
                bottom: BorderSide(color: Colors.grey, width: 4),
                right: BorderSide.none,
                top: BorderSide.none


            )
        ),
        child: Text("Admin"),

      ),


      //),
      onTap: () {
        setState(() {
          is_active = !is_active;
          ref.read(selectedNameProvider.notifier).state="Admin";
        });
      },
    );
  }

  Widget tuitorbtn() {
    return GestureDetector(

      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            boxShadow: [  BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: Offset(0,5),
                blurRadius: 10
            )
            ],
            borderRadius: is_active ?
            BorderRadius.only(bottomLeft: Radius.circular(16)) :
            BorderRadius.only(bottomLeft: Radius.circular(0)),

            color: Colors.white,
            border: is_active ?

            Border(
                left: BorderSide(color: is_active ?
                Colors.yellow : Colors.grey,
                    width: 4),


                bottom: BorderSide(
                    color: is_active ? Colors.yellow : Colors.grey,
                    width: 4),
                right: BorderSide.none,
                top: BorderSide.none
            )
                :
            Border(
                left: BorderSide.none,
                bottom: BorderSide(color: Colors.grey, width: 4),
                right: BorderSide.none,
                top: BorderSide.none


            )
        ),
        child: Text("Instructor"),

      ),


      //),
      onTap: () {
        setState(() {
          is_active = !is_active;
          ref.read(selectedNameProvider.notifier).state="Instructor";
        });
      },
    );
  }


  Widget largeScreen() {
    return Stack(
      children: [

        Container(
          margin: const EdgeInsets.only(right: 200.0),
          decoration: const BoxDecoration(
              color: Colors.grey,
              // borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                  image: AssetImage('assets/mmust.jpg'),
                  fit: BoxFit.cover)),
        ),
        Positioned(
            right: 0,
            child: RegForm()
        ),
        Positioned(
          left: 16,
          top: 16,

          child: IconButton(
              onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder:(context)=> LoginPage()
                    )

                );
              },
              icon: Icon(Icons.arrow_back_sharp)
          ),


        )

      ],
    );
  }


}













