import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';

/// Central Firestore data access layer.
/// All database reads and writes go through this service.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _places =>
      _db.collection('places');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> _reviews(String placeId) =>
      _places.doc(placeId).collection('reviews');

  // ══════════════════════════════════════════════════════════════════════════
  // PLACES
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch all places ordered by rating descending.
  /// Falls back to an empty list on error.
  Future<List<Place>> getPlaces() async {
    try {
      final snapshot =
          await _places.orderBy('rating', descending: true).get();
      return snapshot.docs.map(Place.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch a single place by ID.
  Future<Place?> getPlace(String placeId) async {
    try {
      final doc = await _places.doc(placeId).get();
      if (!doc.exists) return null;
      return Place.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// Fetch all featured places.
  Future<List<Place>> getFeaturedPlaces() async {
    try {
      final snapshot = await _places
          .where('isFeatured', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();
      return snapshot.docs.map(Place.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  /// Fetch places by category.
  Future<List<Place>> getPlacesByCategory(String category) async {
    try {
      final snapshot = await _places
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .get();
      return snapshot.docs.map(Place.fromFirestore).toList();
    } catch (e) {
      return [];
    }
  }

  /// Write a place to Firestore (used by seeder / admin).
  Future<void> setPlace(Place place) async {
    await _places.doc(place.id).set(place.toMap());
  }

  /// Update a place's wait status in real time.
  Future<void> updateWaitStatus(
    String placeId,
    WaitStatus status,
    int? estimatedMinutes,
  ) async {
    await _places.doc(placeId).update({
      'waitStatus': status.index,
      'estimatedWaitMinutes': estimatedMinutes,
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch a user document by UID.
  Future<ZuriUser?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return ZuriUser.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Create or overwrite a user document.
  Future<void> setUser(ZuriUser user) async {
    await _users.doc(user.id).set(user.toMap());
  }

  /// Partially update user fields.
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    await _users.doc(uid).update(fields);
  }

  /// Toggle a saved place in the user's savedPlaces array.
  Future<void> toggleSavedPlace(String uid, String placeId, bool saved) async {
    await _users.doc(uid).update({
      'savedPlaces': saved
          ? FieldValue.arrayUnion([placeId])
          : FieldValue.arrayRemove([placeId]),
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REVIEWS
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch all reviews for a place, newest first.
  Future<List<Review>> getReviews(String placeId) async {
    try {
      final snapshot = await _reviews(placeId)
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        if (data['timestamp'] is Timestamp) {
          data['timestamp'] =
              (data['timestamp'] as Timestamp).toDate().toIso8601String();
        }
        return Review.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a review and update the place's aggregate rating.
  Future<void> addReview(Review review) async {
    final batch = _db.batch();

    // Write review document
    final reviewRef = _reviews(review.placeId).doc(review.id);
    final reviewData = review.toMap();
    reviewData['timestamp'] = FieldValue.serverTimestamp();
    batch.set(reviewRef, reviewData);

    // Increment place review count
    final placeRef = _places.doc(review.placeId);
    batch.update(placeRef, {
      'reviewCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REAL-TIME STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Live stream of reviews for a place (updates without refresh).
  Stream<List<Review>> reviewsStream(String placeId) {
    return _reviews(placeId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data());
              data['id'] = doc.id;
              if (data['timestamp'] is Timestamp) {
                data['timestamp'] =
                    (data['timestamp'] as Timestamp).toDate().toIso8601String();
              }
              return Review.fromMap(data);
            }).toList());
  }

  /// Live stream of a single place document (for real-time wait status).
  Stream<Place?> placeStream(String placeId) {
    return _places.doc(placeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Place.fromFirestore(doc);
    });
  }
}
