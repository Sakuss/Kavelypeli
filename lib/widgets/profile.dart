import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: CircleAvatar(
              radius: 100,
              backgroundImage:
                  NetworkImage('https://i.pinimg.com/originals/ba/92/7f/ba927ff34cd961ce2c184d47e8ead9f6.jpg'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Text(
              'John Doe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
