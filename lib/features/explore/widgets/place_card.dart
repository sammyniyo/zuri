import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/place_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/wait_time_badge.dart';

class PlaceCard extends ConsumerWidget {
  final Place place;
  final VoidCallback onTap;
  final double userLat;
  final double userLng;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(
      savedPlacesProvider.select((s) => s.contains(place.id)),
    );
    final distLabel = place.distanceLabel(userLat, userLng);
    final walkTime = place.walkingTimeFrom(userLat, userLng);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: ZuriColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ZuriColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  // Hero image
                  Hero(
                    tag: 'place_image_${place.id}',
                    child: CachedNetworkImage(
                      imageUrl: place.images.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 200,
                        color: ZuriColors.shimmerBase,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ZuriColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 200,
                        color: ZuriColors.surfaceVariant,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: ZuriColors.textTertiary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Top badges row
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            place.category,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Save button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(savedPlacesProvider.notifier)
                                .toggle(place.id);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_outline_rounded,
                              size: 18,
                              color: isSaved
                                  ? ZuriColors.secondary
                                  : ZuriColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom left: rating
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: RatingBadge(rating: place.rating),
                  ),
                  // Bottom right: wait time
                  if (place.waitStatus != WaitStatus.unknown)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: WaitTimeBadge(
                        status: place.waitStatus,
                        minutes: place.estimatedWaitMinutes,
                        compact: true,
                      ),
                    ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: ZuriTextStyles.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PriceRangeBadge(priceRange: place.priceRange),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: ZuriColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(distLabel, style: ZuriTextStyles.labelSmall),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: ZuriColors.textTertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.directions_walk_rounded,
                        size: 14,
                        color: ZuriColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(walkTime, style: ZuriTextStyles.labelSmall),
                      const Spacer(),
                      OpenStatusBadge(isOpen: place.isOpen),
                    ],
                  ),
                  if (place.priceDetails.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    // Show first 2 price items in RWF
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: place.priceDetails.entries
                          .take(2)
                          .map(
                            (e) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ZuriColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${e.key}: ${_formatRwf(e.value)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: ZuriColors.primaryDark,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRwf(int amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}k RWF';
    }
    return '$amount RWF';
  }
}
