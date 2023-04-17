import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class Leaderboard extends StatefulWidget {
  final AppUser user;
  const Leaderboard({super.key, required this.user});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late Query _query;
  final List<DocumentSnapshot> _data = [];
  final int _perPage = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  final _scrollController = ScrollController();

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
    setState(() {
      _data.addAll(documents);
      _lastDocument = documents.isNotEmpty ? documents.last : null;
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _data.length,
        itemBuilder: (context, index) {
          if (_isLoading && index == _data.length - 1) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = _data[index];
          return ListTile(
            title: Text(data['username']),
            subtitle: Text(data['points'].toString()),
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
