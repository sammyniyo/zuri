import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/widgets/rating_badge.dart';
import '../../shared/widgets/wait_time_badge.dart';
import '../reviews/widgets/reviews_section.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final Place place;
  final double userLat;
  final double userLng;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.userLat,
    required this.userLng,
  });

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  final _pageController = PageController();
  int _currentImage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchMaps() async {
    final place = widget.place;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone() async {
    final phone = widget.place.phone;
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final isSaved = ref.watch(
      savedPlacesProvider.select((s) => s.contains(place.id)),
    );
    final distLabel = place.distanceLabel(widget.userLat, widget.userLng);
    final walkTime = place.walkingTimeFrom(widget.userLat, widget.userLng);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: ZuriColors.background,
        body: CustomScrollView(
          slivers: [
            // ── Image gallery SliverAppBar ──────────────────────────────
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.black,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () =>
                      ref.read(savedPlacesProvider.notifier).toggle(place.id),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: isSaved ? ZuriColors.secondary : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image pager
                    PageView.builder(
                      controller: _pageController,
                      itemCount: place.images.length,
                      onPageChanged: (i) => setState(() => _currentImage = i),
                      itemBuilder: (_, i) => Hero(
                        tag: i == 0
                            ? 'place_image_${place.id}'
                            : 'place_img_${place.id}_$i',
                        child: CachedNetworkImage(
                          imageUrl: place.images[i],
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: Colors.grey.shade900),
                          errorWidget: (_, _, _) => Container(
                            color: Colors.grey.shade900,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white38,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Bottom gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 120,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Image counter
                    if (place.images.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: place.images.length,
                            effect: const ExpandingDotsEffect(
                              dotHeight: 6,
                              dotWidth: 6,
                              activeDotColor: Colors.white,
                              dotColor: Colors.white38,
                              spacing: 4,
                            ),
                          ),
                        ),
                      ),
                    // Image count badge
                    Positioned(
                      top: 60,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_currentImage + 1}/${place.images.length}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: ZuriColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header card ──────────────────────────────────────
                    Container(
                      color: ZuriColors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  place.name,
                                  style: ZuriTextStyles.headlineLarge,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RatingBadge(
                                    rating: place.rating,
                                    large: true,
                                  ),
                                  const SizedBox(height: 4),
                                  PriceRangeBadge(priceRange: place.priceRange),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Category + Open status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: ZuriColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  place.category,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ZuriColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OpenStatusBadge(isOpen: place.isOpen),
                              const SizedBox(width: 8),
                              if (place.waitStatus != WaitStatus.unknown)
                                WaitTimeBadge(
                                  status: place.waitStatus,
                                  minutes: place.estimatedWaitMinutes,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Distance / walk time row
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.location_on_outlined,
                                label: distLabel,
                              ),
                              const SizedBox(width: 10),
                              _InfoChip(
                                icon: Icons.directions_walk_rounded,
                                label: walkTime,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Action buttons ───────────────────────────────────
                    Container(
                      color: ZuriColors.surface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: _launchMaps,
                              icon: const Icon(
                                Icons.directions_walk_rounded,
                                size: 18,
                              ),
                              label: const Text('Walk There'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ZuriColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (place.phone != null)
                            _ActionIconButton(
                              icon: Icons.phone_rounded,
                              color: ZuriColors.primary,
                              onTap: _launchPhone,
                            ),
                          const SizedBox(width: 10),
                          _ActionIconButton(
                            icon: isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: isSaved
                                ? ZuriColors.secondary
                                : ZuriColors.textSecondary,
                            onTap: () => ref
                                .read(savedPlacesProvider.notifier)
                                .toggle(place.id),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Description ──────────────────────────────────────
                    Container(
                      color: ZuriColors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About',
                            style: ZuriTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            place.description,
                            style: ZuriTextStyles.bodyLarge,
                          ),
                          if (place.tags.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: place.tags
                                  .map(
                                    (tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ZuriColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: ZuriColors.textSecondary,
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
                    const SizedBox(height: 8),

                    // ── Price details ─────────────────────────────────────
                    if (place.priceDetails.isNotEmpty)
                      Container(
                        color: ZuriColors.surface,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prices in RWF',
                              style: ZuriTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 14),
                            ...place.priceDetails.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: ZuriTextStyles.bodyLarge,
                                    ),
                                    Text(
                                      _formatRwf(e.value),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: ZuriColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (place.priceDetails.isNotEmpty)
                      const SizedBox(height: 8),

                    // ── Opening hours ─────────────────────────────────────
                    if (place.openingHours.isNotEmpty)
                      Container(
                        color: ZuriColors.surface,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Opening Hours',
                              style: ZuriTextStyles.headlineMedium,
                            ),
                            const SizedBox(height: 14),
                            ...place.openingHours.entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.key,
                                      style: ZuriTextStyles.bodyLarge,
                                    ),
                                    Text(
                                      e.value,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: ZuriColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),

                    // ── Reviews ───────────────────────────────────────────
                    ReviewsSection(placeId: place.id),
                    const SizedBox(height: 8),

                    // ── Contact & Address ────────────────────────────────
                    Container(
                      color: ZuriColors.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Info',
                            style: ZuriTextStyles.headlineMedium,
                          ),
                          const SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            text: place.address,
                          ),
                          if (place.phone != null) ...[
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              text: place.phone!,
                            ),
                          ],
                          if (place.website != null) ...[
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.language_outlined,
                              text: place.website!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRwf(int amount) {
    final parts = amount.toString().split('');
    final buf = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buf.write(',');
      buf.write(parts[i]);
    }
    return '${buf.toString()} RWF';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ZuriColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ZuriColors.textSecondary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ZuriColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ZuriColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: ZuriTextStyles.bodyLarge)),
      ],
    );
  }
}
