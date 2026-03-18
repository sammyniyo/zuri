class AppConstants {
  AppConstants._();

  static const String appName = 'ZURI';
  static const String appTagline = 'Discover the best places around you';

  // Default location (Kigali, Rwanda)
  static const double defaultLatitude = -1.9441;
  static const double defaultLongitude = 30.0619;

  // Distances in meters
  static const double nearbyRadius = 5000; // 5 km

  // Animation durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration longDuration = Duration(milliseconds: 600);

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keySavedPlaces = 'saved_places';

  // Currency
  static const String currency = 'RWF';
}

class PlaceCategories {
  PlaceCategories._();

  static const List<String> all = [
    'All',
    'Restaurants',
    'Cafes',
    'Pools',
    'Nightlife',
    'Hotels',
    'Gyms',
    'Tourist Spots',
    'Quick Bite',
    'Budget',
  ];

  static const Map<String, String> icons = {
    'All': '🌍',
    'Restaurants': '🍽️',
    'Cafes': '☕',
    'Pools': '🏊',
    'Nightlife': '🎵',
    'Hotels': '🏨',
    'Gyms': '💪',
    'Tourist Spots': '📸',
    'Quick Bite': '⚡',
    'Budget': '💰',
  };
}
