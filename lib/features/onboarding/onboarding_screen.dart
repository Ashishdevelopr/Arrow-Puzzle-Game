import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/logic/direction.dart';
import '../../game/logic/grid_model.dart';
import '../../game/state/game_state.dart';
import '../../game/widgets/game_board.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late GridModel _grid;
  late GameState _state;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _buildTutorialGrid();
  }

  void _buildTutorialGrid() {
    _grid = GridModel(rows: 3, cols: 3);
    // Simple 3x3 with a few arrows that can be removed in order
    _grid.setCell(0, 0, Direction.right); // blocked until (0,1) removed
    _grid.setCell(0, 2, Direction.down);  // removable: path down is clear
    _grid.setCell(2, 1, Direction.up);    // removable: path up needs check
    _grid.setCell(1, 1, Direction.right); // blocked by (1,2)
    _grid.setCell(1, 2, Direction.up);    // removable

    _state = GameState(
      grid: _grid,
      lives: 5,
      maxLives: 5,
      status: GameStatus.playing,
      levelId: 0,
      hintsRemaining: 0,
      undoStack: [],
      hintRow: 0,
      hintCol: 2,
    );
  }

  void _handleTap(int r, int c) {
    if (_grid.cells[r][c] == null) return;
    final removed = _grid.removeArrow(r, c);
    if (removed) {
      setState(() {
        _step++;
        final removable = _grid.removableArrows();
        int? hr, hc;
        if (removable.isNotEmpty) {
          hr = removable.first.x;
          hc = removable.first.y;
        }
        _state = GameState(
          grid: _grid,
          lives: _state.lives,
          maxLives: _state.maxLives,
          status: _grid.isCleared ? GameStatus.won : GameStatus.playing,
          levelId: 0,
          hintsRemaining: 0,
          undoStack: [],
          hintRow: hr,
          hintCol: hc,
          lastRemovedRow: r,
          lastRemovedCol: c,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tips = [
      'Tap glowing arrows — they can escape!',
      'An arrow escapes if its path to the edge is clear.',
      'Removing arrows opens paths for others.',
      'Keep going until the board is empty!',
      'You\'re ready. Let\'s play!',
    ];
    final tip = tips[_step.clamp(0, tips.length - 1)];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              Text('How to Play', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xl),

              // Instruction tip
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(tip),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: AppColors.accent, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(tip, style: theme.textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tutorial board
              if (_state.status != GameStatus.won)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth * 0.7;
                    return Center(
                      child: GameBoard(
                        gameState: _state,
                        onTap: _handleTap,
                        boardSize: size,
                      ),
                    );
                  },
                ),

              if (_state.status == GameStatus.won)
                Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.accent, size: 80),
                    const SizedBox(height: AppSpacing.md),
                    Text('You got it!', style: theme.textTheme.headlineMedium),
                  ],
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _state.status == GameStatus.won ||
                          _step >= tips.length - 1
                      ? () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          )
                      : null,
                  child: const Text('Start Playing'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                ),
                child: const Text('Skip Tutorial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
