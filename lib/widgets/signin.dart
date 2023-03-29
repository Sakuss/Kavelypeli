import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:kavelypeli/ReUse/Reusables.dart';
import 'package:kavelypeli/widgets/pagecontainer.dart';
import 'package:kavelypeli/widgets/signup.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
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
                                    PageContainer(children: [])));
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
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SignUp()));
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
