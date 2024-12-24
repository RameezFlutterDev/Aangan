import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProfilepageServices {
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No user document found for this ID");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(
      String userId, String? username, String? avatarUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        if (username != null) 'username': username,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
      print("Profile updated successfully");
    } catch (e) {
      print("Error updating profile: $e");
    }
  }
}
