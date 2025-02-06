import 'package:course_loading_system/components/password.dart';
import 'package:course_loading_system/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../data/providers.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/reset_pass.dart';

class LoginForm extends ConsumerStatefulWidget {
  LoginForm( { required this.roles,super.key});


final String roles;

  @override
  ConsumerState<LoginForm> createState() => _StateLoginForm();

}

class _StateLoginForm extends   ConsumerState<LoginForm> {

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  int _currentImageIndex = 0;
  int p_index = 1;

  final GlobalKey<FormState> _formKeylogin = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateImage);
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateImage);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _updateImage() {
    final emailLength = _emailController.text.length;

    setState(() {
      if (emailLength == 0) {
        _currentImageIndex = 7; // p0.png
      } else if (emailLength >= 1 && emailLength <= 8) {
        _currentImageIndex = emailLength; // p1 to p8.png
      } else {
        _currentImageIndex = 9; // p9.png
      }
    });
  }


  bool hide = false;
  bool pEnter = false;

  bool emailEnter = false;

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    return Container(
      key: _formKeylogin,
        height: height,
        padding: const EdgeInsets.all(26.0),
        decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(270))
        ),

        child:

        Padding(
          padding: const EdgeInsets.all(16.0),
          child:
Form(
  key: _formKeylogin,
  child:


          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircleAvatar(
                  radius: 40,
                  child: emailEnter ?
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Image.asset(
                      'assets/see/p$_currentImageIndex.png',
                      key: ValueKey<int>(_currentImageIndex),
                      height: 200,
                    ),
                  )
                      : pEnter ?
                  hide ?
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Image.asset(
                      'assets/see/oneeyepic1.png',
                      height: 200,
                    ),
                  )
                      :

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Image.asset(
                      'assets/see/closed4.png',
                      height: 200,
                    ),
                  )
                      :

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 10),
                    child: Image.asset(
                      'assets/see/p7.png',

                      height: 200,
                    ),
                  )


              ),


              const SizedBox(height: 10),


              TextFormField(
                controller: _emailController,
                autofocus: false,

                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                onTap: () {
                  setState(() {
                    emailEnter = true;
                    pEnter = false;
                  });
                },
                onTapOutside: (bool) {
                  setState(() {
                    emailEnter = false;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    emailEnter = false;
                  });
                 },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Email Required';
                  }
                  return null;
                },

                keyboardType: TextInputType.emailAddress,
              ),


              const SizedBox(height: 12),


              TextFormField(
                controller: _passwordController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Password Required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !hide,
                onTap: () {
                  setState(() {
                    pEnter = true;
                    emailEnter = false;
                  });
                },
                onTapOutside: (bool) {
                  setState(() {
                    pEnter = false;
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    pEnter = false;
                  });
                },

                decoration: InputDecoration(
                    label: Text('Password'),


                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8.0), // Rounded corner border
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hide ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          hide = !hide;
                        });
                      },

                    )

                ),
              ),
              const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(child: reset(),
                )
              ,
              logreg(),
            ]
            ),

              const SizedBox(height: 24),



            ],
          ),
)
        )


    );


  }
  void checkUserRole() async {
    final userDao = ref.watch(userDaoProvider);
    String? role;

    // Wait for authentication to fully complete before checking role
    for (int i = 0; i < 5; i++) {
      role = await userDao.getUserRole();
      if (role != null) break;
      await Future.delayed(Duration(milliseconds: 300)); // Wait for auth state
    }

    if (role == 'admin') {
      if (mounted) context.go('/dashboard'); // Navigate without refresh
      showSnackBar("Successfully logged in Admin");
    } else if (role == 'instructor') {
      if (mounted) context.go('/instructor');
      showSnackBar("Successfully logged in Instructor");
    } else {
      showSnackBar("Login failed. Please try again.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 700),
      ),
    );
  }







  Widget logreg(){
    final userDao = ref.watch(userDaoProvider);
    return


      Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          child: const Text('Login'),
          onPressed: () async {
            if (_formKeylogin.currentState!.validate()) {
              final errorMessage = await userDao.login(
                _emailController.text,

                  ref.watch(userRoleProvider).value== widget.roles?
                      hashPassword(_passwordController.text):""



              );


              if (errorMessage == null) {
                await Future.delayed(Duration(milliseconds: 2)); // Small delay to ensure auth state update
               // if (mounted) {
                //  checkUserRole();

                  context.go('/dashboard');
               // }
              } else {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    duration: const Duration(milliseconds: 700),
                  ),
                );
              }



            }






          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),

            ),
            elevation: 20,
            padding: EdgeInsets.all(5)
          ),


        ),
        SizedBox(height: 10,),
Text("Or",style: TextStyle(
  color: Colors.white,
  fontSize: 16
),),
        SizedBox(height: 10,),
      
        ElevatedButton(

          child: const Text('Register'),
          style: ElevatedButton.styleFrom(
          
         shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
            elevation: 20,
            padding: EdgeInsets.all(5)
    ),

          
          onPressed: ()  {

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>    RegisterPage()),
            );



           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("Build with security in mind"),
               duration: const Duration(milliseconds: 700),
             ),
           );
          },


        ),
        
      ],


    );



  }

  Widget reset(){
    return Row(
      children: [
        Text('Forgot password?',
    style: TextStyle(
       fontSize: 12
    ),),
        SizedBox(width: 2,),
        GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPass()),
            );
          },
          child: Text("Reset",style: TextStyle(
            color: Colors.white
                ,fontSize: 13
          ),),
        )
      ],
    );
  }

}
