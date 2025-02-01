
import 'dart:async';

import 'package:course_loading_system/components/reg_form.dart';
import 'package:course_loading_system/data/providers.dart';
import 'package:course_loading_system/data/streams.dart';
import 'package:course_loading_system/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../components/login_form.dart';
import '../components/reset_form.dart';

/// Credential Class


class ResetPass extends ConsumerStatefulWidget {
  ResetPass({super.key});

  @override
  ConsumerState<ResetPass> createState() => _StateLoginPage();


}

class _StateLoginPage extends   ConsumerState<ResetPass> {


  @override
  Widget build(BuildContext context) {



    var width4 = MediaQuery
        .of(context)
        .size
        .width / 2;
    return Scaffold(



      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 700) {



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
                            ResetPasswordScreen()
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


              ],
            );
          } else {



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
                                  ResetPasswordScreen()
                                ]


                            ),

                          ),
                        ],

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
            child:  ResetPasswordScreen()
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













