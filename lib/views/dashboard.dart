import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:xupstore/models/games.dart';
import 'package:xupstore/provider/DownloadPP/search_game_provider.dart';
import 'package:xupstore/services/firestore_dashboard_services.dart';
import 'package:xupstore/views/Developer/dev_profile.dart';

import 'package:xupstore/views/Developer/uploadGame.dart';
import 'package:xupstore/views/Favourites/favourite_games.dart';
import 'package:xupstore/views/HelpCenter/help_center_screen.dart';
import 'package:xupstore/views/User/user_profile.dart';
import 'package:xupstore/views/downloadpage.dart';

class Dashboard extends StatefulWidget {
  final String userid;
  const Dashboard({super.key, required this.userid});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> games = [];
  bool isLoading = true; // Flag to show loading state
  FirestoreDashboardServices firestoreServices = FirestoreDashboardServices();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // fetchAllGames();
  }

  // Future<void> fetchAllGames() async {

  //   games = await firestoreServices.getAllGames();
  //   setState(() {
  //     isLoading = false; // Update loading state
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xff6d72ea),
                ),
                child: Text(
                  'XUP Store',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.gamepad),
                title: const Text('Upload'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Uploadgame(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Add your onTap logic here
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Be a Developer '),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DevProfile(),
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help Center '),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ));
                },
              ),
            ],
          ),
        ),
        // bottomNavigationBar: ConvexAppBar(
        //   backgroundColor: Color(0xff6d72ea),
        //   height: 50,
        //   initialActiveIndex: 1,
        //   items: [
        //     TabItem(icon: Icons.home),
        //     TabItem(icon: Icons.add),
        //     TabItem(icon: Icons.favorite_outline),
        //   ],
        //   onTap: (int i) {
        //     if (i == 2) {
        //       setState(() {
        //         i = 1;
        //       });

        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => FavouriteGames(),
        //           ));
        //     }
        //   },
        // ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.segment, size: 28),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfileScreen(
                                  userId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ));
                        },
                        child: CircleAvatar(
                            radius: 20,
                            child: ClipOval(
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade700,
                              ),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        print(_searchController.text);
                        // Update the search query in the GameProvider
                        Provider.of<GameProvider>(context, listen: false)
                            .updateSearchQuery(value);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Game Download Card
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xffe0d910),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior:
                          Clip.none, // Allow the icon to overflow the container
                      // alignment:
                      //     Alignment.topCenter, // Aligns the icon at the top center
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical:
                                  40), // Adjust vertical padding to accommodate the icon
                          child: Column(
                            children: [
                              // Text Message
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Let's download\na game\nto start",
                                  // Center the text
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Game Icon
                        Positioned(
                          top: -140, // Move it up to overlap the container more
                          right: -10, // Adjust the position of the icon
                          child: Container(
                            width: 140,
                            height: 350,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/image.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Popular",
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff262635)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 120, // Fixed height for the horizontal list
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: firestoreServices.getAllGamesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        // Data is available
                        final games = snapshot.data ?? [];

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DownloadPage(
                                        game: game,
                                        userid: widget.userid,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 120, // Fixed width for each item
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    elevation: 5,
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Hero(
                                            tag: 'img-${game['gameid']}',
                                            child: Image.network(
                                              game['gameImagesList'][0],
                                              fit: BoxFit.cover,
                                              height: 63,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                game['title'] ?? 'No Title',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star,
                                                      size: 11,
                                                      color: Color(0xffe0d910)),
                                                  Text(
                                                    (game['rating'] != null
                                                        ? (double.tryParse(game[
                                                                        'rating']
                                                                    .toString())
                                                                ?.toStringAsFixed(
                                                                    1) ??
                                                            '0')
                                                        : '0'),
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 11),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "All Games",
                      style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff262635)),
                    ),
                  ),

                  Container(
                    // height: 195, // Fixed height for the grid
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: firestoreServices.getAllGamesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        // Data is available
                        final games = snapshot.data ?? [];

                        return GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const BouncingScrollPhysics(), // Disable scrolling
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 2 items per row
                            crossAxisSpacing: 4, // Space between columns
                            mainAxisSpacing: 4, // Space between rows
                            childAspectRatio:
                                1, // Adjust the aspect ratio of each grid item
                          ),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DownloadPage(
                                      game: game,
                                      userid: widget.userid,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 5,
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: Hero(
                                        tag: 'img-${game['gameid']}',
                                        child: Image.network(
                                          game['gameImagesList'][0],
                                          fit: BoxFit.cover,
                                          height: 60,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            game['title'] ?? 'No Title',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  size: 9,
                                                  color: Color(0xffe0d910)),
                                              Text(
                                                (game['rating'] != null
                                                    ? (double.tryParse(
                                                                game['rating']
                                                                    .toString())
                                                            ?.toStringAsFixed(
                                                                1) ??
                                                        '0')
                                                    : '0'),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 9),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),

          // Positioned(
          //   top: 140,
          //   left: 20,
          //   right: 20,
          //   child:
          //    _searchController.text.isEmpty
          //       ?
          // Container(
          //   height: MediaQuery.of(context).size.height * 0.4,
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.9),
          //     borderRadius: BorderRadius.circular(15),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.1),
          //         blurRadius: 10,
          //         spreadRadius: 2,
          //       ),
          //     ],
          //   ),
          // ),
          Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              final games = gameProvider.games;
              final isLoading = gameProvider.isLoading;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (games.isEmpty) {
                return const Center(child: Text('No games found.'));
              }

              return Positioned(
                  top: 160,
                  left: 20,
                  right: 20,
                  child: _searchController.text.isNotEmpty
                      ? Container(
                          // height: MediaQuery.of(context).size.height * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: games.length,
                            itemBuilder: (context, index) {
                              final game = games[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DownloadPage(
                                          game: game,
                                          userid: widget.userid,
                                        ),
                                      ));
                                },
                                child: ListTile(
                                  leading: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: game['gameImagesList'] != null &&
                                            game['gameImagesList'].isNotEmpty
                                        ? Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            clipBehavior: Clip
                                                .antiAlias, // Ensures the image is clipped to the circle
                                            child: Image.network(
                                              game['gameImagesList'][0],
                                              fit: BoxFit
                                                  .cover, // Ensures the image fits within the circle
                                            ),
                                          )
                                        : const Icon(Icons.image_not_supported,
                                            size:
                                                30), // Icon size matches the space
                                  ),
                                  title: Text(game['title'] ?? 'Untitled'),
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink());
            },
          ),

          // : SizedBox
          //     .shrink(), // Placeholder widget when _searchController is empty
          // ),

          // Returns an empty widget if searchQuery is empty
        ]));
  }
}
