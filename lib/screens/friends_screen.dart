import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/widgets/friends_search_delegate.dart';

import '../models/user_model.dart';
import '../widgets/profile.dart';

class FriendsPage extends StatefulWidget {
  final AppUser user;

  const FriendsPage({super.key, required this.user});

  @override
  State<FriendsPage> createState() => _FriendsPageState(user: user);
}

class _FriendsPageState extends State<FriendsPage> {
  final AppUser user;
  late Future<List<AppUser>?> friends;
  final db = FirebaseFirestore.instance;

  _FriendsPageState({required this.user});

  @override
  void initState() {
    print("FRIENDS INITSTATE");
    super.initState();
    friends = loadFriends();
  }

  Future<List<AppUser>?> loadFriends() async {
    try {
      List<AppUser> friendsList = [];
      var querySnapshot = await db.collection('friends').where('user_id', isEqualTo: widget.user.uid).get();
      for (var docSnapshot in querySnapshot.docs) {
        var friendId = docSnapshot.get('friend_id');
        var friend = await AppUser.createUser(friendId);
        if (friend != null) {
          friendsList.add(friend);
        }
      }
      return friendsList;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  void addFriend(Map<String, dynamic> newFriend) async {
    try {
      await db.collection('friends').add({
        'user_id': user.uid,
        'friend_id': newFriend['uid'],
      });
      setState(() {
        friends = loadFriends();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void removeFriend(String uid) async {
    try {
      var querySnapshot = await db
          .collection('friends')
          .where(
            'user_id',
            isEqualTo: user.uid,
          )
          .where(
            'friend_id',
            isEqualTo: uid,
          )
          .get();
      for (var docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.delete();
      }
      setState(() {
        friends = loadFriends();
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          Tooltip(
            message: 'Add a friend',
            child: IconButton(
              onPressed: () async {
                var newFriend = await showSearch(
                  context: context,
                  delegate: FriendsSearchDelegate(user: user, friends: friends),
                );
                if (newFriend != null && newFriend.isNotEmpty) {
                  addFriend(newFriend);
                }
              },
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: friends,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var friend = snapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(friend.photoURL),
                      ),
                      title: Text(friend.username!),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Profile(
                              photoURL: friend.photoURL,
                              name: friend.username!,
                              title: '???',
                            ),
                          );
                        },
                      ),
                      trailing: Tooltip(
                        message: 'Remove friend',
                        child: IconButton(
                          iconSize: 30,
                          color: Colors.red,
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Remove friend"),
                                  content: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                          text: 'Are you sure you want to remove ',
                                        ),
                                        TextSpan(
                                          text: friend.username,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(
                                          text: ' from your friends?',
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
                                      child: const Text("Remove"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        removeFriend(friend.uid);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            print(snapshot.data);
            return const Center(
              child: Text('You have no friends :('),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
