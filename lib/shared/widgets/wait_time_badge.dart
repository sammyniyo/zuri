import 'package:flutter/material.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';

class WaitTimeBadge extends StatelessWidget {
  final WaitStatus status;
  final int? minutes;
  final bool compact;

  const WaitTimeBadge({
    super.key,
    required this.status,
    this.minutes,
    this.compact = false,
  });

  Color get _color {
    switch (status) {
      case WaitStatus.low:
        return ZuriColors.waitGreen;
      case WaitStatus.medium:
        return ZuriColors.waitYellow;
      case WaitStatus.high:
        return ZuriColors.waitRed;
      case WaitStatus.unknown:
        return ZuriColors.textTertiary;
    }
  }

  String get _label {
    if (status == WaitStatus.unknown) return 'Unknown wait';
    if (minutes == null || minutes == 0) return 'No wait';
    if (compact) return '${minutes}m wait';
    return '~$minutes min wait';
  }

  String get _dot {
    switch (status) {
      case WaitStatus.low:
        return '●';
      case WaitStatus.medium:
        return '●';
      case WaitStatus.high:
        return '●';
      case WaitStatus.unknown:
        return '○';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _dot,
            style: TextStyle(fontSize: compact ? 7 : 8, color: _color),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
