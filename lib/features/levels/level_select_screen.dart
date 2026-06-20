import 'package:flutter/material.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/levels.dart';
import '../game/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final ProgressStore store;

  const LevelSelectScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final currentLevel = store.currentLevel;

    return Scaffold(
      appBar: AppBar(title: const Text('Levels')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
        ),
        itemCount: totalLevels,
        itemBuilder: (context, index) {
          final levelId = index + 1;
          final stars = store.getLevelStars(levelId);
          final unlocked = levelId <= currentLevel;

          return _LevelTile(
            levelId: levelId,
            stars: stars,
            unlocked: unlocked,
            onTap: unlocked
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameScreen(levelId: levelId),
                      ),
                    )
                : null,
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int levelId;
  final int stars;
  final bool unlocked;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.levelId,
    required this.stars,
    required this.unlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked
              ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
              : (isDark ? AppColors.tileEmptyDark : AppColors.tileEmptyLight),
          borderRadius: BorderRadius.circular(AppRadii.tile),
          border: Border.all(
            color: stars > 0
                ? AppColors.accent.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              const Icon(Icons.lock, size: 16, color: AppColors.heartEmpty)
            else
              Text(
                '$levelId',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  color: unlocked ? null : AppColors.heartEmpty,
                ),
              ),
            if (unlocked && stars > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 3; i++)
                    Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: 8,
                      color: i < stars ? AppColors.starGold : AppColors.starEmpty,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
