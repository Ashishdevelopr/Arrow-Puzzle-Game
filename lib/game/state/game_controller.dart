import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/haptics/haptic_service.dart';
import '../../core/audio/audio_service.dart';
import '../../data/levels.dart';
import '../../game/logic/grid_model.dart';
import '../../game/logic/level_generator.dart';
import 'game_state.dart';

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final gameControllerProvider =
    StateNotifierProvider<GameController, GameState?>((ref) {
  return GameController(
    ref.read(hapticServiceProvider),
    ref.read(audioServiceProvider),
  );
});

class GameController extends StateNotifier<GameState?> {
  final HapticService _haptics;
  final AudioService _audio;

  // Forgiveness window
  DateTime? _blockedAt;
  static const _forgivenessMs = 800;

  GameController(this._haptics, this._audio) : super(null);

  void loadLevel(int levelId, {int? hintsOverride}) {
    final def = getLevelDef(levelId);
    if (def == null) return;

    final grid = LevelGenerator.generate(def.config, seed: def.seed);
    state = GameState(
      grid: grid,
      lives: def.lives,
      maxLives: def.lives,
      status: GameStatus.playing,
      levelId: levelId,
      hintsRemaining: hintsOverride ?? 3,
      undoStack: [],
    );
    _blockedAt = null;
  }

  void loadCustomGrid(GridModel grid, {int lives = 3, int levelId = 0}) {
    state = GameState(
      grid: grid,
      lives: lives,
      maxLives: lives,
      status: GameStatus.playing,
      levelId: levelId,
      hintsRemaining: 3,
      undoStack: [],
    );
  }

  void tapCell(int r, int c) {
    final s = state;
    if (s == null || s.status != GameStatus.playing) return;
    if (s.grid.cells[r][c] == null) return; // empty cell — ignore

    final snapshot = s.grid.clone();
    final removed = s.grid.removeArrow(r, c);

    if (removed) {
      _haptics.light();
      _audio.playPop();

      // Forgiveness: if this tap is within window of a blocked tap, no life was lost
      _blockedAt = null;

      final newStack = [...s.undoStack, snapshot];
      final newStatus = s.grid.isCleared ? GameStatus.won : GameStatus.playing;

      if (newStatus == GameStatus.won) {
        _haptics.success();
        _audio.playWin();
      }

      state = s.copyWith(
        grid: s.grid,
        status: newStatus,
        lastRemovedRow: r,
        lastRemovedCol: c,
        undoStack: newStack,
        clearBlocked: true,
        clearHint: true,
      );
    } else {
      // Blocked tap — check forgiveness
      final now = DateTime.now();
      final prevBlocked = _blockedAt;
      bool forgiving = prevBlocked != null &&
          now.difference(prevBlocked).inMilliseconds < _forgivenessMs;

      _haptics.medium();
      _audio.playThud();

      // Only deduct life if not in forgiveness window (but update window)
      int newLives = forgiving ? s.lives : s.lives - 1;

      _blockedAt = now;

      final newStatus = newLives <= 0 ? GameStatus.outOfLives : GameStatus.playing;
      if (newStatus == GameStatus.outOfLives) _haptics.heavy();

      state = s.copyWith(
        lives: newLives,
        status: newStatus,
        lastBlockedRow: r,
        lastBlockedCol: c,
        clearRemoved: true,
        clearHint: true,
      );
    }
  }

  void useHint() {
    final s = state;
    if (s == null || s.status != GameStatus.playing) return;
    if (s.hintsRemaining <= 0) return;

    final removable = s.grid.removableArrows();
    if (removable.isEmpty) return;

    final hint = removable.first;
    state = s.copyWith(
      hintsRemaining: s.hintsRemaining - 1,
      hintRow: hint.x,
      hintCol: hint.y,
    );
  }

  void clearHint() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(clearHint: true);
  }

  void undo() {
    final s = state;
    if (s == null || s.undoStack.isEmpty) return;
    final prev = s.undoStack.last;
    state = s.copyWith(
      grid: prev,
      undoStack: s.undoStack.sublist(0, s.undoStack.length - 1),
      status: GameStatus.playing,
      clearBlocked: true,
      clearHint: true,
    );
  }

  void restart() {
    final s = state;
    if (s == null) return;
    loadLevel(s.levelId, hintsOverride: s.hintsRemaining);
  }

  void clearBlockedFeedback() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(clearBlocked: true);
  }
}
