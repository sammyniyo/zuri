import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/rating_badge.dart';

class SavedScreen extends ConsumerWidget {
  final Function(Place) onPlaceTap;

  const SavedScreen({super.key, required this.onPlaceTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedPlaceListProvider);
    final location = ref.watch(locationProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ZuriColors.background,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: ZuriColors.surface,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text('Saved Places'),
              centerTitle: false,
              actions: [
                if (saved.isNotEmpty)
                  TextButton(
                    onPressed: () => _confirmClearAll(context, ref),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: ZuriColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            if (saved.isEmpty)
              SliverFillRemaining(child: _EmptySaved())
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final place = saved[index];
                    return _SavedPlaceTile(
                      place: place,
                      userLat: location.latitude,
                      userLng: location.longitude,
                      onTap: () => onPlaceTap(place),
                      onRemove: () {
                        ref.read(savedPlacesProvider.notifier).toggle(place.id);
                      },
                    );
                  }, childCount: saved.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear all saved?',
          style: ZuriTextStyles.headlineMedium,
        ),
        content: const Text(
          'This will remove all your saved places.',
          style: ZuriTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ZuriColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear all saved
              final saved = ref.read(savedPlaceListProvider);
              for (final p in saved) {
                ref.read(savedPlacesProvider.notifier).toggle(p.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ZuriColors.error),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  final Place place;
  final double userLat;
  final double userLng;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SavedPlaceTile({
    required this.place,
    required this.userLat,
    required this.userLng,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(place.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ZuriColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: ZuriColors.error,
          size: 26,
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ZuriColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: ZuriColors.cardShadow,
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: place.images.first,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 80,
                    height: 80,
                    color: ZuriColors.shimmerBase,
                  ),
                  errorWidget: (_, _, _) => Container(
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
              // Info
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RatingBadge(rating: place.rating),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: ZuriColors.textTertiary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          place.distanceLabel(userLat, userLng),
                          style: ZuriTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Remove button
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ZuriColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_remove_outlined,
                    size: 18,
                    color: ZuriColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ZuriColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 48,
                color: ZuriColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No saved places yet',
              style: ZuriTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the bookmark icon on any place\nto save it for later.',
              style: ZuriTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
