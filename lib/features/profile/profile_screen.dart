import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/app_providers.dart';
import '../pro/pro_screen.dart';
import '../../shared/widgets/pro_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final savedCount = ref.watch(savedPlacesProvider).length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ZuriColors.background,
        body: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: ZuriColors.surface,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Profile', style: ZuriTextStyles.headlineLarge),
                            GestureDetector(
                              onTap: () => _showSettings(context, ref),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ZuriColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.settings_outlined,
                                    size: 20, color: ZuriColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // ── Avatar + name ─────────────────────────────
                        if (user != null || auth.isGuest) ...[
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      ZuriColors.primary,
                                      ZuriColors.primaryDark,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ZuriColors.primary.withAlpha(60),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: auth.isGuest
                                    ? const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 44)
                                    : Center(
                                        child: Text(
                                          user?.initials ?? 'Z',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                              if (user?.isProActive == true)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Center(
                                      child: Text('👑',
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                auth.isGuest ? 'Guest' : (user?.name ?? 'ZURI User'),
                                style: ZuriTextStyles.headlineMedium,
                              ),
                              if (user?.isProActive == true) ...[
                                const SizedBox(width: 8),
                                const ProBadge(),
                              ],
                            ],
                          ),
                          if (!auth.isGuest && (user?.phone != null || user?.email != null))
                            Text(
                              user?.phone ?? user?.email ?? '',
                              style: ZuriTextStyles.bodyMedium,
                            ),
                          const SizedBox(height: 20),
                          // ── Stats ────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: ZuriColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Reviews',
                                  value: '${user?.reviewCount ?? 0}',
                                  icon: Icons.star_rounded,
                                  color: ZuriColors.ratingGold,
                                ),
                                Container(
                                    width: 1, height: 36, color: ZuriColors.border),
                                _StatItem(
                                  label: 'Saved',
                                  value: '$savedCount',
                                  icon: Icons.bookmark_rounded,
                                  color: ZuriColors.secondary,
                                ),
                                Container(
                                    width: 1, height: 36, color: ZuriColors.border),
                                _StatItem(
                                  label: 'Explored',
                                  value: '10',
                                  icon: Icons.explore_rounded,
                                  color: ZuriColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Pro upgrade card (if not pro) ─────────────────────────
            if (user?.isProActive != true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => _openPro(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0FA958), Color(0xFF0A5C30)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: ZuriColors.primary.withAlpha(60),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Upgrade to ZURI Pro',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Reviews, filters & more — 5,000 RWF/mo',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.white.withAlpha(204),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Upgrade',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            if (user?.isProActive != true) const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Pro expiry info (if pro) ───────────────────────────────
            if (user?.isProActive == true)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ZuriColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: ZuriColors.primary.withAlpha(50), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded,
                            color: ZuriColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ZURI Pro Active',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ZuriColors.primaryDark,
                                ),
                              ),
                              Text(
                                'Expires ${_expiryText(user?.proExpiresAt)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: ZuriColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (user?.isProActive == true) const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Menu items ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: ZuriColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: ZuriColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.explore_outlined,
                        label: 'Explore Places',
                        color: ZuriColors.primary,
                        onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
                      ),
                      _divider(),
                      _MenuItem(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Saved Places',
                        color: ZuriColors.secondary,
                        onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                      ),
                      _divider(),
                      _MenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'My Reviews',
                        color: ZuriColors.ratingGold,
                        onTap: () {},
                      ),
                      _divider(),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        color: ZuriColors.textSecondary,
                        onTap: () {},
                      ),
                      _divider(),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About ZURI',
                        color: ZuriColors.textSecondary,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Sign out / Sign in ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: auth.isGuest
                    ? ElevatedButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZuriColors.primary,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign in for full access',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => _confirmSignOut(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ZuriColors.error,
                          side: const BorderSide(color: ZuriColors.error, width: 1.5),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, color: ZuriColors.divider);

  String _expiryText(DateTime? dt) {
    if (dt == null) return 'Unknown';
    final diff = dt.difference(DateTime.now()).inDays;
    return 'in $diff day${diff != 1 ? 's' : ''}';
  }

  void _openPro(BuildContext context, WidgetRef ref) {
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

  void _showSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZuriColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ZuriColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Settings', style: ZuriTextStyles.headlineMedium),
            const SizedBox(height: 16),
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              color: ZuriColors.primary,
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.language_outlined,
              label: 'Language',
              color: ZuriColors.textSecondary,
              onTap: () => Navigator.pop(context),
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              color: ZuriColors.textSecondary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?', style: ZuriTextStyles.headlineMedium),
        content: const Text(
          'You will need to sign in again to access your saved places and reviews.',
          style: ZuriTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: ZuriColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ZuriColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: ZuriColors.textPrimary,
          ),
        ),
        Text(label, style: ZuriTextStyles.labelSmall),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: ZuriTextStyles.titleMedium),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: ZuriColors.textTertiary),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
