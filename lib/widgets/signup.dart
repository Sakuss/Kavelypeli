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
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();

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
                    SignButtons(context, true, () {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
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
