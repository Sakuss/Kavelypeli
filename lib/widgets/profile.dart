import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String name;
  final String title;
  final String? profilePictureUrl;
  // final DateTime joinedDate;
  // final String? bio;

  //achievements?
  //points, steps
  //profile picture
  //bio?
  //mutual friends / all friends?
  //joined date?
  //walking data (steps/distance per day / week / month)

  const Profile({
    required this.name,
    required this.title,
    // required this.joinedDate,
    this.profilePictureUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: CircleAvatar(
              radius: 100,
              backgroundImage:
                  NetworkImage('https://i.pinimg.com/originals/ba/92/7f/ba927ff34cd961ce2c184d47e8ead9f6.jpg'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
