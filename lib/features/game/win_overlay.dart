import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class WinOverlay extends StatefulWidget {
  final int stars;
  final int levelId;
  final VoidCallback onNext;
  final VoidCallback onHome;
  final VoidCallback onReplay;

  const WinOverlay({
    super.key,
    required this.stars,
    required this.levelId,
    required this.onNext,
    required this.onHome,
    required this.onReplay,
  });

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay> with TickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;
  final List<AnimationController> _starCtrls = [];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack);

    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      _starCtrls.add(ctrl);
    }

    _scaleCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _confetti.play();
      for (int i = 0; i < 3; i++) {
        Future.delayed(Duration(milliseconds: 300 + i * 150), () {
          if (mounted) _starCtrls[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _scaleCtrl.dispose();
    for (final c in _starCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: () {},
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            colors: const [
              AppColors.accent,
              AppColors.starGold,
              Colors.white,
              Color(0xFF3FB6A8),
            ],
          ),
        ),

        // Card
        Center(
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadii.card),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level Complete!',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Level ${widget.levelId}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _starCtrls[i],
                              curve: Curves.easeOutBack,
                            ),
                            child: Icon(
                              i < widget.stars ? Icons.star : Icons.star_border,
                              color: i < widget.stars
                                  ? AppColors.starGold
                                  : AppColors.starEmpty,
                              size: 44,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      child: const Text('Next Level'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onReplay,
                          child: const Text('Replay'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onHome,
                          child: const Text('Home'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
