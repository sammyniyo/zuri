import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/review_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../features/pro/pro_screen.dart';
import 'review_card.dart';
import '../add_review_screen.dart';

class ReviewsSection extends ConsumerWidget {
  final String placeId;

  const ReviewsSection({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(reviewProvider(placeId));
    final notifier = ref.read(reviewProvider(placeId).notifier);
    final isPro = ref.watch(isProProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    final avgRating = notifier.averageRating;
    final dist = notifier.ratingDistribution;
    final total = reviews.length;

    return Container(
      color: ZuriColors.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reviews', style: ZuriTextStyles.headlineMedium),
                  Text(
                    '$total review${total != 1 ? 's' : ''}',
                    style: ZuriTextStyles.bodyMedium,
                  ),
                ],
              ),
              // Write review button
              if (isAuth)
                isPro
                    ? GestureDetector(
                        onTap: () => _openAddReview(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ZuriColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Write Review',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _openPro(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('👑', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 5),
                              Text(
                                'Write Review',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Rating summary ─────────────────────────────────────────
          if (total > 0) ...[
            Row(
              children: [
                // Big average number
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: ZuriColors.textPrimary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: ZuriColors.ratingGold,
                        );
                      }),
                    ),
                    const SizedBox(height: 2),
                    Text('$total reviews', style: ZuriTextStyles.labelSmall),
                  ],
                ),
                const SizedBox(width: 20),
                // Rating bars
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = dist[star] ?? 0;
                      final fraction = total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$star',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: ZuriColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: ZuriColors.ratingGold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  minHeight: 8,
                                  backgroundColor: ZuriColors.surfaceVariant,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        ZuriColors.ratingGold,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 18,
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: ZuriColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
          ],

          // ── Review list ────────────────────────────────────────────
          if (reviews.isEmpty)
            _EmptyReviews(
              isAuth: isAuth,
              isPro: isPro,
              onWriteReview: () =>
                  isPro ? _openAddReview(context, ref) : _openPro(context),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
            ),
        ],
      ),
    );
  }

  void _openAddReview(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddReviewScreen(placeId: placeId)),
    );
  }

  void _openPro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.92,
        child: const ProScreen(),
      ),
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final bool isAuth;
  final bool isPro;
  final VoidCallback onWriteReview;

  const _EmptyReviews({
    required this.isAuth,
    required this.isPro,
    required this.onWriteReview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Icon(
          Icons.rate_review_outlined,
          size: 48,
          color: ZuriColors.textTertiary,
        ),
        const SizedBox(height: 12),
        const Text(
          'No reviews yet',
          style: ZuriTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Be the first to share your experience!',
          style: ZuriTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        if (isAuth) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onWriteReview,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isPro ? ZuriColors.primary : null,
                gradient: isPro
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isPro) ...[
                    const Text('👑', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                  ],
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Write the first review',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}
