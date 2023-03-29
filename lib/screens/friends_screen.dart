import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  String _searchText = '';
  List<String> friends = [
    "friend1",
    "friend2",
    "friend3",
    "friend4",
    "friend5",
    "friend6",
  ];

  void findUsers() async {
    final db = FirebaseFirestore.instance;

    try {
      var querySnapshot = await db.collection('users').where('username', isEqualTo: _searchText).get();
      for (var docSnapshot in querySnapshot.docs) {
        var userName = docSnapshot.get('username');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void getFriends() async {
    // const user = firebase.auth().currentUser;
    // var userId = user.uid;
    var userId = 'testid';

    final db = FirebaseFirestore.instance;

    try {
      var querySnapshot = await db.collection('friends').where('user_id', isEqualTo: userId).get();
      for (var docSnapshot in querySnapshot.docs) {
        var friendId = docSnapshot.get('friend_id');
        var friendName = await db.collection('users').doc(friendId).get();
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              style: const TextStyle(
                fontSize: 20,
                decorationThickness: 0,
              ),
              decoration: const InputDecoration(
                hintText: 'Search new friends...',
                prefixIcon: Icon(Icons.search),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: friends
                  .map(
                    (friend) => Card(
                      child: Container(
                        child: Text(friend),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ),
                  )
                  .toList()),
          GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: friends
                  .map(
                    (friend) => Card(
                      child: Column(
                        children: [
                          Text(friend),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList()),
        ],
      ),
    );
  }
}
