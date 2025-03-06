// lib/managers/rating_manager_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RatingManagerFirestore {
  static ValueNotifier<List<Map<String, dynamic>>> ratingsNotifier =
  ValueNotifier([]);

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static void initialize() {
    final user = _auth.currentUser;
    if (user == null) {
      ratingsNotifier.value = [];
      return;
    }

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('ratings')
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs.map((doc) => doc.data()).toList();
      ratingsNotifier.value = List<Map<String, dynamic>>.from(items);
    }, onError: (error) {
      ratingsNotifier.value = [];
    });
  }

  static Future<void> setRating(
      int id,
      String mediaType,
      double rating,
      String title,
      String? posterPath,
      ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratings')
          .doc(id.toString())
          .set({
        'id': id,
        'mediaType': mediaType,
        'rating': rating,
        'title': title,
        'poster_path': posterPath,
      });
    } catch (e) {
      debugPrint("Set rating error: $e");
    }
  }

  static double getRating(int id) {
    final found = ratingsNotifier.value.firstWhere(
          (r) => r['id'] == id,
      orElse: () => {},
    );
    return found.isNotEmpty ? (found['rating'] ?? 0.0) : 0.0;
  }

  static Future<void> removeRating(int id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratings')
          .doc(id.toString())
          .delete();
    } catch (e) {
      debugPrint("Remove rating error: $e");
    }
  }
}
