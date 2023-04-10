import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Reusable_widgets/SignInSignOut_widgets.dart';
import '../models/user_model.dart';
import '../widgets/pagecontainer.dart';
import './signup_screen.dart';

class SignIn extends StatefulWidget {
  final Function changeTheme;

  const SignIn({super.key, required this.changeTheme});

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
              retextfield(
                  "Email", Icons.person_outline, false, _emailTextController),
              const SizedBox(
                height: 30,
              ),
              retextfield("Password", Icons.lock_outline, true,
                  _passwordTextController),
              const SizedBox(
                height: 30,
              ),
              SignButtons(
                context,
                true,
                () {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then(
                    (responseData) async {
                      print("VALUE : $responseData");
                      var user =
                          await AppUser.createUserOnLogin(responseData.user!);
                      if (user == null) {
                        //do something
                      }
                      // Util().saveToPrefs("uid", value.user?.uid);
                      // Util().saveToPrefs(
                      //   "user",
                      //   AppUser(
                      //           username: value.additionalUserInfo?.username,
                      //           uid: value.user?.uid,
                      //           email: value.user?.email)
                      //       .toJson(),
                      // );
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
                  ).catchError(
                    (error) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text("Incorrect email or password"),
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
                    },
                  );
                },
              ),
              SignupOption()
            ],
          ),
        ),
      ),
    );
  }

  Row SignupOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SignUp(changeTheme: widget.changeTheme)));
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
