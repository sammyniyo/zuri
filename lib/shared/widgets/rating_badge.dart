import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingBadge extends StatelessWidget {
  final double rating;
  final bool large;

  const RatingBadge({super.key, required this.rating, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 7,
        vertical: large ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: ZuriColors.ratingGold,
        borderRadius: BorderRadius.circular(large ? 10 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: large ? 15 : 12, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: large ? 13 : 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class PriceRangeBadge extends StatelessWidget {
  final String priceRange;

  const PriceRangeBadge({super.key, required this.priceRange});

  @override
  Widget build(BuildContext context) {
    return Text(
      priceRange,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ZuriColors.textSecondary,
      ),
    );
  }
}

class OpenStatusBadge extends StatelessWidget {
  final bool isOpen;

  const OpenStatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOpen
            ? ZuriColors.success.withValues(alpha: 0.1)
            : ZuriColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOpen ? ZuriColors.success : ZuriColors.error,
        ),
      ),
    );
  }
}
