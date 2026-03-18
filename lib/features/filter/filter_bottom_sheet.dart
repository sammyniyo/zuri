import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/models/place_model.dart';
import '../../core/constants/app_constants.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late FilterOptions _local;

  @override
  void initState() {
    super.initState();
    _local = ref.read(filterProvider);
  }

  void _apply() {
    final notifier = ref.read(filterProvider.notifier);
    notifier.setCategory(_local.category);
    notifier.setMinRating(_local.minRating);
    notifier.setMaxDistance(_local.maxDistanceKm);
    notifier.setOpenNow(_local.openNow);
    notifier.setSortBy(_local.sortBy);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: ZuriColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: ZuriColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filters', style: ZuriTextStyles.headlineLarge),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _local = const FilterOptions();
                        });
                      },
                      child: const Text(
                        'Reset all',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: ZuriColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Category ────────────────────────────────────────
                    const Text('Category', style: ZuriTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PlaceCategories.all.map((cat) {
                        final selected = _local.category == cat;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _local = _local.copyWith(category: cat),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? ZuriColors.primary
                                  : ZuriColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? ZuriColors.primary
                                    : ZuriColors.border,
                              ),
                            ),
                            child: Text(
                              '${PlaceCategories.icons[cat] ?? ''} $cat',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : ZuriColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Sort by ──────────────────────────────────────────
                    const Text('Sort by', style: ZuriTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _SortChip(
                          label: 'Nearest',
                          value: 'distance',
                          selected: _local.sortBy,
                          onTap: (v) => setState(
                            () => _local = _local.copyWith(sortBy: v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label: 'Top Rated',
                          value: 'rating',
                          selected: _local.sortBy,
                          onTap: (v) => setState(
                            () => _local = _local.copyWith(sortBy: v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SortChip(
                          label: 'Price',
                          value: 'price',
                          selected: _local.sortBy,
                          onTap: (v) => setState(
                            () => _local = _local.copyWith(sortBy: v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Min rating ────────────────────────────────────────
                    const Text(
                      'Minimum rating',
                      style: ZuriTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [null, 3.0, 3.5, 4.0, 4.5].map((r) {
                        final isSelected = _local.minRating == r;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _local = _local.copyWith(minRating: r),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ZuriColors.ratingGold
                                  : ZuriColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (r != null) ...[
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : ZuriColors.ratingGold,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  r == null ? 'Any' : '$r+',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : ZuriColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Max distance ──────────────────────────────────────
                    const Text(
                      'Max distance',
                      style: ZuriTextStyles.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [null, 0.5, 1.0, 2.0, 5.0].map((d) {
                        final isSelected = _local.maxDistanceKm == d;
                        return GestureDetector(
                          onTap: () => setState(
                            () => _local = _local.copyWith(maxDistanceKm: d),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? ZuriColors.primary
                                  : ZuriColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? ZuriColors.primary
                                    : ZuriColors.border,
                              ),
                            ),
                            child: Text(
                              d == null ? 'Any' : '${d}km',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : ZuriColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ── Open now ──────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: ZuriColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Open now',
                                style: ZuriTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Only show places open right now',
                                style: ZuriTextStyles.bodyMedium.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _local.openNow,
                            onChanged: (v) => setState(
                              () => _local = _local.copyWith(openNow: v),
                            ),
                            activeThumbColor: ZuriColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                decoration: BoxDecoration(
                  color: ZuriColors.surface,
                  boxShadow: ZuriColors.bottomNavShadow,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZuriColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ZuriColors.primary : ZuriColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ZuriColors.primary : ZuriColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : ZuriColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
