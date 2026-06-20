import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/logic/level_generator.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_state.dart';
import '../../game/widgets/game_board.dart';
import '../../game/widgets/lives_bar.dart';
import '../game/win_overlay.dart';
import '../game/out_of_lives_overlay.dart';

class DailyScreen extends StatelessWidget {
  final ProgressStore store;

  const DailyScreen({super.key, required this.store});

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  int get _dailySeed => int.parse(_todayKey);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = store.isDailyDone(_todayKey);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_formatDate(now), style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                isDone ? 'You completed today\'s challenge!' : 'A fresh puzzle every day',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              _MonthCalendar(store: store, now: now),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDone
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DailyGameScreen(
                                seed: _dailySeed,
                                dateKey: _todayKey,
                                store: store,
                              ),
                            ),
                          ),
                  child: Text(isDone ? 'Completed ✓' : 'Start Today\'s Puzzle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _MonthCalendar extends StatelessWidget {
  final ProgressStore store;
  final DateTime now;

  const _MonthCalendar({required this.store, required this.now});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, i) {
        final day = i + 1;
        final key =
            '${now.year}${now.month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}';
        final done = store.isDailyDone(key);
        final isToday = day == now.day;
        final future = day > now.day;

        Color bg;
        if (done) {
          bg = AppColors.accent;
        } else if (future) {
          bg = isDark ? AppColors.tileEmptyDark : AppColors.tileEmptyLight;
        } else {
          bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        }

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: isToday ? Border.all(color: AppColors.accent, width: 2) : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                color: done ? Colors.white : (future ? AppColors.heartEmpty : null),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DailyGameScreen extends ConsumerStatefulWidget {
  final int seed;
  final String dateKey;
  final ProgressStore store;

  const DailyGameScreen({
    super.key,
    required this.seed,
    required this.dateKey,
    required this.store,
  });

  @override
  ConsumerState<DailyGameScreen> createState() => _DailyGameScreenState();
}

class _DailyGameScreenState extends ConsumerState<DailyGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const config = LevelConfig(
        rows: 6,
        cols: 6,
        difficulty: Difficulty.medium,
        lives: 3,
        fillRatio: 0.65,
      );
      final grid = LevelGenerator.generate(config, seed: widget.seed);
      ref.read(gameControllerProvider.notifier).loadCustomGrid(grid, lives: 3, levelId: -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final ctrl = ref.read(gameControllerProvider.notifier);

    // Save on win
    if (gameState?.status == GameStatus.won) {
      widget.store.markDailyDone(widget.dateKey);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(child: Text('Daily Challenge', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18))),
                      ),
                      if (gameState != null)
                        LivesBar(lives: gameState.lives, maxLives: gameState.maxLives),
                      IconButton(icon: const Icon(Icons.lightbulb_outline), onPressed: ctrl.useHint),
                      IconButton(icon: const Icon(Icons.undo), onPressed: ctrl.undo),
                    ],
                  ),
                ),
                Expanded(
                  child: gameState == null
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final size = constraints.biggest.shortestSide - AppSizes.boardPadding * 2;
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.boardPadding),
                                child: GameBoard(
                                  gameState: gameState,
                                  onTap: ctrl.tapCell,
                                  boardSize: size,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            if (gameState?.status == GameStatus.won)
              WinOverlay(
                stars: gameState!.starsEarned,
                levelId: 0,
                onNext: () => Navigator.of(context).pop(),
                onHome: () => Navigator.of(context).pop(),
                onReplay: ctrl.restart,
              ),
            if (gameState?.status == GameStatus.outOfLives)
              OutOfLivesOverlay(
                onRetry: ctrl.restart,
                onHome: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}
