import 'package:flutter/material.dart';

class ProBadge extends StatelessWidget {
  final bool small;
  const ProBadge({super.key, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(small ? 5 : 7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withAlpha(80),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('👑', style: TextStyle(fontSize: small ? 9 : 11)),
          const SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: small ? 9 : 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
