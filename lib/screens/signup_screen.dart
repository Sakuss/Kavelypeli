import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/util.dart';

import '../Reusable_widgets/SignInSignOut_widgets.dart';
import '../models/user_model.dart';
import '../widgets/pagecontainer.dart';

class SignUp extends StatefulWidget {
  final Function changeTheme;

  const SignUp({super.key, required this.changeTheme});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _passwordConfirmationTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              retextfield("Username", Icons.person_outline, false, _userNameTextController),
              const SizedBox(
                height: 25,
              ),
              retextfield("Email", Icons.mail_outline, false, _emailTextController),
              const SizedBox(
                height: 25,
              ),
              retextfield("Password", Icons.lock_outline, true, _passwordTextController),
              const SizedBox(
                height: 25,
              ),
              retextfield("Confirm Password", Icons.lock_outline, true, _passwordConfirmationTextController),
              const SizedBox(
                height: 25,
              ),
              SignButtons(
                context,
                false,
                () {
                  if (_userNameTextController.text.isEmpty) {
                    showAlertDialog(context, "Please enter a username to continue");
                    return;
                  }
                  if (_passwordTextController.text != _passwordConfirmationTextController.text) {
                    showAlertDialog(context, "Please enter matching passwords to continue");
                    return;
                  }
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text, password: _passwordTextController.text)
                      .then(
                    (responseData) async {
                      var user = await AppUser.createUserOnSignup(
                        responseData.user!,
                        _userNameTextController.text,
                        _emailTextController.text,
                      );

                      if (user == null) {
                        //do something
                      }
                      Util().clearPrefs();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageContainer(
                            changeTheme: widget.changeTheme,
                            user: user!,
                          ),
                        ),
                      );
                    },
                  ).onError(
                    (error, stackTrace) {
                      if (error is FirebaseAuthException) {
                        if (error.code == 'weak-password') {
                          showAlertDialog(
                            context,
                            'Password too weak. Provide password with at least 6 characters',
                          );
                        } else if (error.code == 'email-already-in-use') {
                          showAlertDialog(context, 'Email is already in use');
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
