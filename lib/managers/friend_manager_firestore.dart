// lib/managers/friend_manager_firestore.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FriendManagerFirestore {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Search for user by exact nickname
  static Future<List<Map<String, dynamic>>> searchUserByNickname(String nickname) async {
    if (nickname.isEmpty) return [];
    final snapshot = await _firestore
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();

    // Return a list of users
    return snapshot.docs.map((doc) {
      return {
        'uid': doc.id,
        'nickname': doc['nickname'] ?? '',
      };
    }).toList();
  }

  /// Send friend request to [targetUserUid].
  static Future<void> sendFriendRequest(String targetUserUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final senderUid = currentUser.uid;

    // Write request to target user's friendRequests subcollection
    await _firestore
        .collection('users')
        .doc(targetUserUid)
        .collection('friendRequests')
        .doc(senderUid)
        .set({
      'senderUid': senderUid,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get the stream of incoming friend requests for current user
  static Stream<List<Map<String, dynamic>>> getIncomingRequestsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'requestDocId': doc.id,
          'senderUid': data['senderUid'],
          'status': data['status'],
        };
      }).toList();
    });
  }

  static Future<void> acceptFriendRequest(String senderUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final myUid = currentUser.uid;


    await _firestore
        .collection('users')
        .doc(myUid)
        .collection('friendRequests')
        .doc(senderUid)
        .update({'status': 'accepted'});



    await _firestore
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .doc(senderUid)
        .set({'friendUid': senderUid});

    //    - In the sender's doc
    await _firestore
        .collection('users')
        .doc(senderUid)
        .collection('friends')
        .doc(myUid)
        .set({'friendUid': myUid});
  }

  /// Reject the friend request from [senderUid].
  /// - set "status" to "rejected" or just delete
  static Future<void> rejectFriendRequest(String senderUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final myUid = currentUser.uid;

    // Just remove or mark as rejected
    await _firestore
        .collection('users')
        .doc(myUid)
        .collection('friendRequests')
        .doc(senderUid)
        .update({'status': 'rejected'});
  }

  /// Stream the list of accepted friends of current user
  static Stream<List<String>> getFriendsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friends')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList(); // friendUid list
    });
  }

  // Check if current user is friend with a given userId
  static Future<bool> isFriend(String otherUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final myUid = currentUser.uid;

    final doc = await _firestore
        .collection('users')
        .doc(myUid)
        .collection('friends')
        .doc(otherUid)
        .get();

    return doc.exists;
  }
}
