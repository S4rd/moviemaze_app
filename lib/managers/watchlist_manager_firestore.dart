// lib/managers/watchlist_manager_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WatchlistManagerFirestore {
  static ValueNotifier<List<Map<String, dynamic>>> watchlistNotifier =
  ValueNotifier([]);

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static void initialize() {
    final user = _auth.currentUser;
    if (user == null) {
      watchlistNotifier.value = [];
      return;
    }

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .snapshots()
        .listen((snapshot) {
      final items = snapshot.docs.map((doc) => doc.data()).toList();
      watchlistNotifier.value = List<Map<String, dynamic>>.from(items);
    }, onError: (error) {
      watchlistNotifier.value = [];
    });
  }

  static Future<void> addToWatchlist(Map<String, dynamic> item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(item['id'].toString())
          .set(item);
    } catch (e) {
      debugPrint("Add to watchlist error: $e");
    }
  }


// Add this static method to fetch watchlist of a specific user once.
// It's a "once" get, not a stream. We do minimal code.

  static Future<List<Map<String, dynamic>>> getUserWatchlistOnce(String userUid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userUid)
          .collection('watchlist')
          .get();

      final items = snapshot.docs.map((doc) => doc.data()).toList();
      return List<Map<String, dynamic>>.from(items);
    } catch (e) {
      debugPrint("getUserWatchlistOnce error: $e");
      return [];
    }
  }


  static Future<void> removeFromWatchlist(int id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlist')
          .doc(id.toString())
          .delete();
    } catch (e) {
      debugPrint("Remove from watchlist error: $e");
    }
  }

  static bool isInWatchlist(int id) {
    return watchlistNotifier.value.any((w) => w['id'] == id);
  }
}
