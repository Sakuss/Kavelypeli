import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({Key? key}) : super(key: key);

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> {
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  final auth = FirebaseAuth.instance;

  List<DocumentSnapshot>? _achievements;
  int? _userSteps;

  @override
  void initState() {
    super.initState();
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      // Retrieve the user's step count from Firestore
      db.collection('users').doc(userId).get().then((DocumentSnapshot snapshot) {
        setState(() {
          _userSteps = snapshot.get('steps');
        });
      });
    }
    // Retrieve the list of achievements from Firestore, ordered by step requirement
    db.collection('achievements').orderBy('req').get().then((QuerySnapshot snapshot) {
      setState(() {
        _achievements = snapshot.docs;
      });
    });
  }

  // Add a method to calculate the user's progress towards the next achievement
  int calculateProgress(int requiredSteps, int userSteps) {
    if (userSteps == 0) {
      return 0;
    } else {
      int progress = userSteps % requiredSteps;
      return progress == 0 ? requiredSteps : progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: _achievements?.map((achievement) {
                    int requiredSteps = achievement['req'];
                    int progress = calculateProgress(requiredSteps, _userSteps ?? 0);
                    if (_userSteps != null && _userSteps! >= requiredSteps) {
                      return FutureBuilder(
                        future: storage.refFromURL(achievement['imageUrl']).getDownloadURL(),
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading image'),
                            );
                          } else {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(snapshot.data!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              achievement['name'],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              achievement['desc'],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Completed!',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    } else {
                      return Opacity(
                        opacity: 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.lock,
                                  size: 50,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  achievement['name'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unlock at $requiredSteps steps',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Progress: $progress / $requiredSteps',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  }).toList() ??
                  [],
            ),
          ),
        ],
      ),
    );
  }
}
