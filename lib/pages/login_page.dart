
import 'package:flutter/material.dart';


import '../components/login_form.dart';

/// Credential Class
class Credentials {
  Credentials(this.username, this.password);
  final String username;
  final String password;
}

class LoginPage extends StatefulWidget {
   LoginPage({super.key});

  // /// Called when users sign in with [Credentials].
  // final ValueChanged<Credentials> onLogIn;
  //


  @override
  State<LoginPage> createState() => _StateLoginPage();


}

class _StateLoginPage extends   State<LoginPage> {
  String _selectedButton = '';


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
                          image: AssetImage('assets/mmust.jpg'),
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
              LoginForm()
          ]


          ),


                    )
                ),
                Positioned(
                  top: 32,
                  right: 16,
                  child: adminbtn(),
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
                              LoginForm()
                            ]


                        ),

                      ),
                    ],

                  ),
                  Positioned(
                    top: 32,
                    right: 16,
                    child: adminbtn(),
                  ),


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
            child: LoginForm()

        )


      ],
    );
  }


}













