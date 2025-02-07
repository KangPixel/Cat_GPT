//packages/ski_master/lib/game/routes/settings.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({
    super.key,
    required this.musicValueListenable,
    required this.sfxValueListenable,
    required this.musicVolumeListenable,
    this.onMusicValueChanged,
    this.onSfxValueChanged,
    this.onMusicVolumeChanged,
    this.onBackPressed,
  });

  static const id = 'Settings';

  final ValueListenable<bool> musicValueListenable;
  final ValueListenable<bool> sfxValueListenable;
  final ValueListenable<double> musicVolumeListenable;
  final ValueChanged<bool>? onMusicValueChanged;
  final ValueChanged<bool>? onSfxValueChanged;
  final ValueChanged<double>? onMusicVolumeChanged;
  final VoidCallback? onBackPressed;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 200,
              child: ValueListenableBuilder<bool>(
                valueListenable: musicValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onMusicValueChanged,
                    title: child,
                  );
                },
                child: const Text('Music'),
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: musicValueListenable,
              builder: (context, musicEnabled, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: musicVolumeListenable,
                  builder: (context, volume, _) {
                    return SizedBox(
                      width: 200,
                      child: Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(volume * 100).round()}%',
                        onChanged: musicEnabled ? onMusicVolumeChanged : null,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 200,
              child: ValueListenableBuilder<bool>(
                valueListenable: sfxValueListenable,
                builder: (BuildContext context, bool value, Widget? child) {
                  return SwitchListTile(
                    value: value,
                    onChanged: onSfxValueChanged,
                    title: child,
                  );
                },
                child: const Text('Sfx'),
              ),
            ),
            const SizedBox(height: 5),
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          ],
        ),
      ),
    );
  }
}
