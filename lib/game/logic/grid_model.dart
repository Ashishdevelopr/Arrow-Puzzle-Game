import 'dart:math';
import 'direction.dart';

class GridModel {
  final int rows;
  final int cols;
  List<List<Direction?>> cells;

  GridModel({required this.rows, required this.cols})
      : cells = List.generate(rows, (_) => List.filled(cols, null));

  GridModel._fromCells({
    required this.rows,
    required this.cols,
    required this.cells,
  });

  /// True if the arrow at (r,c) can escape in its direction — path to edge is all empty.
  bool isRemovable(int r, int c) {
    final dir = cells[r][c];
    if (dir == null) return false;

    int nr = r + dir.rowDelta;
    int nc = c + dir.colDelta;
    while (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
      if (cells[nr][nc] != null) return false;
      nr += dir.rowDelta;
      nc += dir.colDelta;
    }
    return true;
  }

  /// All cells currently removable.
  List<Point<int>> removableArrows() {
    final result = <Point<int>>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c] != null && isRemovable(r, c)) {
          result.add(Point(r, c));
        }
      }
    }
    return result;
  }

  /// Remove arrow at (r,c). Returns true if removed, false if blocked.
  bool removeArrow(int r, int c) {
    if (!isRemovable(r, c)) return false;
    cells[r][c] = null;
    return true;
  }

  bool get isCleared {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c] != null) return false;
      }
    }
    return true;
  }

  int get remainingCount {
    int count = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (cells[r][c] != null) count++;
      }
    }
    return count;
  }

  GridModel clone() {
    return GridModel._fromCells(
      rows: rows,
      cols: cols,
      cells: List.generate(rows, (r) => List.from(cells[r])),
    );
  }

  /// Greedy solver — removes any removable arrow in-place until cleared or stuck.
  /// Returns the ordered move list. For validation, call on a clone().
  List<Point<int>> solve() {
    final moves = <Point<int>>[];
    while (!isCleared) {
      final removable = removableArrows();
      if (removable.isEmpty) break;
      final move = removable.first;
      removeArrow(move.x, move.y);
      moves.add(move);
    }
    return moves;
  }

  void setCell(int r, int c, Direction? dir) {
    cells[r][c] = dir;
  }

  @override
  String toString() {
    final sb = StringBuffer();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        sb.write(cells[r][c]?.symbol ?? '.');
        sb.write(' ');
      }
      sb.write('\n');
    }
    return sb.toString();
  }
}
