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

// 100 levels.
// Easy warmup (1-10) → medium (11-20) → hard dense mazes (21-100).
// Arrow count listed as guide; actual count = rows*cols*fillRatio.
final List<LevelDef> kLevels = [

  // ── EASY WARMUP ─────────────────────────────────────────────────────────
  // Levels 1–5: 4×4, ~8 arrows — intro, open board
  ..._range(1, 5,
      rows: 4, cols: 4, diff: Difficulty.easy, lives: 5, fill: 0.50),
  // Levels 6–10: 4×4, ~10 arrows — still easy, slightly busier
  ..._range(6, 10,
      rows: 4, cols: 4, diff: Difficulty.easy, lives: 4, fill: 0.65),

  // ── MEDIUM TRANSITION ───────────────────────────────────────────────────
  // Levels 11–15: 5×5, ~14 arrows — medium difficulty
  ..._range(11, 15,
      rows: 5, cols: 5, diff: Difficulty.medium, lives: 3, fill: 0.56),
  // Levels 16–20: 5×5, ~18 arrows — medium/dense
  ..._range(16, 20,
      rows: 5, cols: 5, diff: Difficulty.medium, lives: 3, fill: 0.72),

  // ── HARD DENSE MAZES ────────────────────────────────────────────────────
  // Short-ray bias packs arrows tightly; high fill = crowded grid.

  // Levels 21–25: 5×5 hard, ~21 arrows (84% fill — nearly every cell)
  ..._range(21, 25,
      rows: 5, cols: 5, diff: Difficulty.hard, lives: 3, fill: 0.84),
  // Levels 26–30: 6×6 hard, ~28 arrows (78%)
  ..._range(26, 30,
      rows: 6, cols: 6, diff: Difficulty.hard, lives: 3, fill: 0.78),
  // Levels 31–35: 6×6 hard, ~32 arrows (89%)
  ..._range(31, 35,
      rows: 6, cols: 6, diff: Difficulty.hard, lives: 3, fill: 0.89),
  // Levels 36–40: 6×6 hard, ~34 arrows (94%) — almost full
  ..._range(36, 40,
      rows: 6, cols: 6, diff: Difficulty.hard, lives: 3, fill: 0.94),
  // Levels 41–45: 7×7 hard, ~34 arrows (70%)
  ..._range(41, 45,
      rows: 7, cols: 7, diff: Difficulty.hard, lives: 3, fill: 0.70),
  // Levels 46–50: 7×7 hard, ~40 arrows (82%)
  ..._range(46, 50,
      rows: 7, cols: 7, diff: Difficulty.hard, lives: 3, fill: 0.82),
  // Levels 51–55: 7×7 hard, ~44 arrows (90%)
  ..._range(51, 55,
      rows: 7, cols: 7, diff: Difficulty.hard, lives: 3, fill: 0.90),
  // Levels 56–60: 7×7 hard, ~46 arrows (94%)
  ..._range(56, 60,
      rows: 7, cols: 7, diff: Difficulty.hard, lives: 3, fill: 0.94),
  // Levels 61–65: 8×8 hard, ~46 arrows (72%)
  ..._range(61, 65,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.72),
  // Levels 66–70: 8×8 hard, ~54 arrows (84%)
  ..._range(66, 70,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.84),
  // Levels 71–75: 8×8 hard, ~58 arrows (90%)
  ..._range(71, 75,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.90),
  // Levels 76–80: 8×8 hard, ~60 arrows (94%)
  ..._range(76, 80,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.94),
  // Levels 81–90: 8×8 hard, ~62 arrows (97%)
  ..._range(81, 90,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.97),
  // Levels 91–100: 8×8 brutal — every cell filled (99%)
  ..._range(91, 100,
      rows: 8, cols: 8, diff: Difficulty.hard, lives: 3, fill: 0.99),
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
        seed: i * 31 + 7,
      ),
  ];
}

LevelDef? getLevelDef(int id) {
  final idx = id - 1;
  if (idx < 0 || idx >= kLevels.length) return null;
  return kLevels[idx];
}

int get totalLevels => kLevels.length;
