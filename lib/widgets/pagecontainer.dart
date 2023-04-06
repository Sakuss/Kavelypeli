import 'package:flutter/material.dart';
import 'package:kavelypeli/screens/friends_screen.dart';
import 'package:kavelypeli/screens/profile_screen.dart';

import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';

class PageContainer extends StatefulWidget {
  final Function changeTheme;

  const PageContainer({super.key, required this.changeTheme});

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  int _selectedIndex = 1;
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
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: Icon(
                Icons.account_circle_sharp,
                size: 48.0,
                color: Colors.white,
              ),
              accountName: Text('Username'),
              accountEmail: Text('test@gmail.com'),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
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
                // Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryPage()));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FriendsPage()));
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
                      builder: (context) =>
                          SettingsScreen(changeTheme: widget.changeTheme),
                      // Text("settings"),
                    ));
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Placeholder text"),
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          FriendsPage(),
          Home(),
          ProfilePage(),
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
            icon: Icon(Icons.shopping_basket),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
