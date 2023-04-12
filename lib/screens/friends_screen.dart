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

  Future<List<AppUser>?> appendFriendToFutureFriendsList(AppUser friend) async {
    var friendsList = await friends;
    if (friendsList != null) {
      friendsList.add(friend);
    }
    return friendsList;
  }

  void addFriend(Map<String, dynamic> newFriend) async {
    try {
      setState(() {
        friends = appendFriendToFutureFriendsList(AppUser(
          uid: newFriend['uid'],
          username: newFriend['username'],
          photoUrl: newFriend['photoUrl'],
          joinDate: newFriend['joinDate'].toDate(),
          steps: newFriend['steps'],
          points: newFriend['points'],
          currency: newFriend['currency'],
        ));
      });
      await db.collection('friends').add({
        'user_id': user.uid,
        'friend_id': newFriend['uid'],
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
                  delegate: FriendsSearchDelegate(user: user),
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
            return Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: snapshot.data!
                        .map(
                          (friend) => Card(
                            elevation: 5,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: InkWell(
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
                                      name: friend.username!,
                                      title: '???',
                                      profilePictureUrl: friend.photoUrl,
                                    ),
                                  );
                                },
                              ),
                              child: Center(
                                child: Text(friend.username!),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
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
