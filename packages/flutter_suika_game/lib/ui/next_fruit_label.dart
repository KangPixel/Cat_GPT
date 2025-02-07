// packages/flutter_suika_game/lib/ui/next_fruit_label.dart

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_suika_game/model/fruit.dart';

/// 다음 나올 과일의 이름을 표시하는 컴포넌트
class NextFruitLabel extends TextComponent {
  // fruit.image 별 글자색 맵핑
  static final Map<String, Color> fruitImageColorMap = {
    'cherry.png': Colors.red, // 체리=빨강
    'strawberry.png': Colors.pink, // 딸기=분홍
    'grape.png': Colors.blue, // 포도=파랑
    'kaki.png': Colors.orange, // 감=주황
    'orange.png': Colors.yellow, // 오렌지=노랑
  };

  NextFruitLabel({String? initialText})
      : super(
          text: initialText ?? "Next",
          // 기본 TextPaint
          textRenderer: TextPaint(
            style: const TextStyle(
              fontSize: 15, // 글자 크기 작게
              color: Colors.white,
            ),
          ),
        );

  /// 과일 정보에 따라 라벨의 텍스트와 색상을 업데이트
  void updateFruit(Fruit fruit) {
    // 과일 이름
    final fruitName = _getFruitName(fruit);
    text = "Next: $fruitName";

    // fruit.image 값에 따른 색상(못찾으면 기본 흰색)
    final color = fruitImageColorMap[fruit.image] ?? Colors.white;

    // 텍스트 페인트를 과일 색으로 교체
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: 18, // 작게
        color: color,
      ),
    );
  }

  String _getFruitName(Fruit fruit) {
    // 예: "cherry.png" -> "Cherry"
    String name = fruit.image.split('.').first;
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
    }
    return name;
  }
}
