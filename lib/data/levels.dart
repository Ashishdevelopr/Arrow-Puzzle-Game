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

// 100 levels: 10 easy warmup → progressively dense medium/hard mazes
final List<LevelDef> kLevels = [
  // ── EASY warmup (levels 1–10) ──────────────────────────────────────────
  // Levels 1–5: 4×4, light (~8 arrows) — intro mechanics
  ..._range(1, 5,   rows: 4, cols: 4, diff: Difficulty.easy,   lives: 5, fill: 0.50),
  // Levels 6–10: 4×4, a bit denser (~10 arrows) — still easy
  ..._range(6, 10,  rows: 4, cols: 4, diff: Difficulty.easy,   lives: 4, fill: 0.62),

  // ── MEDIUM density ramp (levels 11–30) ─────────────────────────────────
  // Levels 11–15: 5×5 medium (~16 arrows)
  ..._range(11, 15, rows: 5, cols: 5, diff: Difficulty.medium, lives: 3, fill: 0.65),
  // Levels 16–20: 5×5 medium denser (~18 arrows)
  ..._range(16, 20, rows: 5, cols: 5, diff: Difficulty.medium, lives: 3, fill: 0.72),
  // Levels 21–25: 6×6 medium (~24 arrows)
  ..._range(21, 25, rows: 6, cols: 6, diff: Difficulty.medium, lives: 3, fill: 0.67),
  // Levels 26–30: 6×6 medium denser (~28 arrows)
  ..._range(26, 30, rows: 6, cols: 6, diff: Difficulty.medium, lives: 3, fill: 0.74),

  // ── HARD dense maze (levels 31–60) ─────────────────────────────────────
  // Levels 31–35: 5×5 hard packed (~22 arrows)
  ..._range(31, 35, rows: 5, cols: 5, diff: Difficulty.hard,   lives: 3, fill: 0.88),
  // Levels 36–40: 6×6 hard (~30 arrows)
  ..._range(36, 40, rows: 6, cols: 6, diff: Difficulty.hard,   lives: 3, fill: 0.82),
  // Levels 41–45: 6×6 hard packed (~33 arrows)
  ..._range(41, 45, rows: 6, cols: 6, diff: Difficulty.hard,   lives: 3, fill: 0.90),
  // Levels 46–50: 7×7 hard (~38 arrows)
  ..._range(46, 50, rows: 7, cols: 7, diff: Difficulty.hard,   lives: 3, fill: 0.78),
  // Levels 51–55: 7×7 hard denser (~43 arrows)
  ..._range(51, 55, rows: 7, cols: 7, diff: Difficulty.hard,   lives: 3, fill: 0.88),
  // Levels 56–60: 7×7 near-full (~46 arrows)
  ..._range(56, 60, rows: 7, cols: 7, diff: Difficulty.hard,   lives: 3, fill: 0.95),

  // ── BRUTAL 8×8 mazes (levels 61–100) ───────────────────────────────────
  // Levels 61–65: 8×8 hard (~50 arrows)
  ..._range(61, 65, rows: 8, cols: 8, diff: Difficulty.hard,   lives: 3, fill: 0.78),
  // Levels 66–70: 8×8 hard denser (~55 arrows)
  ..._range(66, 70, rows: 8, cols: 8, diff: Difficulty.hard,   lives: 3, fill: 0.86),
  // Levels 71–75: 8×8 very dense (~58 arrows)
  ..._range(71, 75, rows: 8, cols: 8, diff: Difficulty.hard,   lives: 3, fill: 0.90),
  // Levels 76–80: 8×8 near-full (~60 arrows)
  ..._range(76, 80, rows: 8, cols: 8, diff: Difficulty.hard,   lives: 3, fill: 0.94),
  // Levels 81–90: 8×8 maximum density (~62 arrows)
  ..._range(81, 90, rows: 8, cols: 8, diff: Difficulty.hard,   lives: 3, fill: 0.97),
  // Levels 91–100: 8×8 brutal — almost every cell filled
  ..._range(91, 100, rows: 8, cols: 8, diff: Difficulty.hard,  lives: 3, fill: 0.99),
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
