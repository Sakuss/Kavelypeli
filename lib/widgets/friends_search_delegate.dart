import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class FriendsSearchDelegate extends SearchDelegate<Map<String, dynamic>> {
  final db = FirebaseFirestore.instance;
  final AppUser user;
  final Future<List<AppUser>?> friends;

  FriendsSearchDelegate({required this.user, required this.friends});

  Future<List?> findUsers() async {
    List users = [];
    try {
      var querySnapshot = await db
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();
      for (var docSnapshot in querySnapshot.docs) {
        var userData = docSnapshot.data();
        userData['uid'] = docSnapshot.id;
        users.add(userData);
      }
      return users;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool?> checkIfIsFriend(String uid) async {
    var friends = await this.friends;
    if (friends != null) {
      for (var friend in friends) {
        return friend.uid == uid;
      }
    }
    return null;
  }

  Future<void> onTap(context, snapshot, index) async {
    var isFriend = await checkIfIsFriend(snapshot.data![index]['uid']);
    if (isFriend == null) {
      return;
    } else if (isFriend) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add friend"),
            content: const Text("You are already friends with this user"),
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
    } else if (snapshot.data![index]['uid'] != user.uid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add friend"),
            content: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Add ',
                  ),
                  TextSpan(
                    text: snapshot.data![index]['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: ' as a friend?',
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  Navigator.of(context).pop();
                  close(context, snapshot.data![index]);
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add friend"),
            content: const Text("You can't add yourself as a friend"),
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
    }
  }

  @override
  String get searchFieldLabel => 'Find user';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, {});
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: query.length >= 2 ? findUsers() : Future<List?>.value([]),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.data![index]['photoUrl'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    title: Text(snapshot.data![index]['username']),
                    onTap: () => onTap(context, snapshot, index),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No users found'),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
