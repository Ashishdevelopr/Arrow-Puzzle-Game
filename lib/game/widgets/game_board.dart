import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/logic/direction.dart';
import '../../game/state/game_state.dart';
import 'arrow_widget.dart';
import 'flying_arrow.dart';

class GameBoard extends StatefulWidget {
  final GameState gameState;
  final void Function(int r, int c) onTap;
  final double boardSize;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onTap,
    required this.boardSize,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final List<FlyingArrowData> _flying = [];
  int _nextId = 0;
  int? _prevRemovedRow, _prevRemovedCol;

  @override
  void didUpdateWidget(GameBoard old) {
    super.didUpdateWidget(old);
    final s = widget.gameState;
    final removedRow = s.lastRemovedRow;
    final removedCol = s.lastRemovedCol;

    if (removedRow != null &&
        removedCol != null &&
        (removedRow != _prevRemovedRow || removedCol != _prevRemovedCol)) {
      final prevDir = old.gameState.grid.cells[removedRow][removedCol];
      if (prevDir != null) {
        _spawnFlyingArrow(removedRow, removedCol, prevDir);
      }
      _prevRemovedRow = removedRow;
      _prevRemovedCol = removedCol;
    }
  }

  void _spawnFlyingArrow(int r, int c, Direction dir) {
    final id = _nextId++;
    final tileSize = _tileSize;
    final gap = _gap;

    final data = FlyingArrowData(
      id: id,
      row: r,
      col: c,
      direction: dir,
      startX: c * (tileSize + gap),
      startY: r * (tileSize + gap),
      tileSize: tileSize,
    );

    setState(() => _flying.add(data));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _flying.removeWhere((f) => f.id == id));
    });
  }

  double get _gap => AppSpacing.sm;

  double get _tileSize {
    final rows = widget.gameState.grid.rows;
    final cols = widget.gameState.grid.cols;
    final maxTiles = max(rows, cols);
    final available = widget.boardSize - (maxTiles - 1) * _gap;
    return (available / maxTiles).clamp(AppSizes.minTileSize, 80.0);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.gameState;
    final grid = s.grid;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileSize = _tileSize;
    final gap = _gap;

    final boardW = grid.cols * tileSize + (grid.cols - 1) * gap;
    final boardH = grid.rows * tileSize + (grid.rows - 1) * gap;

    return SizedBox(
      width: boardW,
      height: boardH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Empty slot backgrounds
          for (int r = 0; r < grid.rows; r++)
            for (int c = 0; c < grid.cols; c++)
              Positioned(
                left: c * (tileSize + gap),
                top: r * (tileSize + gap),
                child: _TileSlot(size: tileSize, isDark: isDark),
              ),

          // Arrow widgets
          for (int r = 0; r < grid.rows; r++)
            for (int c = 0; c < grid.cols; c++)
              if (grid.cells[r][c] != null)
                Positioned(
                  key: ValueKey('arrow_${r}_$c'),
                  left: c * (tileSize + gap),
                  top: r * (tileSize + gap),
                  child: ArrowWidget(
                    direction: grid.cells[r][c]!,
                    isRemovable: grid.isRemovable(r, c),
                    isBlocked: s.lastBlockedRow == r && s.lastBlockedCol == c,
                    isHinted: s.hintRow == r && s.hintCol == c,
                    isNew: false,
                    onTap: () => widget.onTap(r, c),
                    tileSize: tileSize,
                    isDark: isDark,
                    compact: grid.rows > 6 || grid.cols > 6,
                  ),
                ),

          // Flying escape animations
          for (final fa in _flying)
            FlyingArrow(
              key: ValueKey('fly_${fa.id}'),
              data: fa,
              isDark: isDark,
              rows: grid.rows,
              cols: grid.cols,
              tileSize: tileSize,
              gap: gap,
              compact: grid.rows > 6 || grid.cols > 6,
            ),
        ],
      ),
    );
  }
}

class _TileSlot extends StatelessWidget {
  final double size;
  final bool isDark;
  const _TileSlot({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.tileEmptyDark : AppColors.tileEmptyLight,
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
    );
  }
}
