import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

IconData mapLocationIcon(String iconKey) => switch (iconKey) {
      'bakery' => Icons.bakery_dining,
      'bar' => Icons.local_bar,
      'cafe' => Icons.local_cafe,
      'restaurant' => Icons.restaurant,
      'amusement_park' => Icons.attractions,
      'arcade' => Icons.sports_esports,
      'bowling_alley' => Icons.sports_baseball,
      'movie_theatre' => Icons.movie,
      'nightlife' => Icons.nightlife,
      'park' => Icons.park,
      'playground' => Icons.child_care,
      'water_park' => Icons.water,
      'zoo' => Icons.pets,
      'art_gallery' => Icons.palette,
      'cultural_attraction' => Icons.landscape,
      'cultural_centre' => Icons.groups,
      'historical_place' => Icons.account_balance,
      'museum' => Icons.museum,
      'theatre' => Icons.theater_comedy,
      _ => Icons.place,
    };

Color mapLocationColor(String group) => switch (group) {
      'food_drink' => Colors.deepOrange,
      'entertainment' => Colors.deepPurple,
      'culture' => Colors.blue,
      _ => AppColors.pine,
    };
