//packages/flutter_suika_game/lib/presenter/prediction_line_presenter.dart
import 'package:flame/game.dart';
import 'package:flutter_suika_game/model/prediction_line.dart';

class PredictionLinePresenter {
  PredictionLinePresenter(this._predictionLineComponent);
  final PredictionLineComponent _predictionLineComponent;

  /// Update the prediction line.
  void updateLine(Vector2? newStart, Vector2? newEnd) {
    _predictionLineComponent.updateLine(newStart, newEnd);
  }
}
