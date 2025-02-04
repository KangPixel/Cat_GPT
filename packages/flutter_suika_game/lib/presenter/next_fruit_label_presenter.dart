// lib/presenter/next_fruit_label_presenter.dart
import 'package:flame/game.dart';
import 'package:flutter_suika_game/model/fruit.dart';
import 'package:flutter_suika_game/ui/next_fruit_label.dart';

class NextFruitLabelPresenter {
  NextFruitLabelPresenter(this._nextFruitLabel);
  final NextFruitLabel _nextFruitLabel;

  set position(Vector2 position) {
    _nextFruitLabel.position = position;
  }

  Vector2 get position => _nextFruitLabel.position;

  /// Fruit 객체를 받아 화면에 표시되는 텍스트를 업데이트합니다.
  void updateFruit(Fruit fruit) {
    _nextFruitLabel.updateFruit(fruit);
  }
}
