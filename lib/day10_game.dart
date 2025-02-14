import 'package:flutter/material.dart';
import 'day.dart';
import 'status.dart';
import 'touch.dart';
import 'flameui.dart';

class Day10GameScreen extends StatelessWidget {
  const Day10GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 버튼 비활성화
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Day 10 Mini Game'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Mini Game Coming Soon!',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  dayManager.resetDay(); // D-day를 10으로 리셋
                  CatGame.instance?.updateDday(); // UI 업데이트
                },
                child: const Text('나가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
