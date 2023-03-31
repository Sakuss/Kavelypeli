import 'package:flutter/material.dart';
import 'package:kavelypeli/pages/profile_page.dart';
import 'package:kavelypeli/pages/stats_page.dart';
import '../pages/friends_page.dart';
import '../pages/inventory_page.dart';
import '../pages/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home'),
    Text('Search'),
    Text('Profile'),
  ];

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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InventoryPage()));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StatsPage()));
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
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
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
