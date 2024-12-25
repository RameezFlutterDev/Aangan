import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDownloadpageServices {
  Future<void> addReview({
    required String gameId,
    required double rating,
    required String reviewText,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Fetch the username from the `users` collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String username = userDoc['username'] ?? 'Anonymous';

        // Reference to the specific game document's reviews subcollection
        final reviewRef = FirebaseFirestore.instance
            .collection('games')
            .doc(gameId)
            .collection('reviews')
            .doc();

        // Data to store in the review
        final reviewData = {
          'userId': user.uid,
          'username': username,
          'rating': rating,
          'reviewText': reviewText,
          'date': Timestamp.now(),
          'helpfulCount': 0,
        };

        // Add the review data to Firestore
        await reviewRef.set(reviewData);

        print("Review added successfully!");
      } catch (e) {
        print("Failed to add review: $e");
      }
    } else {
      print("No user is signed in.");
    }
  }

  Stream<List<Map<String, dynamic>>> getReviewsStream(String gameId) {
    return FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, dynamic>> getAverageRatingAndReviewCount(String gameId) {
    return FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return {"averageRating": 0.0, "reviewCount": 0}; // No reviews case
      }

      double totalRating = snapshot.docs.fold(0.0, (sum, doc) {
        final data = doc.data();
        final rating = (data['rating'] ?? 0.0) as double;
        return sum + rating;
      });

      double averageRating = totalRating / snapshot.docs.length;
      int reviewCount = snapshot.docs.length;

      return {"averageRating": averageRating, "reviewCount": reviewCount};
    });
  }
}
