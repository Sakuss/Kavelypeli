import 'package:flutter/material.dart';
import 'package:kavelypeli/screens/friends_screen.dart';
import 'package:kavelypeli/screens/profile_screen.dart';
import 'package:kavelypeli/screens/shop_screen.dart';

import '../screens/home_screen.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({super.key});

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
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Placeholder text"),
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          FriendsPage(),
          Home(),
          ShopPage(),
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
