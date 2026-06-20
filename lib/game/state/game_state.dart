import '../../game/logic/grid_model.dart';

enum GameStatus { playing, won, outOfLives }

class GameState {
  final GridModel grid;
  final int lives;
  final int maxLives;
  final GameStatus status;
  final int levelId;
  final int? lastRemovedRow;
  final int? lastRemovedCol;
  final int? lastBlockedRow;
  final int? lastBlockedCol;
  final int? hintRow;
  final int? hintCol;
  final int hintsRemaining;
  final List<GridModel> undoStack;

  const GameState({
    required this.grid,
    required this.lives,
    required this.maxLives,
    required this.status,
    required this.levelId,
    required this.hintsRemaining,
    required this.undoStack,
    this.lastRemovedRow,
    this.lastRemovedCol,
    this.lastBlockedRow,
    this.lastBlockedCol,
    this.hintRow,
    this.hintCol,
  });

  int get starsEarned {
    if (status != GameStatus.won) return 0;
    if (lives >= maxLives) return 3;
    if (lives == maxLives - 1) return 2;
    if (lives > 0) return 1;
    return 0;
  }

  GameState copyWith({
    GridModel? grid,
    int? lives,
    int? maxLives,
    GameStatus? status,
    int? levelId,
    int? lastRemovedRow,
    int? lastRemovedCol,
    int? lastBlockedRow,
    int? lastBlockedCol,
    int? hintRow,
    int? hintCol,
    int? hintsRemaining,
    List<GridModel>? undoStack,
    bool clearHint = false,
    bool clearBlocked = false,
    bool clearRemoved = false,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      status: status ?? this.status,
      levelId: levelId ?? this.levelId,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      undoStack: undoStack ?? this.undoStack,
      lastRemovedRow: clearRemoved ? null : (lastRemovedRow ?? this.lastRemovedRow),
      lastRemovedCol: clearRemoved ? null : (lastRemovedCol ?? this.lastRemovedCol),
      lastBlockedRow: clearBlocked ? null : (lastBlockedRow ?? this.lastBlockedRow),
      lastBlockedCol: clearBlocked ? null : (lastBlockedCol ?? this.lastBlockedCol),
      hintRow: clearHint ? null : (hintRow ?? this.hintRow),
      hintCol: clearHint ? null : (hintCol ?? this.hintCol),
    );
  }
}
