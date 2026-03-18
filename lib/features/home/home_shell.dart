import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/models/place_model.dart';
import '../../core/theme/app_colors.dart';
import '../explore/explore_screen.dart';
import '../map/map_screen.dart';
import '../saved/saved_screen.dart';
import '../profile/profile_screen.dart';
import '../place_detail/place_detail_screen.dart';
import '../../shared/widgets/zuri_bottom_nav.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(bottomNavIndexProvider);
    final location = ref.watch(locationProvider);

    void goToDetail(Place place) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlaceDetailScreen(
            place: place,
            userLat: location.latitude,
            userLng: location.longitude,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ZuriColors.background,
      body: IndexedStack(
        index: tabIndex,
        children: [
          ExploreScreen(onPlaceTap: goToDetail),
          MapScreen(onPlaceTap: goToDetail),
          SavedScreen(onPlaceTap: goToDetail),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ZuriBottomNav(
        currentIndex: tabIndex,
        onTap: (i) =>
            ref.read(bottomNavIndexProvider.notifier).state = i,
      ),
    );
  }
}
