// onboarding.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/onboarding';

  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _catNameController = TextEditingController();

  // 현재 선택된 고양이 종(이름)
  String _selectedSpecies = ''; // 기본값 ''이면 아직 미선택 상태

  // 고양이 종(이름 + 이미지) 리스트
  final List<Map<String, String>> _catSpeciesList = [
    {'name': '회냥이', 'image': 'assets/images/cat/gray_cat.png'},
    {'name': '흰냥이', 'image': 'assets/images/cat/white_cat.png'},
    {'name': '갈냥이', 'image': 'assets/images/cat/brown_cat.png'},
    {'name': '아이보리냥이', 'image': 'assets/images/cat/ivory_cat.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 254, 244),
      appBar: AppBar(
        title: const Text('고양이 정보 입력'),
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // (1) 고양이 이름 입력
            TextField(
              controller: _catNameController,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: '고양이 이름',
                hintText: '고양이의 이름을 지어주세요🍀 (1~7자)',
                labelStyle: const TextStyle(color: Colors.black),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 108, 255, 160)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // (2) 안내 문구
            const Text(
              '고양이 종을 선택하세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // (3) GridView로 고양이 종 목록
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _catSpeciesList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 가로 2칸
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final species = _catSpeciesList[index];
                final name = species['name']!;
                final image = species['image']!;
                final bool isSelected = (name == _selectedSpecies);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecies = name;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromARGB(255, 185, 255, 210)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromARGB(255, 108, 255, 160)
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            image,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.black : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),

            // (4) 시작하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 108, 255, 160),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _onStartPressed,
                child: const Text(
                  '고양이 탄생 시키기🐱',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "시작하기" 버튼 누를 때
  void _onStartPressed() async {
    // 1) 고양이 이름 1~7자 검사
    final catName = _catNameController.text.trim();
    if (catName.isEmpty || catName.length < 1 || catName.length > 7) {
      _showErrorMessage('고양이 이름은 1~7자 이내로 입력해주세요.');
      return;
    }

    // 2) 고양이 종 선택 여부
    if (_selectedSpecies.isEmpty) {
      _showErrorMessage('고양이 종을 선택해주세요.');
      return;
    }

    // 3) SharedPreferences에 온보딩 정보 + 완료 상태 + 탄생일 저장
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('catName', catName);
    await prefs.setString('catSpecies', _selectedSpecies);
    await prefs.setBool('isOnboarded', true);

    // **탄생일 기록** (오늘 날짜)
    final DateTime now = DateTime.now();
    final String birthdayString = '${now.year}년 ${now.month}월 ${now.day}일';
    await prefs.setString('catBirthday', birthdayString);

    print('고양이 이름: $catName');
    print('고양이 종: $_selectedSpecies');
    print('탄생일: $birthdayString');

    // 4) 알림창(다이얼로그) 표시
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('축하합니다🥳'),
          content: Text('$birthdayString\n🐱$catName🐱가(이) 탄생했어요!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                // 이후 메인 화면으로 이동
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
