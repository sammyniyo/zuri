import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mock_data.dart';
import '../models/review_model.dart';
import 'firestore_service.dart';

/// Seeds the Firestore database with initial data on first launch.
///
/// Usage (called once in main.dart after Firebase.initializeApp):
///   await DatabaseSeeder.seedIfEmpty();
///
/// The seeder checks if the 'places' collection is empty before writing.
/// If places already exist, it does nothing (safe to call every launch).
class DatabaseSeeder {
  DatabaseSeeder._();

  static final _db = FirebaseFirestore.instance;
  static final _fs = FirestoreService.instance;

  /// Seeds all 10 Kigali places if the Firestore collection is empty.
  /// Returns true if data was seeded, false if already populated.
  static Future<bool> seedIfEmpty() async {
    try {
      // Check if places already exist
      final snapshot = await _db.collection('places').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        // Database already has data — skip
        return false;
      }

      // Seed all places using a Firestore batch (atomic write)
      await _seedPlaces();
      await _seedReviews();

      return true;
    } catch (e) {
      // Seeding failed (offline / rules) — app still works with mock data
      return false;
    }
  }

  /// Force re-seed regardless of existing data (use in dev only).
  static Future<void> forceSeed() async {
    await _seedPlaces();
    await _seedReviews();
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static Future<void> _seedPlaces() async {
    // Write all places in a single batch for efficiency
    final batch = _db.batch();

    for (final place in MockData.places) {
      final ref = _db.collection('places').doc(place.id);
      batch.set(ref, {
        ...place.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'reviewCount': 0,
      });
    }

    await batch.commit();
  }

  static Future<void> _seedReviews() async {
    // Write sample reviews for places 1, 2, and 5
    for (final review in MockReviews.all) {
      await _fs.addReview(review);
    }
  }

  /// Check how many places are in Firestore.
  static Future<int> getPlaceCount() async {
    try {
      final snapshot = await _db.collection('places').count().get();
      return snapshot.count ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
