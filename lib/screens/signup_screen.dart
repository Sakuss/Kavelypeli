import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                true,
                () {
                  if (_passwordTextController.text != _passwordConfirmationTextController.text) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Passwords do not match"),
                        content: const Text("Please enter matching passwords to continue."),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"))
                        ],
                      ),
                    );
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
                      if (error is FirebaseAuthException && error.code == 'email-already-in-use') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Email is already in use"),
                            content: const Text("Please enter another email"),
                            actions: <Widget>[
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("OK"))
                            ],
                          ),
                        );
                        return;
                      } else {
                        //print("Error ${error.toString()}");
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
