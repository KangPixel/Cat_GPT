//onboarding_slides

import 'package:flutter/material.dart';

class OnboardingSlides extends StatefulWidget {
  static const routeName = '/onboarding_slides';

  const OnboardingSlides({Key? key}) : super(key: key);

  @override
  State<OnboardingSlides> createState() => _OnboardingSlidesState();
}

class _OnboardingSlidesState extends State<OnboardingSlides> {
  final PageController _pageController = PageController(); 
  int _currentPage = 0;

  // 5장 구성
  final List<_SlideData> _slides = [
    _SlideData(
      image: 'assets/images/onboarding1.png',
      title: '환영합니다!🍀',
      description: '당신만의 특별한 고양이 키우기 게임!\n귀여운 고양이와 함께 즐거운 시간을 보내보세요.',
    ),
    _SlideData(
      image: 'assets/images/onboarding2.png',
      title: '기본 조작',
      description: 
                '① 고양이 버튼: 고양이의 에너지 상태를 확인할 수 있습니다.\n'
                '② 밥 주기: 고양이의 에너지를 회복시킵니다.\n'
                '③ 잠자기: 고양이의 피로도를 낮추고 에너지를 회복합니다.\n'
                '④ 놀아주기: 고양이와 미니게임을 즐길 수 있습니다.\n'
                '⑤ 대화하기: 고양이와 대화를 나눌 수 있습니다.',
    ),
    _SlideData(
      image: 'assets/images/onboarding3.png',
      title: '상태 관리',
      description:                 
                '• 에너지: 활동에 필요한 기본 자원입니다.\n'
                '• 피로도: 높아지면 에너지 회복이 불가능합니다.\n'
                '• 친밀도: 고양이 밥주기 & 대화로 높일 수 있습니다.',
    ),
    _SlideData(
      image: 'assets/images/onboarding4.png',
      title: '미니 게임',
      description:
                '• 에너지가 50% 이상일 때 플레이 가능\n'
                '• 미니게임 성공 시 포인트 획득! 원하는 스탯에 분배해 주세요.\n'
                '• 다양한 게임을 즐길 수 있습니다!',
    ),
    _SlideData(
      image: 'assets/images/onboarding5.png',
      title: '팁',
      description: 
                '• 하루에 세번까지 밥주기를 통해 친밀도를 높일 수 있습니다.\n'
                '• 잠을 자면 피로도가 낮아집니다.\n'
                '• 취침 후에는 친밀도가 리셋됩니다.\n'
                '• 10일이 지나 D-Day가 되면 특별한 경기를 한답니다!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단바나 배경색 설정은 필요에 따라 추가
      body: SafeArea(
        child: Column(
          children: [
            // 상단 "건너뛰기" 버튼 (원한다면 사용)
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  // 바로 마지막 페이지로 건너뛰기
                  _pageController.jumpToPage(_slides.length - 1);
                },
                child: const Text('건너뛰기'),
              ),
            ),

            // 중앙의 PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlide(slide);
                },
              ),
            ),

            // 하단 인디케이터 + 다음/고양이 만들기 버튼
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  /// 각 페이지(슬라이드) 레이아웃
  Widget _buildSlide(_SlideData data) {
  // 왼쪽 정렬할 타이틀 목록
  final leftAlignTitles = [
    '기본 조작',
    '상태 관리',
    '미니 게임',
    '팁',
  ];

  // 해당 타이틀이면 왼쪽 정렬, 아니면 기본(가령 center)
  final isLeftAlign = leftAlignTitles.contains(data.title);
  final textAlignment = isLeftAlign ? TextAlign.left : TextAlign.center;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            data.image,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data.title,
          style: const TextStyle(fontFamily: 'Pretendard',fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          data.description,
          textAlign: textAlignment, // 여기서 조건부로 왼쪽 혹은 기본 정렬
          style: const TextStyle(fontFamily: 'Pretendard',fontSize: 16, color: Colors.black87),
        ),
        const SizedBox(height: 40),
      ],
    ),
  );
}


  /// 하단 인디케이터와 버튼
  Widget _buildBottomControls() {
    final isLastPage = (_currentPage == _slides.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 인디케이터
          Row(
            children: List.generate(
              _slides.length,
              (index) => _buildIndicator(index == _currentPage),
            ),
          ),
          // "다음" 또는 "고양이 만들기" 버튼
          ElevatedButton(
            onPressed: isLastPage ? _goToOnboardingScreen : _goToNextPage,
            child: Text(isLastPage ? '고양이 만들기' : '다음'),
          ),
        ],
      ),
    );
  }

  /// 동그란 인디케이터
  Widget _buildIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 16 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  /// 다음 페이지로 이동
  void _goToNextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 마지막 페이지의 "고양이 만들기" 버튼 -> OnboardingScreen으로 이동
  void _goToOnboardingScreen() {
    // 이미 main.dart의 routes에서 '/onboarding'를 OnboardingScreen으로 매핑해둬야 함
    Navigator.pushNamed(context, '/onboarding');
  }
}

/// 내부에서 쓸 슬라이드 데이터 모델
class _SlideData {
  final String image;
  final String title;
  final String description;

  _SlideData({
    required this.image,
    required this.title,
    required this.description,
  });
}
