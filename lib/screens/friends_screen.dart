import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/widgets/friends_search_delegate.dart';

import '../widgets/profile.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final db = FirebaseFirestore.instance;

  Future<List> loadFriends() async {
    // const user = firebase.auth().currentUser;
    // var userId = user.uid;
    var userId = 'testid';
    var friends = [];

    try {
      var querySnapshot = await db.collection('friends').where('user_id', isEqualTo: userId).get();
      for (var docSnapshot in querySnapshot.docs) {
        var friendId = docSnapshot.get('friend_id');
        var friend = await db.collection('users').doc(friendId).get();
        friends.add(friend.data());
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
    return friends;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: FriendsSearchDelegate());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadFriends(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                                  return const Dialog(
                                    child: Profile(),
                                  );
                                },
                              ),
                              child: Center(
                                child: Text(friend['username']),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
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
