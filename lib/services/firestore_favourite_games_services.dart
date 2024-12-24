import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreFavouriteGamesServices {
  Future<void> addFavorite(String userId, String gameId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    await userDoc.update({
      'favorites': FieldValue.arrayUnion([gameId]) // Add game ID to the list
    });
  }

  Future<void> removeFavorite(String userId, String gameId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    await userDoc.update({
      'favorites':
          FieldValue.arrayRemove([gameId]) // Remove game ID from the list
    });
  }

  Stream<List<Map<String, dynamic>>> fetchFavoriteGames(String userId) {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    return userDoc.snapshots().asyncMap((doc) async {
      final favoriteGameIds = List<String>.from(doc.data()?['favorites'] ?? []);

      final games = await Future.wait(
        favoriteGameIds.map((gameId) async {
          final gameDoc = await FirebaseFirestore.instance
              .collection('games')
              .doc(gameId)
              .get();
          return gameDoc.data(); // This could return null
        }),
      );

      // Filter out null values to ensure non-nullable data
      return games.whereType<Map<String, dynamic>>().toList();
    });
  }
}
