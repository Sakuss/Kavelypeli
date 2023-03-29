import 'package:flutter/material.dart';

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
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(leading: Icon(Icons.person), title: Text('Profile')),
            SizedBox(
              height: 20,
            ),
            ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
            SizedBox(
              height: 20,
            ),
            ListTile(leading: Icon(Icons.inventory), title: Text('Inventory')),
            SizedBox(
              height: 20,
            ),
            ListTile(leading: Icon(Icons.people), title: Text('Friends')),
            SizedBox(
              height: 20,
            ),
            ListTile(leading: Icon(Icons.bar_chart), title: Text('Stats')),
            SizedBox(
              height: 20,
            ),
            ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications')),
            SizedBox(
              height: 20,
            ),
            ListTile(
                leading: Icon(Icons.logout_rounded), title: Text('Log out')),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Placeholder text"),
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
