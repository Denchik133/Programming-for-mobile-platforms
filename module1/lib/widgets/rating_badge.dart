
import 'package:flutter/material.dart';

/// Віджет для відображення рейтингу із зіркою.
class RatingBadge extends StatelessWidget {
  final double rating;
  final String? label;

  const RatingBadge({
    super.key,
    required this.rating,
    this.label,
  }) : assert(rating >= 0.0 && rating <= 5.0);

  /// Визначає колір зірки залежно від рейтингу.
  Color get ratingColor {
    if (rating >= 4.0) {
      return Colors.green;
    } else if (rating >= 2.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: ratingColor,
          size: 22,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (label != null && label!.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(label!),
        ],
      ],
    );
  }
}
