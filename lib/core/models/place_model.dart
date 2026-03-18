import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String category;
  final double rating;
  final String priceRange; // $, $$, $$$
  final Map<String, int> priceDetails; // RWF prices
  final double latitude;
  final double longitude;
  final List<String> images;
  final Map<String, String> openingHours; // {'Monday': '8:00 AM - 10:00 PM'}
  final String description;
  final String address;
  final String? phone;
  final String? website;
  final WaitStatus waitStatus;
  final int? estimatedWaitMinutes;
  final List<String> tags;
  final bool isOpen;
  final bool isFeatured;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.priceRange,
    required this.priceDetails,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.openingHours,
    required this.description,
    required this.address,
    this.phone,
    this.website,
    this.waitStatus = WaitStatus.unknown,
    this.estimatedWaitMinutes,
    this.tags = const [],
    this.isOpen = true,
    this.isFeatured = false,
  });

  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRad(latitude - lat);
    final double dLng = _toRad(longitude - lng);
    final double a =
        _sin2(dLat / 2) +
        _cos(_toRad(lat)) * _cos(_toRad(latitude)) * _sin2(dLng / 2);
    final double c = 2 * _asin(_sqrt(a));
    return earthRadius * c;
  }

  double _toRad(double deg) => deg * 3.14159265358979 / 180;
  double _sin2(double x) => _sin(x) * _sin(x);
  double _sin(double x) {
    // Simple approximation for small angles is fine for display purposes
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _asin(double x) => x + (x * x * x) / 6;
  double _sqrt(double x) {
    if (x <= 0) return 0;
    double result = x;
    for (int i = 0; i < 10; i++) {
      result = (result + x / result) / 2;
    }
    return result;
  }

  String walkingTimeFrom(double lat, double lng) {
    final distMeters = distanceTo(lat, lng);
    final minutes = (distMeters / 83.33).round(); // avg walk 5km/h = 83m/min
    if (minutes < 1) return '< 1 min walk';
    if (minutes < 60) return '$minutes min walk';
    final hours = (minutes / 60).floor();
    final mins = minutes % 60;
    return '${hours}h ${mins}m walk';
  }

  String distanceLabel(double lat, double lng) {
    final distMeters = distanceTo(lat, lng);
    if (distMeters < 1000) {
      return '${distMeters.round()}m away';
    } else {
      return '${(distMeters / 1000).toStringAsFixed(1)}km away';
    }
  }

  Place copyWith({
    String? id,
    String? name,
    String? category,
    double? rating,
    String? priceRange,
    Map<String, int>? priceDetails,
    double? latitude,
    double? longitude,
    List<String>? images,
    Map<String, String>? openingHours,
    String? description,
    String? address,
    String? phone,
    String? website,
    WaitStatus? waitStatus,
    int? estimatedWaitMinutes,
    List<String>? tags,
    bool? isOpen,
    bool? isFeatured,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      priceRange: priceRange ?? this.priceRange,
      priceDetails: priceDetails ?? this.priceDetails,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      waitStatus: waitStatus ?? this.waitStatus,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      tags: tags ?? this.tags,
      isOpen: isOpen ?? this.isOpen,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  /// Serialize to a plain map for writing to Firestore
  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'rating': rating,
        'priceRange': priceRange,
        'priceDetails': priceDetails,
        'latitude': latitude,
        'longitude': longitude,
        'images': images,
        'openingHours': openingHours,
        'description': description,
        'address': address,
        'phone': phone,
        'website': website,
        'waitStatus': waitStatus.index,
        'estimatedWaitMinutes': estimatedWaitMinutes,
        'tags': tags,
        'isOpen': isOpen,
        'isFeatured': isFeatured,
      };

  factory Place.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      priceRange: data['priceRange'] ?? '',
      priceDetails: Map<String, int>.from(data['priceDetails'] ?? {}),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      openingHours: Map<String, String>.from(data['openingHours'] ?? {}),
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'],
      website: data['website'],
      waitStatus: WaitStatus.values[data['waitStatus'] ?? 3],
      estimatedWaitMinutes: data['estimatedWaitMinutes'],
      tags: List<String>.from(data['tags'] ?? []),
      isOpen: data['isOpen'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
    );
  }
}

enum WaitStatus { low, medium, high, unknown }

class FilterOptions {
  final String category;
  final double? maxPrice; // 1=$ 2=$$ 3=$$$
  final double? maxDistanceKm;
  final double? minRating;
  final bool openNow;
  final String sortBy; // 'distance', 'rating', 'price'

  const FilterOptions({
    this.category = 'All',
    this.maxPrice,
    this.maxDistanceKm,
    this.minRating,
    this.openNow = false,
    this.sortBy = 'distance',
  });

  FilterOptions copyWith({
    String? category,
    double? maxPrice,
    double? maxDistanceKm,
    double? minRating,
    bool? openNow,
    String? sortBy,
  }) {
    return FilterOptions(
      category: category ?? this.category,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      minRating: minRating ?? this.minRating,
      openNow: openNow ?? this.openNow,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      category != 'All' ||
      maxPrice != null ||
      maxDistanceKm != null ||
      minRating != null ||
      openNow;
}
