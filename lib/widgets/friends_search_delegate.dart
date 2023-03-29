import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsSearchDelegate extends SearchDelegate<String> {
  final db = FirebaseFirestore.instance;
  Future<List> findUsers() async {
    var users = [];
    try {
      var querySnapshot = await db.collection('users').where('username', isEqualTo: query).get();
      for (var docSnapshot in querySnapshot.docs) {
        users.add(docSnapshot.data());
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
    return users;
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
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: findUsers(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index]['username']),
              );
            },
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
