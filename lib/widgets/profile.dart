import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kavelypeli/widgets/character_preview.dart';

import '../models/user_model.dart';

class Profile extends StatelessWidget {
  final AppUser user;
  final bool showTooltip;
  final VoidCallback? changeProfilePicture;

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
    required this.user,
    this.changeProfilePicture,
    super.key,
    this.showTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: changeProfilePicture,
                  child: showTooltip
                      ? Tooltip(
                          message: 'Tap to change profile picture',
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(user.photoURL),
                          ),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(user.photoURL),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Member since: ${DateFormat('dd.MM.yyyy').format(user.joinDate!)}',
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          CharacterPreview(user: user),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
              width: 200,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 2,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        user.steps.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Points',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        user.points.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
