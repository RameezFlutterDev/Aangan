import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:xupstore/views/Favourites/favourite_games.dart';
import 'package:xupstore/views/dashboard.dart';

class Homepage extends StatefulWidget {
  final String userid;
  const Homepage({required this.userid, super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    int selectedIndex = 1; // Track the selected tab index
    final PageController pageController = PageController();

    final List<Widget> pages = [
      Dashboard(
        userid: widget.userid,
      ),
      Dashboard(
        userid: widget.userid,
      ),
      FavouriteGames(
        userid: widget.userid,
      ),
    ];
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: const Color(0xff6d72ea),
        height: 50,
        initialActiveIndex: selectedIndex,
        items: const [
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.favorite_outline),
        ],
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
          pageController.jumpToPage(index); // Navigate to the selected page
        },
      ),
      body: PageView(
        controller: pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Disable swiping between pages
        children: pages,
      ),
    );
  }
}
