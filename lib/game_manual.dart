// game_manual.dart
import 'package:flutter/material.dart';

class GameManualPage extends StatelessWidget {
  const GameManualPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '게임 설명',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan[50],
      ),
      body: Container(
        color: Colors.cyan[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildManualSection(
                '게임 소개',
                '당신만의 특별한 고양이 키우기 게임!\n귀여운 고양이와 함께 즐거운 시간을 보내보세요.',
                Icons.pets,
              ),
              const SizedBox(height: 20),
              _buildManualSection(
                '기본 조작',
                '• 고양이 버튼: 고양이의 에너지 상태를 확인할 수 있습니다.\n'
                '• 밥 주기: 고양이의 에너지를 회복시킵니다.\n'
                '• 잠자기: 고양이의 피로도를 낮추고 에너지를 회복합니다.\n'
                '• 놀아주기: 고양이와 미니게임을 즐길 수 있습니다.\n'
                '• 대화하기: 고양이와 대화를 나눌 수 있습니다.',
                Icons.touch_app,
              ),
              const SizedBox(height: 20),
              _buildManualSection(
                '상태 관리',
                '• 에너지: 활동에 필요한 기본 자원입니다.\n'
                '• 피로도: 높아진 피로도는 취침으로 회복합니다.\n'
                '• 친밀도: 밥주기 & 대화로 높일 수 있습니다.',
                Icons.show_chart,
              ),
              const SizedBox(height: 20),
              _buildManualSection(
                '미니게임',
                '• 에너지가 50% 이상일 때 플레이 가능\n'
                '• 미니게임 성공 시 포인트 획득! 원하는 스탯에 분배해 주세요.\n'
                '• 다양한 게임을 즐길 수 있습니다!',
                Icons.videogame_asset,
              ),
              const SizedBox(height: 20),
              _buildManualSection(
                '레이싱',
                '• 10일이 지나면 플레이 가능\n'
                '• 10일동안 미니게임으로 단련시킨 스탯으로 달리게 됩니다.\n'
                '• 레이싱에서 1등을 노려보세요!',
                Icons.stars,
              ),
              const SizedBox(height: 20),
              _buildManualSection(
                '팁',
                '• 하루에 세번까지 밥주기를 통해 친밀도를 높일 수 있습니다.\n'
                '• 잠을 자면 피로도가 낮아집니다.\n'
                '• 취침 후에는 친밀도가 리셋됩니다.\n'
                '• 10일이 지나 D-Day가 되면 특별한 경기를 한답니다!',
                Icons.lightbulb,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 187, 210),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color.fromARGB(255, 255, 187, 210),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}