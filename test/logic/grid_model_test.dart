import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle/game/logic/direction.dart';
import 'package:arrow_puzzle/game/logic/grid_model.dart';
import 'package:arrow_puzzle/game/logic/level_generator.dart';

void main() {
  group('isRemovable', () {
    test('arrow at edge pointing outward is always removable', () {
      final grid = GridModel(rows: 3, cols: 3);
      // Top-left pointing up
      grid.setCell(0, 0, Direction.up);
      expect(grid.isRemovable(0, 0), isTrue);

      // Bottom-right pointing down
      grid.setCell(2, 2, Direction.down);
      expect(grid.isRemovable(2, 2), isTrue);
    });

    test('arrow blocked by another arrow is not removable', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right);
      grid.setCell(0, 1, Direction.up); // blocker
      expect(grid.isRemovable(0, 0), isFalse);
    });

    test('arrow is removable when blocker is removed', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right);
      grid.setCell(0, 1, Direction.up);

      expect(grid.isRemovable(0, 0), isFalse);
      grid.removeArrow(0, 1); // remove the blocker
      expect(grid.isRemovable(0, 0), isTrue);
    });

    test('null cell is not removable', () {
      final grid = GridModel(rows: 3, cols: 3);
      expect(grid.isRemovable(1, 1), isFalse);
    });

    test('arrow pointing up: checks all cells above', () {
      final grid = GridModel(rows: 5, cols: 5);
      grid.setCell(4, 2, Direction.up);
      grid.setCell(2, 2, Direction.right); // blocker above
      expect(grid.isRemovable(4, 2), isFalse);
      grid.setCell(2, 2, null);
      expect(grid.isRemovable(4, 2), isTrue);
    });

    test('arrow pointing down: checks all cells below', () {
      final grid = GridModel(rows: 5, cols: 5);
      grid.setCell(0, 2, Direction.down);
      grid.setCell(3, 2, Direction.right); // blocker below
      expect(grid.isRemovable(0, 2), isFalse);
    });

    test('arrow pointing left: checks all cells to the left', () {
      final grid = GridModel(rows: 3, cols: 5);
      grid.setCell(1, 4, Direction.left);
      grid.setCell(1, 2, Direction.up); // blocker
      expect(grid.isRemovable(1, 4), isFalse);
    });

    test('arrow pointing right: checks all cells to the right', () {
      final grid = GridModel(rows: 3, cols: 5);
      grid.setCell(1, 0, Direction.right);
      grid.setCell(1, 3, Direction.up); // blocker
      expect(grid.isRemovable(1, 0), isFalse);
    });
  });

  group('removeArrow', () {
    test('returns true and clears cell when removable', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right);
      expect(grid.removeArrow(0, 0), isTrue);
      expect(grid.cells[0][0], isNull);
    });

    test('returns false and keeps cell when blocked', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right);
      grid.setCell(0, 1, Direction.up);
      expect(grid.removeArrow(0, 0), isFalse);
      expect(grid.cells[0][0], equals(Direction.right));
    });

    test('returns false on empty cell', () {
      final grid = GridModel(rows: 3, cols: 3);
      expect(grid.removeArrow(1, 1), isFalse);
    });
  });

  group('isCleared', () {
    test('empty grid is cleared', () {
      final grid = GridModel(rows: 3, cols: 3);
      expect(grid.isCleared, isTrue);
    });

    test('grid with arrows is not cleared', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(1, 1, Direction.up);
      expect(grid.isCleared, isFalse);
    });

    test('becomes cleared after all arrows removed', () {
      final grid = GridModel(rows: 2, cols: 2);
      grid.setCell(0, 0, Direction.right);
      grid.setCell(0, 1, Direction.down);
      grid.removeArrow(0, 1); // right col, pointing down, clear path
      grid.removeArrow(0, 0); // now clear
      expect(grid.isCleared, isTrue);
    });
  });

  group('remainingCount', () {
    test('counts arrows correctly', () {
      final grid = GridModel(rows: 3, cols: 3);
      expect(grid.remainingCount, 0);
      grid.setCell(0, 0, Direction.up);
      grid.setCell(1, 1, Direction.down);
      expect(grid.remainingCount, 2);
      grid.removeArrow(0, 0);
      expect(grid.remainingCount, 1);
    });
  });

  group('clone', () {
    test('clone is independent copy', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.up);
      final clone = grid.clone();
      clone.setCell(0, 0, null);
      expect(grid.cells[0][0], equals(Direction.up));
      expect(clone.cells[0][0], isNull);
    });
  });

  group('solve', () {
    test('solves a simple 2x2 grid in-place', () {
      final grid = GridModel(rows: 2, cols: 2);
      grid.setCell(0, 0, Direction.right);
      final moves = grid.solve();
      expect(moves.length, 1);
      expect(grid.isCleared, isTrue);
    });

    test('greedy solver always clears generated levels', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right);
      grid.setCell(1, 0, Direction.up);
      grid.setCell(2, 0, Direction.right);
      final working = grid.clone();
      final moves = working.solve();
      expect(moves.isNotEmpty, isTrue);
      expect(working.isCleared, isTrue);
    });
  });

  group('LevelGenerator — all generated levels are solvable', () {
    test('easy 4x4 levels — 100 seeds all solvable', () {
      const config = LevelConfig(
        rows: 4,
        cols: 4,
        difficulty: Difficulty.easy,
        lives: 3,
        fillRatio: 0.5,
      );
      for (int seed = 0; seed < 100; seed++) {
        final grid = LevelGenerator.generate(config, seed: seed);
        final working = grid.clone();
        working.solve();
        expect(
          working.isCleared,
          isTrue,
          reason: 'Seed $seed: easy 4x4 level not cleared by solver',
        );
      }
    });

    test('medium 5x5 levels — 100 seeds all solvable', () {
      const config = LevelConfig(
        rows: 5,
        cols: 5,
        difficulty: Difficulty.medium,
        lives: 3,
        fillRatio: 0.65,
      );
      for (int seed = 0; seed < 100; seed++) {
        final grid = LevelGenerator.generate(config, seed: seed);
        final working = grid.clone();
        working.solve();
        expect(
          working.isCleared,
          isTrue,
          reason: 'Seed $seed: medium 5x5 level not cleared by solver',
        );
      }
    });

    test('hard 6x6 levels — 100 seeds all solvable', () {
      const config = LevelConfig(
        rows: 6,
        cols: 6,
        difficulty: Difficulty.hard,
        lives: 3,
        fillRatio: 0.8,
      );
      for (int seed = 0; seed < 100; seed++) {
        final grid = LevelGenerator.generate(config, seed: seed);
        final working = grid.clone();
        working.solve();
        expect(
          working.isCleared,
          isTrue,
          reason: 'Seed $seed: hard 6x6 level not cleared by solver',
        );
      }
    });

    test('hard 8x8 levels — 50 seeds all solvable', () {
      const config = LevelConfig(
        rows: 8,
        cols: 8,
        difficulty: Difficulty.hard,
        lives: 3,
        fillRatio: 0.8,
      );
      for (int seed = 0; seed < 50; seed++) {
        final grid = LevelGenerator.generate(config, seed: seed);
        final working = grid.clone();
        working.solve();
        expect(
          working.isCleared,
          isTrue,
          reason: 'Seed $seed: hard 8x8 level not cleared by solver',
        );
      }
    });
  });

  group('removableArrows', () {
    test('returns all currently removable arrows', () {
      final grid = GridModel(rows: 3, cols: 3);
      grid.setCell(0, 0, Direction.right); // blocked by (0,1)
      grid.setCell(0, 1, Direction.up);   // edge arrow, removable
      grid.setCell(1, 0, Direction.up);   // removable (clear up)
      final removable = grid.removableArrows();
      // (0,1) pointing up: row 0, no cells above → removable
      // (1,0) pointing up: (0,0) has an arrow → blocked
      // (0,0) pointing right: (0,1) has arrow → blocked
      expect(removable.length, 1);
      expect(removable.first.x, 0);
      expect(removable.first.y, 1);
    });
  });
}
