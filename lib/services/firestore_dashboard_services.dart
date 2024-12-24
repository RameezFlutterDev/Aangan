import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDashboardServices {
  Stream<List<Map<String, dynamic>>> getAllGamesStream() {
    return FirebaseFirestore.instance.collection('games').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .where((data) =>
                  data['status'] == "Active" || !data.containsKey('status'))
              .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> searchGames(String query) {
    return FirebaseFirestore.instance
        .collection('games')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .where((game) => (game['title'] ?? '')
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }
}
