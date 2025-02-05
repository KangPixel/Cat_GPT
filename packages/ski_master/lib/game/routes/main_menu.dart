//packages/ski_master/lib/game/routes/main_menu.dart
import 'package:flutter/material.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    this.onPlayPressed,
    this.onSettingsPressed,
  });

  static const id = 'MainMenu';

  final VoidCallback? onPlayPressed;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ski.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ski Master',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white, // 배경이 있으므로 텍스트 색상 변경
                  shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: onPlayPressed,
                  child: const Text('Play'),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 150,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                  ),
                  onPressed: onSettingsPressed,
                  child: const Text('Settings'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
