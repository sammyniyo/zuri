import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../models/mock_data.dart';
import '../constants/app_constants.dart';

// ─── Location ───────────────────────────────────────────────────────────────
class LocationState {
  final double latitude;
  final double longitude;
  final bool hasPermission;
  final bool isLoading;

  const LocationState({
    this.latitude = AppConstants.defaultLatitude,
    this.longitude = AppConstants.defaultLongitude,
    this.hasPermission = false,
    this.isLoading = false,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? hasPermission,
    bool? isLoading,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  void setLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng, hasPermission: true);
  }

  void setPermission(bool granted) {
    state = state.copyWith(hasPermission: granted);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) => LocationNotifier(),
);

// ─── Filter ──────────────────────────────────────────────────────────────────
class FilterNotifier extends StateNotifier<FilterOptions> {
  FilterNotifier() : super(const FilterOptions());

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setMaxDistance(double? km) {
    state = state.copyWith(maxDistanceKm: km);
  }

  void setMinRating(double? rating) {
    state = state.copyWith(minRating: rating);
  }

  void setOpenNow(bool openNow) {
    state = state.copyWith(openNow: openNow);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = const FilterOptions();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterOptions>(
  (ref) => FilterNotifier(),
);

// ─── Places ──────────────────────────────────────────────────────────────────
final allPlacesProvider = FutureProvider<List<Place>>(
  (ref) => MockData.fetchPlaces(),
);

final filteredPlacesProvider = Provider<List<Place>>((ref) {
  final filter = ref.watch(filterProvider);
  final location = ref.watch(locationProvider);
  final allPlacesAsync = ref.watch(allPlacesProvider);

  return allPlacesAsync.maybeWhen(
    data: (places) => _filterAndSortPlaces(places, filter, location),
    orElse: () => [],
  );
});

List<Place> _filterAndSortPlaces(
  List<Place> places,
  FilterOptions filter,
  LocationState location,
) {
  var result = places.where((place) {
    if (filter.category != 'All' && place.category != filter.category) {
      return false;
    }
    if (filter.openNow && !place.isOpen) return false;
    if (filter.minRating != null && place.rating < filter.minRating!) {
      return false;
    }
    if (filter.maxDistanceKm != null) {
      final distKm =
          place.distanceTo(location.latitude, location.longitude) / 1000;
      if (distKm > filter.maxDistanceKm!) return false;
    }
    return true;
  }).toList();

  result.sort((a, b) {
    switch (filter.sortBy) {
      case 'rating':
        return b.rating.compareTo(a.rating);
      case 'price':
        return a.priceRange.length.compareTo(b.priceRange.length);
      default: // distance
        final distA = a.distanceTo(location.latitude, location.longitude);
        final distB = b.distanceTo(location.latitude, location.longitude);
        return distA.compareTo(distB);
    }
  });

  return result;
}

final featuredPlacesProvider = Provider<List<Place>>((ref) {
  final allPlacesAsync = ref.watch(allPlacesProvider);
  return allPlacesAsync.maybeWhen(
    data: (places) => places.where((p) => p.isFeatured).toList(),
    orElse: () => [],
  );
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<List<Place>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return [];
  final allPlacesAsync = ref.watch(allPlacesProvider);
  return allPlacesAsync.maybeWhen(
    data: (places) => places.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.tags.any((t) => t.toLowerCase().contains(query));
    }).toList(),
    orElse: () => [],
  );
});

// ─── Saved places ─────────────────────────────────────────────────────────
class SavedPlacesNotifier extends StateNotifier<Set<String>> {
  SavedPlacesNotifier() : super({});

  void toggle(String placeId) {
    if (state.contains(placeId)) {
      state = {...state}..remove(placeId);
    } else {
      state = {...state, placeId};
    }
  }

  bool isSaved(String placeId) => state.contains(placeId);
}

final savedPlacesProvider =
    StateNotifierProvider<SavedPlacesNotifier, Set<String>>(
      (ref) => SavedPlacesNotifier(),
    );

final savedPlaceListProvider = Provider<List<Place>>((ref) {
  final savedIds = ref.watch(savedPlacesProvider);
  final allPlacesAsync = ref.watch(allPlacesProvider);
  return allPlacesAsync.maybeWhen(
    data: (places) => places.where((p) => savedIds.contains(p.id)).toList(),
    orElse: () => [],
  );
});

// ─── Selected place ──────────────────────────────────────────────────────────
final selectedPlaceProvider = StateProvider<Place?>((ref) => null);

// ─── Bottom nav index ────────────────────────────────────────────────────────
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
