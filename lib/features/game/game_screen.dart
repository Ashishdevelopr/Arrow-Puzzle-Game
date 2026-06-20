import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/levels.dart';
import '../../game/state/game_controller.dart';
import '../../game/state/game_state.dart';
import '../../game/widgets/game_board.dart';
import '../../game/widgets/lives_bar.dart';
import 'win_overlay.dart';
import 'out_of_lives_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final int levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _progressSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).loadLevel(widget.levelId);
    });
  }

  Future<void> _saveProgress(int stars) async {
    if (_progressSaved) return;
    _progressSaved = true;
    final store = await ProgressStore.load();
    store.setLevelStars(widget.levelId, stars);
    if (widget.levelId >= store.currentLevel) {
      store.currentLevel = widget.levelId + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final ctrl = ref.read(gameControllerProvider.notifier);

    if (gameState?.status == GameStatus.won && !_progressSaved) {
      _saveProgress(gameState!.starsEarned);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(
                  levelId: widget.levelId,
                  gameState: gameState,
                  onBack: () => Navigator.of(context).pop(),
                  onHint: ctrl.useHint,
                  onRestart: () { _progressSaved = false; ctrl.restart(); },
                  onUndo: ctrl.undo,
                ),
                Expanded(
                  child: gameState == null
                      ? const Center(child: CircularProgressIndicator())
                      : _BoardArea(gameState: gameState, ctrl: ctrl),
                ),
              ],
            ),
            // Overlays
            if (gameState?.status == GameStatus.won)
              WinOverlay(
                stars: gameState!.starsEarned,
                levelId: widget.levelId,
                onNext: () {
                  final next = widget.levelId + 1;
                  if (next <= totalLevels) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => GameScreen(levelId: next),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                onHome: () => Navigator.of(context).pop(),
                onReplay: () {
                  _progressSaved = false;
                  ctrl.restart();
                },
              ),
            if (gameState?.status == GameStatus.outOfLives)
              OutOfLivesOverlay(
                onRetry: () { _progressSaved = false; ctrl.restart(); },
                onHome: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int levelId;
  final GameState? gameState;
  final VoidCallback onBack;
  final VoidCallback onHint;
  final VoidCallback onRestart;
  final VoidCallback onUndo;

  const _TopBar({
    required this.levelId,
    required this.gameState,
    required this.onBack,
    required this.onHint,
    required this.onRestart,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = gameState;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Level $levelId',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          if (s != null) LivesBar(lives: s.lives, maxLives: s.maxLives),
          const SizedBox(width: AppSpacing.sm),
          _HintButton(
            count: s?.hintsRemaining ?? 0,
            onTap: onHint,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRestart,
            tooltip: 'Restart',
          ),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: onUndo,
            tooltip: 'Undo',
          ),
        ],
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _HintButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: count > 0 ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: count > 0
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(
            color: count > 0 ? AppColors.accent : AppColors.heartEmpty,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: count > 0 ? AppColors.accent : AppColors.heartEmpty,
            ),
            const SizedBox(width: 2),
            Text(
              '$count',
              style: TextStyle(
                color: count > 0 ? AppColors.accent : AppColors.heartEmpty,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardArea extends ConsumerWidget {
  final GameState gameState;
  final GameController ctrl;

  const _BoardArea({required this.gameState, required this.ctrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.biggest.shortestSide - AppSizes.boardPadding * 2;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.boardPadding),
            child: GameBoard(
              gameState: gameState,
              onTap: ctrl.tapCell,
              boardSize: available,
            ),
          ),
        );
      },
    );
  }
}
