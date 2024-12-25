import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xupstore/services/firestore_favourite_games_services.dart';
import 'package:xupstore/views/downloadpage.dart';

class FavouriteGames extends StatelessWidget {
  final String userid;
  FavouriteGames({super.key, required this.userid});

  FirestoreFavouriteGamesServices firestoreFavouriteGamesServices =
      FirestoreFavouriteGamesServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            Text(
              "Favorites",
              style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff262635)),
            ),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream:
                  firestoreFavouriteGamesServices.fetchFavoriteGames(userid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final games = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadPage(
                              game: game,
                              userid: userid,
                            ),
                          )),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          height: MediaQuery.sizeOf(context).height * 0.20,
                          width: MediaQuery.sizeOf(context).width * 0.40,
                          child: Image.network(
                            game['gameImagesList'][0],
                            fit: BoxFit.cover,
                          ),
                        ),

                        title: Text(
                          game['title'],
                          style: GoogleFonts.poppins(),
                        ),
                        subtitle: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xffe0d910),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              (game['rating']?.toDouble() ?? 0.0)
                                  .toStringAsFixed(
                                      1), // Restricts to 1 decimal place
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // subtitle: Text(game['genre']),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
