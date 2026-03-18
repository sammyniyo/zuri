import 'package:flutter/material.dart';
import '../../../core/models/review_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZuriColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ZuriColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _avatarColor(review.userName),
                      _avatarColor(review.userName).withAlpha(180),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : 'Z',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: ZuriTextStyles.titleMedium),
                    Text(review.timeAgo, style: ZuriTextStyles.labelSmall),
                  ],
                ),
              ),
              // Star rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ZuriColors.ratingGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: ZuriColors.ratingGold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ZuriColors.ratingGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Review text ───────────────────────────────────────────────
          Text(review.text, style: ZuriTextStyles.bodyLarge),
          // ── Images ───────────────────────────────────────────────────
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    review.images[i],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 90,
                      height: 90,
                      color: ZuriColors.surfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF0FA958),
      const Color(0xFFFF8C42),
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
    ];
    int hash = 0;
    for (final ch in name.codeUnits) {
      hash = (hash * 31 + ch) & 0xFFFFFFFF;
    }
    return colors[hash % colors.length];
  }
}

// Star rating selector widget
class StarRatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;

  const StarRatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1.0;
        return GestureDetector(
          onTap: () => onRatingChanged(starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              starValue <= rating
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: starValue <= rating
                  ? ZuriColors.ratingGold
                  : ZuriColors.border,
            ),
          ),
        );
      }),
    );
  }
}
