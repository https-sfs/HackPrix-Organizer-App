import 'package:flutter/material.dart';
import 'main.dart';

enum NotificationCategory {
  general,
  food,
  mentoring,
  workshop,
  results,
  emergency,
  transport;

  String get label {
    switch (this) {
      case NotificationCategory.general:
        return 'General';
      case NotificationCategory.food:
        return 'Food';
      case NotificationCategory.mentoring:
        return 'Mentoring';
      case NotificationCategory.workshop:
        return 'Workshop';
      case NotificationCategory.results:
        return 'Results';
      case NotificationCategory.emergency:
        return 'Emergency';
      case NotificationCategory.transport:
        return 'Transport';
    }
  }

  String get popupTitle => '$label Update';

  IconData get icon {
    switch (this) {
      case NotificationCategory.general:
        return Icons.campaign_outlined;
      case NotificationCategory.food:
        return Icons.restaurant_rounded;
      case NotificationCategory.mentoring:
        return Icons.support_agent_rounded;
      case NotificationCategory.workshop:
        return Icons.build_circle_outlined;
      case NotificationCategory.results:
        return Icons.emoji_events_outlined;
      case NotificationCategory.emergency:
        return Icons.warning_amber_rounded;
      case NotificationCategory.transport:
        return Icons.directions_bus_rounded;
    }
  }

  Color get accent {
    switch (this) {
      case NotificationCategory.general:
        return HackPrixColors.blue;
      case NotificationCategory.food:
        return HackPrixColors.orange;
      case NotificationCategory.mentoring:
        return HackPrixColors.purple;
      case NotificationCategory.workshop:
        return HackPrixColors.cyan;
      case NotificationCategory.results:
        return HackPrixColors.lime;
      case NotificationCategory.emergency:
        return const Color(0xFFE53935);
      case NotificationCategory.transport:
        return HackPrixColors.yellow;
    }
  }

  static NotificationCategory fromValue(String? value) {
    if (value == null || value.isEmpty) return NotificationCategory.general;

    for (final category in NotificationCategory.values) {
      if (category.name == value.toLowerCase()) return category;
    }

    return NotificationCategory.general;
  }
}
