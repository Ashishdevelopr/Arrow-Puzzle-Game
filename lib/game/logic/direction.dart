enum Direction { up, down, left, right }

extension DirectionExtension on Direction {
  int get rowDelta {
    switch (this) {
      case Direction.up:
        return -1;
      case Direction.down:
        return 1;
      case Direction.left:
      case Direction.right:
        return 0;
    }
  }

  int get colDelta {
    switch (this) {
      case Direction.left:
        return -1;
      case Direction.right:
        return 1;
      case Direction.up:
      case Direction.down:
        return 0;
    }
  }

  String get symbol {
    switch (this) {
      case Direction.up:
        return '↑';
      case Direction.down:
        return '↓';
      case Direction.left:
        return '←';
      case Direction.right:
        return '→';
    }
  }
}
