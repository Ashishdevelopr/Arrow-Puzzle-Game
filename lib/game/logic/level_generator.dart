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
  // Higher attempt count so dense fills actually reach their target.
  static const int _maxAttempts = 50000;

  /// Reverse-generation: place arrows in reverse removal order → always solvable.
  static GridModel generate(LevelConfig config, {int seed = 0}) {
    final targetCount =
        (config.rows * config.cols * config.fillRatio).round().clamp(
              1,
              config.rows * config.cols,
            );

    // Run multiple attempts and keep the densest result.
    GridModel best = GridModel(rows: config.rows, cols: config.cols);
    int bestCount = 0;

    // For hard levels try several seeds to find the densest packing.
    final tries = config.difficulty == Difficulty.hard ? 4 : 1;

    for (int t = 0; t < tries; t++) {
      final g = _generateOnce(config, targetCount, Random(seed + t * 997));
      final count = g.remainingCount;
      if (count > bestCount) {
        bestCount = count;
        best = g;
      }
      if (bestCount >= targetCount) break;
    }

    return best;
  }

  static GridModel _generateOnce(
      LevelConfig config, int targetCount, Random rng) {
    final grid = GridModel(rows: config.rows, cols: config.cols);
    int placed = 0;
    int stalls = 0;

    while (placed < targetCount && stalls < _maxAttempts) {
      // Gather all valid (cell, direction) candidates — forward ray must be clear.
      final candidates = _buildCandidates(grid, config);

      if (candidates.isEmpty) break;

      final chosen = _pickCandidate(candidates, config.difficulty, rng);
      grid.setCell(chosen.r, chosen.c, chosen.dir);
      placed++;
      stalls = 0; // reset stall counter on each successful placement
    }

    return grid;
  }

  static List<_Candidate> _buildCandidates(GridModel grid, LevelConfig config) {
    final result = <_Candidate>[];
    for (int r = 0; r < config.rows; r++) {
      for (int c = 0; c < config.cols; c++) {
        if (grid.cells[r][c] != null) continue; // cell already occupied
        for (final dir in Direction.values) {
          if (_forwardRayClear(grid, r, c, dir)) {
            final len = _rayLength(grid, r, c, dir);
            result.add(_Candidate(r, c, dir, len));
          }
        }
      }
    }
    return result;
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
        // Uniform random — open board, varied arrow lengths.
        return candidates[rng.nextInt(candidates.length)];

      case Difficulty.medium:
        // Mild preference for medium-length rays (not too open, not edge-only).
        final sorted = [...candidates]
          ..sort((a, b) => a.rayLength.compareTo(b.rayLength));
        // pick from middle 50%
        final lo = (sorted.length * 0.25).round();
        final hi = (sorted.length * 0.75).round().clamp(lo + 1, sorted.length);
        return sorted[lo + rng.nextInt(hi - lo)];

      case Difficulty.hard:
        // Bias heavily toward SHORT rays (length 1–2).
        // Short-ray arrows pack densely: each only needs 1-2 clear cells ahead,
        // so many can coexist → truly crowded board, hard to untangle order.
        candidates.sort((a, b) => a.rayLength.compareTo(b.rayLength));
        // Pick from the shortest 25% of candidates.
        final topK = max(1, (candidates.length * 0.25).round());
        return candidates[rng.nextInt(topK)];
    }
  }
}

class _Candidate {
  final int r, c, rayLength;
  final Direction dir;
  const _Candidate(this.r, this.c, this.dir, this.rayLength);
}
