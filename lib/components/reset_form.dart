
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_dao.dart';
import '../data/providers.dart';


class ResetPasswordScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends  ConsumerState<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String message = '';


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void resetPassword() async {
    final userDao = ref.watch(userDaoProvider);
    if(_formKey.currentState!.validate()) {
      String? error = await userDao.resetPassword(emailController.text.trim());

      if (error == null) {
        setState(() {
          message = 'Password reset link sent! Check your email.';
        });
      } else {
        setState(() {
          message = error;
        });
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery
        .of(context)
        .size
        .height;
    return
        Container(
            height: height,
            padding: const EdgeInsets.all(26.0),
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(270))
            ),

            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      TextFormField(
                        controller: emailController,
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

                      logreg(),
                      SizedBox(height: 20),
                      Text(
                        message,
                        style: TextStyle(color: Colors.red),
                      ),

                    ],
                  ),

                )
            )


    );
  }


  Widget logreg() {
    return
      ElevatedButton(

        child: const Text('Send Reset Link'),
        style: ElevatedButton.styleFrom(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),

            ),
            elevation: 20,
            padding: EdgeInsets.all(5)
        ),

        onPressed: resetPassword,


      );
  }
}
