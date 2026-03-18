import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/rating_badge.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Function(Place) onPlaceTap;

  const MapScreen({super.key, required this.onPlaceTap});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  Place? _selectedPlace;

  CameraPosition get _initialCamera {
    final loc = ref.read(locationProvider);
    return CameraPosition(
      target: LatLng(loc.latitude, loc.longitude),
      zoom: 14.5,
    );
  }

  Set<Marker> _buildMarkers(List<Place> places) {
    return places.map((place) {
      final pinColor = _pinColor(place);
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(pinColor),
        onTap: () {
          setState(() => _selectedPlace = place);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(place.latitude, place.longitude),
              15.5,
            ),
          );
        },
      );
    }).toSet();
  }

  double _pinColor(Place place) {
    if (place.rating >= 4.5) return BitmapDescriptor.hueGreen;
    if (place.rating >= 4.0) return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueRed;
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(filteredPlacesProvider);
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: ZuriColors.background,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (ctrl) => _mapController = ctrl,
            initialCameraPosition: _initialCamera,
            markers: _buildMarkers(places),
            myLocationEnabled: location.hasPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedPlace = null),
            style: _mapStyle,
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: ZuriColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: ZuriColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            color: ZuriColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${places.length} places nearby',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ZuriColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // My location button
                  GestureDetector(
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(location.latitude, location.longitude),
                          14.5,
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: ZuriColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: ZuriColors.cardShadow,
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: ZuriColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Legend
          Positioned(
            top: 80,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: ZuriColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: ZuriColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    _LegendDot(
                      color: ZuriColors.pinHighRated,
                      label: 'Highly rated',
                    ),
                    SizedBox(height: 6),
                    _LegendDot(color: ZuriColors.pinAverage, label: 'Average'),
                    SizedBox(height: 6),
                    _LegendDot(color: ZuriColors.pinBusy, label: 'Lower rated'),
                  ],
                ),
              ),
            ),
          ),
          // Bottom place preview card
          if (_selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _PlacePreviewCard(
                place: _selectedPlace!,
                userLat: location.latitude,
                userLng: location.longitude,
                onTap: () => widget.onPlaceTap(_selectedPlace!),
                onDismiss: () => setState(() => _selectedPlace = null),
              ),
            ),
          // Horizontal scrollable list at bottom
          if (_selectedPlace == null)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _MapPlacesList(
                places: places,
                userLat: location.latitude,
                userLng: location.longitude,
                onSelect: (p) {
                  setState(() => _selectedPlace = p);
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(p.latitude, p.longitude),
                      15.5,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ZuriColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PlacePreviewCard extends StatelessWidget {
  final Place place;
  final double userLat;
  final double userLng;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _PlacePreviewCard({
    required this.place,
    required this.userLat,
    required this.userLng,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZuriColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                place.images.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  color: ZuriColors.surfaceVariant,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: ZuriColors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.name, style: ZuriTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${place.category} · ${place.priceRange}',
                    style: ZuriTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RatingBadge(rating: place.rating),
                      const SizedBox(width: 8),
                      Text(
                        place.distanceLabel(userLat, userLng),
                        style: ZuriTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: ZuriColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: ZuriColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ZuriColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPlacesList extends StatelessWidget {
  final List<Place> places;
  final double userLat;
  final double userLng;
  final Function(Place) onSelect;

  const _MapPlacesList({
    required this.places,
    required this.userLat,
    required this.userLng,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: places.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final place = places[i];
          return GestureDetector(
            onTap: () => onSelect(place),
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ZuriColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: ZuriColors.cardShadow,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      place.images.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 50,
                        height: 50,
                        color: ZuriColors.surfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ZuriColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 11,
                              color: ZuriColors.ratingGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ZuriColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              place.distanceLabel(userLat, userLng),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: ZuriColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom map style (light, minimal)
const _mapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#f5f5f5"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#616161"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#f5f5f5"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#ffffff"}]},
  {"featureType": "road.arterial", "elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#dadada"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#c9c9c9"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#9e9e9e"}]}
]
''';
