import 'package:course_loading_system/components/password.dart';
import 'package:course_loading_system/data/providers.dart';
import 'package:course_loading_system/data/streams.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/login_page.dart';

class RegForm extends ConsumerStatefulWidget {
  RegForm({ super.key,this.whichbtn});
final whichbtn;

  @override
  ConsumerState<RegForm> createState() => _StateRegForm();

}

class _StateRegForm extends   ConsumerState<RegForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  final TextEditingController _emailController = TextEditingController();


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();




  @override
  void initState() {
    super.initState();


  }

  @override
  void dispose() {


    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }







  @override
  Widget build(BuildContext context) {

    String selectedUser=ref.watch(selectedNameProvider);
    var height=MediaQuery.of(context).size.height;
    return


      Container(
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
                  key: _formKey,
                  child:



            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                DropdownButton<String>
                  (
                  value: selectedUser,
                    items: <String>['Admin','Instructor']
                    .map<DropdownMenuItem<String>>((String user){
                      return DropdownMenuItem<String>(
                        value: user,
                        child: Text(user),
                      );
                    }).toList(),
                    onChanged: (newValue){
                    setState(() {
                    //  selectedUser=newValue!;
                      // datastream.updateData(selectedUser);
                      ref.read(selectedNameProvider.notifier).state=newValue!;


                    });
                    }
                ),


                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter your email',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: false,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),


                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Password Required';
                    }
                    return null;
                  },
                  autofocus: false,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                      label: Text('Password'),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8.0), // Rounded corner border
                      ),



                  ),
                ),


                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordConfirm,
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  validator: (String? value) {
                    if (value!=_passwordController.text) {
                      return 'Passwords don\'t match';
                    }
                    return null;
                  },
                  obscureText: true,

                  decoration: InputDecoration(
                      label: Text('Confirm Password'),
                      // filled: true,

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8.0), // Rounded corner border
                      ),


                  ),
                ),
                const SizedBox(height: 24),

                      logreg(),

                const SizedBox(height: 24),



              ],
            ),

                )
          )


      );


  }

  void checkUserRole() async {
    final userDao = ref.watch(userDaoProvider);
    String? role = await userDao.getUserRole();
    if (role == 'admin') {
      Navigator.pushNamed(context, '/dashboard');
    } else if (role == 'instructor') {
      Navigator.pushNamed(context, '/instructor');
    }
  }


  Widget logreg(){
    final userDao = ref.watch(userDaoProvider);

    return
          ElevatedButton(

            child: const Text('Register'),
            style: ElevatedButton.styleFrom(

                shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),

                ),
                elevation: 20,
                padding: EdgeInsets.all(5)
            ),

            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final errorMessage = await userDao.signup(
                  _emailController.text,
                  _passwordConfirm.text == _passwordController.text ?
                  hashPassword(_passwordController.text)
                      : '',
                  ref.watch(selectedNameProvider),

                );


                if (_formKey.currentState!.validate()) {
                  final errorMessage = await userDao.login(
                    _emailController.text,
                  //  _passwordController.text,
                     hashPassword(_passwordController.text)
                  );


                  if (errorMessage == null) {
                    await Future.delayed(Duration(milliseconds: 2)); // Small delay to ensure auth state update

                    context.go('/dashboard');

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




      );



  }



}
