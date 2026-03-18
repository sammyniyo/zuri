import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/place_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/rating_badge.dart';

class FeaturedSection extends ConsumerWidget {
  final Function(Place) onPlaceTap;
  final double userLat;
  final double userLng;

  const FeaturedSection({
    super.key,
    required this.onPlaceTap,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredPlacesProvider);
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('✨ Featured', style: ZuriTextStyles.headlineMedium),
              Text(
                'See all',
                style: ZuriTextStyles.labelLarge.copyWith(
                  color: ZuriColors.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final place = featured[index];
              return _FeaturedCard(
                place: place,
                onTap: () => onPlaceTap(place),
                userLat: userLat,
                userLng: userLng,
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final double userLat;
  final double userLng;

  const _FeaturedCard({
    required this.place,
    required this.onTap,
    required this.userLat,
    required this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: ZuriColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: ZuriColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: place.images.first,
                    width: 180,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 180,
                      height: 130,
                      color: ZuriColors.shimmerBase,
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 180,
                      height: 130,
                      color: ZuriColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: ZuriColors.textTertiary,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: RatingBadge(rating: place.rating),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ZuriColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.priceRange,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: ZuriTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: ZuriColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          place.distanceLabel(userLat, userLng),
                          style: ZuriTextStyles.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  }
}
