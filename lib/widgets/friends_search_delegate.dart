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
      var querySnapshot = await db.collection('users').where('username', isEqualTo: query).get();
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
      future: query.isNotEmpty ? findUsers() : Future<List?>.value([]),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index]['username']),
                onTap: () {
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
                },
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
