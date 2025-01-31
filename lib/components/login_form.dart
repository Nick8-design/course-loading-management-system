import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants.dart';
import '../data/providers.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class LoginForm extends ConsumerStatefulWidget {
  LoginForm({ super.key});
 // final ValueChanged<Credentials> onLogIn;

  @override
  ConsumerState<LoginForm> createState() => _StateLoginForm();

}

class _StateLoginForm extends   ConsumerState<LoginForm> {

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  int _currentImageIndex = 0;
  int p_index = 1;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
      key: _formKey,
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
  child:


          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              CircleAvatar(
                  radius: 40,
                  child: emailEnter ?
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/see/p$_currentImageIndex.png',
                      key: ValueKey<int>(_currentImageIndex),
                      height: 200,
                    ),
                  )
                      : pEnter ?
                  hide ?
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/see/oneeyepic1.png',
                      height: 200,
                    ),
                  )
                      :

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    child: Image.asset(
                      'assets/see/closed4.png',
                      height: 200,
                    ),
                  )
                      :

                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
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

  Widget logreg(){
    final userDao = ref.watch(userDaoProvider);
    return


      Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        ElevatedButton(
          child: const Text('Login'),
          onPressed: () async {

            // widget.onLogIn(Credentials(_emailController.value.text,
            //     _passwordController.value.text));
            //

            if (_formKey.currentState!.validate()) {
              final errorMessage = await userDao.login(
                _emailController.text,
                _passwordController.text,
              );

              if(userDao.isLoggedIn()){
                context.go('/0');

              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Pressed login"),
                  duration: const Duration(milliseconds: 700),
                ),
              );



              if (errorMessage != null) {
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
//Navigator.pushNamed(context, "/register");

          //  context.go('/login/register');


           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("Pressed reg"),
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
