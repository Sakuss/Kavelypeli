import 'package:flutter/material.dart';

class CharacterRender extends StatelessWidget {
  const CharacterRender({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        children: <Widget>[
          const Center(
            child: Text(
              "Your character",
              style:
                  TextStyle(fontSize: 25, decoration: TextDecoration.underline),
            ),
          ),
          Center(
            child: Image.asset(
              "assets/images/apustaja.png",
              // width: MediaQuery.of(context).size.width * 0.8,
              // fit: BoxFit.scaleDown,
            ),
          ),
        ],
      ),
    );
  }
}
