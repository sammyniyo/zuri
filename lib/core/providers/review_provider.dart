import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/review_model.dart';

// ─── Per-place Reviews Notifier ───────────────────────────────────────────────
class ReviewNotifier extends StateNotifier<List<Review>> {
  final String placeId;
  final _firestore = FirebaseFirestore.instance;

  ReviewNotifier(this.placeId) : super([]) {
    _loadReviews();
  }

  /// Fetch reviews from Firestore, fallback to mock data if empty / offline
  Future<void> _loadReviews() async {
    try {
      final snapshot = await _firestore
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        state = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          // Convert Firestore Timestamp → ISO8601 String for Review.fromMap
          if (data['timestamp'] is Timestamp) {
            data['timestamp'] =
                (data['timestamp'] as Timestamp).toDate().toIso8601String();
          }
          return Review.fromMap(data);
        }).toList();
      } else {
        // No Firestore data yet — show mock reviews so the UI isn't empty
        state = MockReviews.forPlace(placeId);
      }
    } catch (_) {
      // Offline or Firestore rules not set — use mock data
      state = MockReviews.forPlace(placeId);
    }
  }

  /// Add a review: optimistic local update + persist to Firestore
  Future<void> addReview({
    required String userId,
    required String userName,
    String? userAvatar,
    required double rating,
    required String text,
    List<String> images = const [],
  }) async {
    final review = Review(
      id: const Uuid().v4(),
      placeId: placeId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      text: text,
      images: images,
      timestamp: DateTime.now(),
    );

    // Optimistic UI update — show immediately
    state = [review, ...state];

    // Persist to Firestore
    try {
      final data = review.toMap();
      // Use server timestamp for accuracy
      data['timestamp'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .doc(review.id)
          .set(data);
    } catch (_) {
      // Review stays in local state even if Firestore write fails
    }
  }

  double get averageRating {
    if (state.isEmpty) return 0;
    final sum = state.fold<double>(0, (acc, r) => acc + r.rating);
    return sum / state.length;
  }

  Map<int, int> get ratingDistribution {
    final dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in state) {
      final key = r.rating.round().clamp(1, 5);
      dist[key] = (dist[key] ?? 0) + 1;
    }
    return dist;
  }
}

// Family provider — one independent notifier per placeId
final reviewProvider =
    StateNotifierProvider.family<ReviewNotifier, List<Review>, String>(
  (ref, placeId) => ReviewNotifier(placeId),
);
