import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/storage/progress_store.dart';
import '../../game/state/game_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ProgressStore? _store;
  bool _sound = true;
  bool _haptics = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await ProgressStore.load();
    setState(() {
      _store = store;
      _sound = store.soundEnabled;
      _haptics = store.hapticsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _store == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _SettingsTile(
                  title: 'Sound Effects',
                  subtitle: 'Pop and feedback sounds',
                  value: _sound,
                  onChanged: (v) {
                    setState(() => _sound = v);
                    _store!.soundEnabled = v;
                    ref.read(audioServiceProvider).setSoundEnabled(v);
                  },
                ),
                _SettingsTile(
                  title: 'Haptics',
                  subtitle: 'Vibration feedback',
                  value: _haptics,
                  onChanged: (v) {
                    setState(() => _haptics = v);
                    _store!.hapticsEnabled = v;
                    ref.read(hapticServiceProvider).setEnabled(v);
                  },
                ),
                const Divider(height: AppSpacing.xl),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
                  title: const Text('Reset Progress'),
                  subtitle: const Text('Delete all level data'),
                  onTap: () => _confirmReset(context),
                ),
                const Divider(height: AppSpacing.xl),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  onTap: () {},
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    'Arrow Puzzle v1.0.0',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will delete all your level progress and stars.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _store!.resetProgress();
              if (context.mounted) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeColor: AppColors.accent,
      onChanged: onChanged,
    );
  }
}
