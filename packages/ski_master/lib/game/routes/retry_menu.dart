// FILE: packages/ski_master/lib/game/routes/retry_menu.dart

import 'package:flutter/material.dart';

class RetryMenu extends StatelessWidget {
  const RetryMenu({
    super.key,
    required this.currentScore,
    this.onRetryPressed,
    this.onSettlePressed,
  });

  static const id = 'RetryMenu';

  final int currentScore;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onSettlePressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 229, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            Text(
              'Score: $currentScore',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onRetryPressed,
                child: const Text('Retry'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                onPressed: onSettlePressed,
                child: const Text('정산하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
