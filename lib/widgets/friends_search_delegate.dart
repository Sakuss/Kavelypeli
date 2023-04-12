import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class FriendsSearchDelegate extends SearchDelegate<Map<String, dynamic>> {
  final db = FirebaseFirestore.instance;
  final AppUser user;

  FriendsSearchDelegate({required this.user});

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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      snapshot.data![index]['photoUrl'] ?? 'https://via.placeholder.com/150',
                    ),
                  ),
                  title: Text(snapshot.data![index]['username']),
                  onTap: () {
                    if (snapshot.data![index]['uid'] != user.uid) {
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
                  },
                ),
              );
            },
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
