import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../widgets/profile.dart';

class Leaderboard extends StatefulWidget {
  final AppUser user;
  const Leaderboard({super.key, required this.user});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late Query _query;
  final List<AppUser> _users = [];
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  final _scrollController = ScrollController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _getMoreUsers();
  }

  Future<void> _getMoreUsers() async {
    _query = FirebaseFirestore.instance.collection('users').orderBy('points', descending: true).limit(_perPage);
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    final snapshot = _lastDocument == null ? await _query.get() : await _query.startAfterDocument(_lastDocument!).get();
    final documents = snapshot.docs;
    for (final document in documents) {
      if (!mounted) return;
      AppUser user = AppUser(
        uid: document.id,
        photoURL: await AppUser.getPhotoURL(document.id),
        joinDate: document['joinDate'].toDate(),
        username: document['username'],
        points: document['points'],
        steps: document['steps'],
      );
      _users.add(user);
    }
    setState(() {
      _lastDocument = documents.isNotEmpty ? documents.last : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _users.length,
        itemBuilder: (context, index) {
          if (_isLoading && index == _users.length - 1) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final user = _users[index];
          bool isAppUser = user.username == widget.user.username;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: ListTile(
              leading: Text('${index + 1}.'),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.photoURL),
                  ),
                  const SizedBox(width: 8),
                  isAppUser
                      ? Text(
                          user.username!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(user.username!),
                  if (isAppUser)
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                ],
              ),
              onTap: isAppUser
                  ? null
                  : () => showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15),
                              ),
                            ),
                            child: Profile(
                              user: user,
                            ),
                          );
                        },
                      ),
              trailing: Text(user.points.toString()),
            ),
          );
        },
      ),
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            _scrollController.position.extentAfter == 0 &&
            _lastDocument != null) {
          _getMoreUsers();
        }
        return false;
      },
    );
  }
}
