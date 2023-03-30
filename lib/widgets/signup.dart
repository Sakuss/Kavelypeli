import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:kavelypeli/ReUse/Reusables.dart';
import 'package:kavelypeli/widgets/pagecontainer.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _passwordConfirmationTextController =
      TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

  void _createUserDocument(User user) {
    FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'email': user.email,
      'username': _userNameTextController.text,
    }).then((value) {
      print('User document created successfully!');
    }).catchError((error) {
      print('Failed to create user document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    retextfield("Username", Icons.person_outline, false,
                        _userNameTextController),
                    const SizedBox(
                      height: 30,
                    ),
                    retextfield("Email", Icons.mail_outline, false,
                        _emailTextController),
                    const SizedBox(
                      height: 30,
                    ),
                    retextfield("Password", Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 30,
                    ),
                    retextfield("Confirm Password", Icons.lock_outline, true,
                        _passwordConfirmationTextController),
                    const SizedBox(
                      height: 30,
                    ),
                    SignButtons(context, true, () {
                      if (_passwordTextController.text !=
                          _passwordConfirmationTextController.text) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text("Passwords do not match"),
                                  content: const Text(
                                      "Please enter matching passwords to continue."),
                                  actions: <Widget>[
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("OK"))
                                  ],
                                ));
                        return;
                      }
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        _createUserDocument(value.user!);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PageContainer(
                                      children: [],
                                    )));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    }),
                  ],
                ))));
  }
}
