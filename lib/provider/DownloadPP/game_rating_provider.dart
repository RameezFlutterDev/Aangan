import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double averageRating = 0.0;
  int reviewCount = 0;
  bool isLoading = false;
  double _rated = 0.0;

  double get rated => _rated;

  Future<void> fetchRatingAndReviewCount(String gameId) async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) {
        averageRating = 0.0;
        reviewCount = 0;
      } else {
        double totalRating = snapshot.docs.fold(0.0, (sum, doc) {
          final data = doc.data() as Map<String, dynamic>;
          final rating = (data['rating'] ?? 0.0) as double;
          return sum + rating;
        });

        averageRating = totalRating / snapshot.docs.length;
        reviewCount = snapshot.docs.length;
        await _firestore
            .collection('games')
            .doc(gameId)
            .update({"rating": averageRating});
      }
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  void updateRating(double rating) {
    _rated = rating;
    notifyListeners(); // Notify listeners to update the UI
  }
}
