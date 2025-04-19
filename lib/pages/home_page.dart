// ignore_for_file: unused_field, unused_local_variable

import 'package:flutter/material.dart';

import '../pages/profile_page.dart';
import '../pages/recent_conversations_page.dart';
import '../pages/seacrh_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late double _height;
  late double _width;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 1,
    );

    _tabController.animation!.addListener(() {
      if (mounted) {
        setState(() {}); // Updates UI while swiping-
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "BanterHub",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          automaticIndicatorColorAdjustment: true,
          // dividerColor: Colors.red,
          // enableFeedback: true,
          // indicatorSize: TabBarIndicatorSize.tab,
          // labelColor: Colors.red,
          // unselectedLabelColor: Colors.grey[100]
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                _getIcon(0, Icons.people, Icons.people_outline),
                size: 30,
              ),
            ),
            Tab(
              icon: Icon(
                _getIcon(1, Icons.chat_bubble, Icons.chat_bubble_outline),
                size: 28,
              ),
            ),
            Tab(
              icon: Icon(
                _getIcon(2, Icons.person, Icons.person_outline),
                size: 30,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _tabBarPages(),
    );
  }

  IconData _getIcon(int tabIndex, IconData activeIcon, IconData inactiveIcon) {
    double selectedIndex = _tabController.index.toDouble();
    double animationValue = _tabController.animation!.value;

    return (animationValue.round() == tabIndex) ? activeIcon : inactiveIcon;
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SeacrhPage(height: _height, width: _width),
        RecentConversationsPage(height: _height, width: _width),
        ProfilePage(height: _height, width: _width),
        // ProfilePage(),
      ],
    );
  }
}
