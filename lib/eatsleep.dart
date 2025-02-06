// eatsleep.dart
import 'package:flutter/material.dart';
import 'flameui.dart';
import 'status.dart';
import 'touch.dart';
import 'day.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 고양이가 음식을 먹는 중인지 체크하는 변수
bool isEating = false;

// 🍽️ [먹기 기능] 고양이가 음식을 먹는 액션을 수행하는 함수
void eatAction(BuildContext context) {
  if (isEating) return; // 이미 먹고 있으면 동작하지 않음
  isEating = true; // 먹기 시작

  // 친밀도가 5 이상이어야 먹을 수 있음
  if (catStatus.intimacy.value >= 5) {
    // 에너지가 100 미만일 때만 먹기 가능
    if (catStatus.energy.value < 100) {
      // 생선 이미지를 화면에 표시
      _showFishOverlay(context);

      // 🐱 고양이 스프라이트(이미지) 변경 (입 벌리기 -> 원래 상태)
      if (CatGame.instance != null) {
        catStatus.catSprite.value = CatGame.instance?.openMouthSprite;
        Future.delayed(const Duration(milliseconds: 600), () {
          catStatus.catSprite.value = CatGame.instance?.normalSprite;
          isEating = false; // 다시 먹을 수 있도록 상태 초기화
        });
      } else {
        print("CatGame instance is not available.");
      }

      debugPrint('Eat success! Energy increased by 30');
      catStatus.updateStatus(energyDelta: 30); // 에너지 +30 증가
    } else {
      debugPrint("Energy is full! Please press when you are low on energy.");
    }
  } else {
    debugPrint("Intimacy too low to eat! Need intimacy level 5 or higher");
  }
}

// 🐟 [먹기 연출] 생선 이미지를 화면에 잠시 표시하는 함수
void _showFishOverlay(BuildContext context) {
  OverlayState overlayState = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.55, // 고양이 입 근처 위치
      left: MediaQuery.of(context).size.width * 0.35, // 중앙 위치 조정
      child: Image.asset(
        'assets/images/fish.png',  // 생선 이미지 경로
        width: 100,
        height: 100,
      ),
    ),
  );

  // 오버레이 추가
  overlayState.insert(overlayEntry);

  // 0.6초 후 오버레이 제거
  Future.delayed(const Duration(milliseconds: 600), () {
    overlayEntry.remove();
  });
}

// 🌙 [수면 연출] 우주 배경으로 페이드 인/아웃하는 오버레이 위젯
class SleepTransitionOverlay extends StatefulWidget {
  final VoidCallback onTransitionComplete; // 애니메이션 완료 후 실행할 함수

  const SleepTransitionOverlay({
    Key? key,
    required this.onTransitionComplete,
  }) : super(key: key);

  @override
  _SleepTransitionOverlayState createState() => _SleepTransitionOverlayState();
}

class _SleepTransitionOverlayState extends State<SleepTransitionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  String _selectedCatImage = 'gray_cat';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedCatImage();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _animationController.forward();

    // Add listener to trigger completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isDisposed) {
        widget.onTransitionComplete();
      }
    });
  }

  Future<void> _loadSelectedCatImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 선택한 고양이 종에 맞는 이미지 파일 매핑
      final Map<String, String> catImages = {
        '회냥이': 'gray_cat',
        '흰냥이': 'white_cat',
        '갈냥이': 'brown_cat',
        '아이보리냥이': 'ivory_cat',
      };

      String selectedCat = prefs.getString('selectedCat') ?? '회냥이';
      if (!_isDisposed) {
        setState(() {
          _selectedCatImage = catImages[selectedCat] ?? 'gray_cat';
        });
      }
    } catch (e) {
      print('Error loading cat image: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Space background
                Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Image.asset(
                    'assets/images/space_background.png',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.6),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),

                // Cat and Nightcap Container
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 고양이 이미지의 크기 설정
                      final catSize = constraints.maxWidth * 0.6; // 화면 너비의 60%
                      
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Cat Image
                          SizedBox(
                            width: catSize,
                            height: catSize,
                            child: Image.asset(
                              'assets/images/cat/${_selectedCatImage}_sleep.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          
                          // Nightcap Image
                          Positioned(
                            top: -(catSize * 0.24), // 고양이 크기의 24% 만큼 위로
                            left: catSize * 0.33,   // 고양이 크기의 33% 만큼 왼쪽으로
                            child: SizedBox(
                              width: catSize * 0.4,  // 고양이 크기의 40%
                              height: catSize * 0.4,
                              child: Image.asset(
                                'assets/images/nightcap.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🛌 [자기 기능] 수면 연출을 적용한 후 상태 초기화 및 날짜 변경
void sleepAction(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // 배경이 투명한 페이지로 이동
      pageBuilder: (context, _, __) {
        return SleepTransitionOverlay(
          onTransitionComplete: () {
            // 💤 수면 후 상태 업데이트
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Perform sleep actions after transition
              catStatus.energy.value = 40;
              catStatus.resetFatigue();
              touchManager.resetTouchCount();
              
              // Pop the transition overlay
              Navigator.of(context).pop();
              
              dayManager.onSleep(context);
            });
          },
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}