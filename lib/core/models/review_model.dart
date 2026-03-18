class Review {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating; // 1.0 – 5.0
  final String text;
  final List<String> images;
  final DateTime timestamp;

  const Review({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.text,
    this.images = const [],
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'placeId': placeId,
        'userId': userId,
        'userName': userName,
        'userAvatar': userAvatar,
        'rating': rating,
        'text': text,
        'images': images,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as String,
        placeId: map['placeId'] as String,
        userId: map['userId'] as String,
        userName: map['userName'] as String,
        userAvatar: map['userAvatar'] as String?,
        rating: (map['rating'] as num).toDouble(),
        text: map['text'] as String,
        images: List<String>.from(map['images'] as List? ?? []),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

// Mock reviews for demo
class MockReviews {
  static final List<Review> all = [
    Review(
      id: 'r1',
      placeId: '1',
      userId: 'u1',
      userName: 'Amina K.',
      rating: 5.0,
      text: 'Absolutely love this rooftop! The views of Kigali are stunning and the coffee is excellent. Perfect spot for morning meetings.',
      images: [
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400&q=80',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Review(
      id: 'r2',
      placeId: '1',
      userId: 'u2',
      userName: 'Jean-Paul M.',
      rating: 4.5,
      text: 'Great ambiance and friendly staff. The smoothies are worth every franc. Will definitely come back!',
      images: [],
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Review(
      id: 'r3',
      placeId: '2',
      userId: 'u3',
      userName: 'Sarah T.',
      rating: 5.0,
      text: 'Best pool in Kigali by far. The poolside service is amazing and the food is fresh. Totally worth the 15,000 RWF day pass.',
      images: [
        'https://images.unsplash.com/photo-1575429198097-0414ec08e8cd?w=400&q=80',
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&q=80',
      ],
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Review(
      id: 'r4',
      placeId: '5',
      userId: 'u4',
      userName: 'Eric N.',
      rating: 5.0,
      text: 'Heaven Restaurant lives up to its name. The terrace view at sunset is breathtaking and the food is exceptional. Highly recommend the grilled fish.',
      images: [],
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Review(
      id: 'r5',
      placeId: '5',
      userId: 'u5',
      userName: 'Claire B.',
      rating: 4.0,
      text: 'Amazing East African cuisine with a modern twist. The wine selection is impressive. Perfect for a special occasion.',
      images: [],
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static List<Review> forPlace(String placeId) =>
      all.where((r) => r.placeId == placeId).toList();
}
