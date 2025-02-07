// FILE: packages/ski_master/lib/game/routes/main_menu.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';

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
    return WillPopScope(
      onWillPop: () async {
        // 메인 메뉴에서 뒤로가기가 안되는 이슈를 해결하려면,
        // 'return true' 나 SystemNavigator.pop() 등을 써야 합니다.
        final game = context.findAncestorWidgetOfExactType<GameWidget>();
        if (game != null) {
          await Navigator.of(context).maybePop();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                    color: Colors.white,
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
      ),
    );
  }
}
