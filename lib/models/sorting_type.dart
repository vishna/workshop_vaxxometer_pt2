import 'package:flutter/material.dart';

enum SortingType { byQuota, byVaccinated, byName }

extension SortingTypeExt on SortingType {
  IconData get iconData {
    switch (this) {
      case SortingType.byQuota:
        return Icons.trending_up;
      case SortingType.byVaccinated:
        return Icons.family_restroom;
      case SortingType.byName:
        return Icons.sort_by_alpha;
    }
  }

  String get tooltip {
    switch (this) {
      case SortingType.byQuota:
        return "Sort by Percentage";
      case SortingType.byVaccinated:
        return "Sort by Vaccinated Count";
      case SortingType.byName:
        return "Sort by Name";
    }
  }
}
