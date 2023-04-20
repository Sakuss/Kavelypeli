import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kavelypeli/screens/achievements_screen.dart';
import 'package:kavelypeli/screens/friends_screen.dart';
import 'package:kavelypeli/screens/profile_screen.dart';
import 'package:kavelypeli/screens/shop_screen.dart';
import 'package:kavelypeli/screens/inventory_screen.dart';
import 'package:kavelypeli/screens/signin_screen.dart';

import '../models/user_model.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/settings_screen.dart';

class PageContainer extends StatefulWidget {
  final Function changeTheme;
  final AppUser user;

  const PageContainer({
    super.key,
    required this.changeTheme,
    required this.user,
  });

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  int _selectedIndex = 1;
  int? _stepGoal = null;
  final PageController _pageController = PageController(initialPage: 1);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // print("building pagecontainer");
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(widget.user.photoURL),
              ),
              accountName: Text(widget.user.username ?? "no username"),
              accountEmail: Text(widget.user.email ?? "no email"),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Color(0xFF13C0E3),
                ),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)));
                }),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.inventory,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Inventory'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InventoryPage(user: widget.user,))).then((value) {
                      setState(() {});
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.star,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Achievements'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AchievementPage()));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.people,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Friends'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendsPage(
                              user: widget.user,
                            )));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.bar_chart,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Stats'),
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => StatsPage()));
              },
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.black),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(
                        changeTheme: widget.changeTheme,
                        user: widget.user,
                      ),
                    )).then((value) {
                  setState(() {
                    _stepGoal = value;
                    print(_stepGoal);
                  });
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFF13C0E3),
              ),
              title: const Text('Log out'),
              onTap: () {
                widget.changeTheme(ThemeMode.light);
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SignIn(
                              changeTheme: widget.changeTheme,
                            )));
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Kävelypeli"),
      ),
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Leaderboard(user: widget.user),
          Home(user: widget.user, stepGoal: _stepGoal),
          ShopPage(
            user: widget.user,
          )
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_chart),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Home.icon),
            label: Home.name,
          ),
          BottomNavigationBarItem(
            icon: Icon(ShopPage.icon),
            label: ShopPage.name,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
