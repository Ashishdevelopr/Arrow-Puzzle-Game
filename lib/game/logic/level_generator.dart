import 'dart:math';
import 'direction.dart';
import 'grid_model.dart';

enum Difficulty { easy, medium, hard }

class LevelConfig {
  final int rows;
  final int cols;
  final Difficulty difficulty;
  final int lives;
  final double fillRatio;

  const LevelConfig({
    required this.rows,
    required this.cols,
    required this.difficulty,
    required this.lives,
    required this.fillRatio,
  });
}

class LevelGenerator {
  static const int _maxAttempts = 10000;

  /// Generate a level using reverse generation — guaranteed solvable.
  static GridModel generate(LevelConfig config, {int seed = 0}) {
    final rng = Random(seed);
    final grid = GridModel(rows: config.rows, cols: config.cols);
    final targetCount = (config.rows * config.cols * config.fillRatio).round();
    int placed = 0;
    int attempts = 0;

    while (placed < targetCount && attempts < _maxAttempts) {
      attempts++;

      // Gather candidate (cell, direction) pairs where the forward ray is clear.
      final candidates = <_Candidate>[];
      for (int r = 0; r < config.rows; r++) {
        for (int c = 0; c < config.cols; c++) {
          if (grid.cells[r][c] != null) continue;
          for (final dir in Direction.values) {
            if (_forwardRayClear(grid, r, c, dir)) {
              final rayLen = _rayLength(grid, r, c, dir);
              candidates.add(_Candidate(r, c, dir, rayLen));
            }
          }
        }
      }

      if (candidates.isEmpty) break;

      final candidate = _pickCandidate(candidates, config.difficulty, rng);
      grid.setCell(candidate.r, candidate.c, candidate.dir);
      placed++;
    }

    return grid;
  }

  /// True if every cell from (r,c) stepping in dir to the edge is empty.
  static bool _forwardRayClear(GridModel grid, int r, int c, Direction dir) {
    int nr = r + dir.rowDelta;
    int nc = c + dir.colDelta;
    while (nr >= 0 && nr < grid.rows && nc >= 0 && nc < grid.cols) {
      if (grid.cells[nr][nc] != null) return false;
      nr += dir.rowDelta;
      nc += dir.colDelta;
    }
    return true;
  }

  static int _rayLength(GridModel grid, int r, int c, Direction dir) {
    int len = 0;
    int nr = r + dir.rowDelta;
    int nc = c + dir.colDelta;
    while (nr >= 0 && nr < grid.rows && nc >= 0 && nc < grid.cols) {
      len++;
      nr += dir.rowDelta;
      nc += dir.colDelta;
    }
    return len;
  }

  static _Candidate _pickCandidate(
    List<_Candidate> candidates,
    Difficulty difficulty,
    Random rng,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return candidates[rng.nextInt(candidates.length)];

      case Difficulty.medium:
        return candidates[rng.nextInt(candidates.length)];

      case Difficulty.hard:
        // Bias toward longer rays (arrows placed early get buried deeper).
        candidates.sort((a, b) => b.rayLength.compareTo(a.rayLength));
        final topK = max(1, (candidates.length * 0.3).round());
        return candidates[rng.nextInt(topK)];
    }
  }
}

class _Candidate {
  final int r, c, rayLength;
  final Direction dir;
  const _Candidate(this.r, this.c, this.dir, this.rayLength);
}
