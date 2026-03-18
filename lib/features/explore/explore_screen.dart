import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import 'widgets/place_card.dart';
import 'widgets/filter_chips_row.dart';
import 'widgets/featured_section.dart';
import '../filter/filter_bottom_sheet.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final Function(Place) onPlaceTap;

  const ExploreScreen({super.key, required this.onPlaceTap});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final places = ref.watch(filteredPlacesProvider);
    final filter = ref.watch(filterProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ZuriColors.background,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Header ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: ZuriColors.surface,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: ZuriColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Kigali, Rwanda',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ZuriColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 16,
                                        color: ZuriColors.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Discover nearby',
                                    style: ZuriTextStyles.headlineLarge,
                                  ),
                                ],
                              ),
                            ),
                            // Profile / notifications
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: ZuriColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'Z',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: ZuriColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Search bar ──────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showSearch(
                                    context: context,
                                    delegate: _ZuriSearchDelegate(
                                      ref: ref,
                                      onPlaceTap: widget.onPlaceTap,
                                      userLat: location.latitude,
                                      userLng: location.longitude,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ZuriColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.search_rounded,
                                        color: ZuriColors.textTertiary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Search restaurants, pools...',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: ZuriColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Filter button
                            GestureDetector(
                              onTap: _openFilter,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: filter.hasActiveFilters
                                      ? ZuriColors.primary
                                      : ZuriColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.tune_rounded,
                                        color: filter.hasActiveFilters
                                            ? Colors.white
                                            : ZuriColors.textSecondary,
                                        size: 22,
                                      ),
                                    ),
                                    if (filter.hasActiveFilters)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: ZuriColors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter chips ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: ZuriColors.surface,
                child: Column(
                  children: [
                    const FilterChipsRow(),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: ZuriColors.divider, thickness: 1),
                  ],
                ),
              ),
            ),

            // ── Featured places ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: FeaturedSection(
                  onPlaceTap: widget.onPlaceTap,
                  userLat: location.latitude,
                  userLng: location.longitude,
                ),
              ),
            ),

            // ── Nearby places header ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nearby Places',
                          style: ZuriTextStyles.headlineMedium,
                        ),
                        Text(
                          '${places.length} place${places.length != 1 ? 's' : ''} found',
                          style: ZuriTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    // Sort indicator
                    GestureDetector(
                      onTap: _openFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ZuriColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sort_rounded,
                              size: 16,
                              color: ZuriColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _sortLabel(ref.watch(filterProvider).sortBy),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
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
            ),

            // ── Place cards list ───────────────────────────────────────────
            places.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyState(
                      onReset: () => ref.read(filterProvider.notifier).reset(),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PlaceCard(
                          place: places[index],
                          onTap: () => widget.onPlaceTap(places[index]),
                          userLat: location.latitude,
                          userLng: location.longitude,
                        ),
                        childCount: places.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'rating':
        return 'Top Rated';
      case 'price':
        return 'Price';
      default:
        return 'Nearest';
    }
  }
}

// ─── Search delegate ──────────────────────────────────────────────────────────
class _ZuriSearchDelegate extends SearchDelegate<Place?> {
  final WidgetRef ref;
  final Function(Place) onPlaceTap;
  final double userLat;
  final double userLng;

  _ZuriSearchDelegate({
    required this.ref,
    required this.onPlaceTap,
    required this.userLat,
    required this.userLng,
  });

  @override
  String get searchFieldLabel => 'Search places...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ZuriColors.surface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: ZuriColors.textTertiary,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () {
            query = '';
            ref.read(searchQueryProvider.notifier).state = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildResultsView();

  @override
  Widget buildSuggestions(BuildContext context) {
    ref.read(searchQueryProvider.notifier).state = query;
    return _buildResultsView();
  }

  Widget _buildResultsView() {
    final results = ref.watch(searchResultsProvider);
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_rounded,
              size: 64,
              color: ZuriColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Search for restaurants, cafes,\npools, and more...',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: ZuriColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: ZuriColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No places found for "$query"',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: ZuriColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final place = results[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              place.images.first,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 56,
                color: ZuriColors.surfaceVariant,
                child: const Icon(Icons.place, color: ZuriColors.textTertiary),
              ),
            ),
          ),
          title: Text(place.name, style: ZuriTextStyles.titleMedium),
          subtitle: Text(
            '${place.category} · ${place.distanceLabel(userLat, userLng)}',
            style: ZuriTextStyles.bodyMedium,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ZuriColors.ratingGold,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 2),
                Text(
                  place.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            close(context, place);
            onPlaceTap(place);
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 72,
            color: ZuriColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No places found',
            style: ZuriTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search in a different area.',
            style: ZuriTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}
