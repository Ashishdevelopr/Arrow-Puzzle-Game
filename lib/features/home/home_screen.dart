import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../game/game_screen.dart';
import '../levels/level_select_screen.dart';
import '../daily/daily_screen.dart';
import '../settings/settings_screen.dart';

final progressStoreProvider = FutureProvider<ProgressStore>((ref) async {
  return ProgressStore.load();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(progressStoreProvider);

    return Scaffold(
      body: SafeArea(
        child: storeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (store) => _HomeContent(store: store),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final ProgressStore store;

  const _HomeContent({required this.store});

  @override
  Widget build(BuildContext context) {
    final currentLevel = store.currentLevel;
    final totalStars = store.allStars.values.fold(0, (a, b) => a + b);

    return Column(
      children: [
        // Settings button
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo / title
                _LogoWidget(),
                const SizedBox(height: AppSpacing.xl),

                // Level + stars info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Chip(
                      icon: Icons.grid_view,
                      label: 'Level $currentLevel',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _Chip(
                      icon: Icons.star,
                      label: '$totalStars ★',
                      color: AppColors.starGold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Play button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _goToLevel(context, currentLevel),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        currentLevel == 1 ? 'Play' : 'Continue',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Daily challenge card
                _DailyCard(store: store),
                const SizedBox(height: AppSpacing.md),

                // Level select
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.grid_4x4),
                    label: const Text('All Levels'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelSelectScreen(store: store),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goToLevel(BuildContext context, int levelId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId)),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_upward, color: Colors.white, size: 40),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Arrow Puzzle',
          style: theme.textTheme.headlineLarge?.copyWith(
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tap arrows to set them free',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Chip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.tileFillLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color ?? AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  final ProgressStore store;

  const _DailyCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final dateKey = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final done = store.isDailyDone(dateKey);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DailyScreen(store: store)),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: done ? AppColors.accent : AppColors.accent.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.chip),
              ),
              child: Icon(
                done ? Icons.check_circle : Icons.calendar_today,
                color: AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Challenge', style: theme.textTheme.titleMedium),
                  Text(
                    done ? 'Completed today!' : 'Today\'s puzzle awaits',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}
