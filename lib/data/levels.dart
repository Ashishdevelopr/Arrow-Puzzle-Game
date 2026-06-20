import '../game/logic/level_generator.dart';

class LevelDef {
  final int id;
  final int rows;
  final int cols;
  final Difficulty difficulty;
  final int lives;
  final double fillRatio;
  final int seed;

  const LevelDef({
    required this.id,
    required this.rows,
    required this.cols,
    required this.difficulty,
    required this.lives,
    required this.fillRatio,
    required this.seed,
  });

  LevelConfig get config => LevelConfig(
    rows: rows,
    cols: cols,
    difficulty: difficulty,
    lives: lives,
    fillRatio: fillRatio,
  );
}

// 100 levels with a smooth difficulty curve
final List<LevelDef> kLevels = [
  // Tutorial (levels 1–3): 3×3 easy
  ..._range(1, 3, rows: 3, cols: 3, diff: Difficulty.easy, lives: 5, fill: 0.40),
  // Levels 4–10: 4×4 easy
  ..._range(4, 10, rows: 4, cols: 4, diff: Difficulty.easy, lives: 3, fill: 0.45),
  // Levels 11–20: 4×4 medium
  ..._range(11, 20, rows: 4, cols: 4, diff: Difficulty.medium, lives: 3, fill: 0.60),
  // Levels 21–30: 5×5 easy
  ..._range(21, 30, rows: 5, cols: 5, diff: Difficulty.easy, lives: 3, fill: 0.50),
  // Levels 31–40: 5×5 medium
  ..._range(31, 40, rows: 5, cols: 5, diff: Difficulty.medium, lives: 3, fill: 0.65),
  // Levels 41–50: 5×5 hard
  ..._range(41, 50, rows: 5, cols: 5, diff: Difficulty.hard, lives: 3, fill: 0.75),
  // Levels 51–60: 6×6 medium
  ..._range(51, 60, rows: 6, cols: 6, diff: Difficulty.medium, lives: 3, fill: 0.60),
  // Levels 61–70: 6×6 hard
  ..._range(61, 70, rows: 6, cols: 6, diff: Difficulty.hard, lives: 3, fill: 0.78),
  // Levels 71–80: 7×7 medium
  ..._range(71, 80, rows: 7, cols: 7, diff: Difficulty.medium, lives: 3, fill: 0.62),
  // Levels 81–90: 7×7 hard
  ..._range(81, 90, rows: 7, cols: 7, diff: Difficulty.hard, lives: 3, fill: 0.80),
  // Levels 91–100: 8×8 hard
  ..._range(91, 100, rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.82),
];

List<LevelDef> _range(
  int from,
  int to, {
  required int rows,
  required int cols,
  required Difficulty diff,
  required int lives,
  required double fill,
}) {
  return [
    for (int i = from; i <= to; i++)
      LevelDef(
        id: i,
        rows: rows,
        cols: cols,
        difficulty: diff,
        lives: lives,
        fillRatio: fill,
        seed: i * 31 + 7, // reproducible per level
      ),
  ];
}

LevelDef? getLevelDef(int id) {
  final idx = id - 1;
  if (idx < 0 || idx >= kLevels.length) return null;
  return kLevels[idx];
}

int get totalLevels => kLevels.length;
