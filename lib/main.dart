import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_slides.dart';
import 'onboarding.dart';
import 'flameui.dart';
import 'chat.dart';
import 'status.dart';
import 'day.dart';
import 'touch.dart';
import 'eatsleep.dart';
import 'day10_game.dart';
import 'game_screen.dart';
import 'play.dart';
import 'copyright.dart';
import 'game_manual.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  // 5초 지연
  await Future.delayed(const Duration(seconds: 5));
  
  // 스플래시 제거
  debugPrint('remove Splash');
  FlutterNativeSplash.remove();

  // 온보딩 여부 체크
  final prefs = await SharedPreferences.getInstance();
  final isOnboarded = prefs.getBool('isOnboarded') ?? false;

  runApp(MyApp(isOnboarded: isOnboarded));
}

class MyApp extends StatelessWidget {
  final bool isOnboarded;
  const MyApp({Key? key, required this.isOnboarded}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat Game',
      initialRoute: isOnboarded ? '/' : '/onboarding_slides',
      routes: {
        '/onboarding_slides': (context) => const OnboardingSlides(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/': (context) => GameScreen(),
        '/chat': (context) => const ChatScreen(),
        '/day10Game': (context) => const Day10GameScreen(),
        '/play': (context) => const PlayScreen(),
        '/copyright': (context) => const CopyrightPage(),
        '/manual': (context) => const GameManualPage(),
      },
    );
  }
}
