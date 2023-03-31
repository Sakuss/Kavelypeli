import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:kavelypeli/Reusable_widgets/SignInSignOut_widgets.dart';
import 'package:kavelypeli/widgets/pagecontainer.dart';
import 'package:kavelypeli/widgets/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    retextfield("Email", Icons.person_outline, false,
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
                          .signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PageContainer(children: [])));
                      }).catchError((error) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Error"),
                              content:
                                  const Text("Incorrect email or password"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("OK"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      });
                    }),
                    SignupOption()
                  ],
                ))));
  }

  Row SignupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SignUp()));
            },
            child: const Text(
              "Sign up",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ))
      ],
    );
  }
}
