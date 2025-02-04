//packages/flutter_suika_game/lib/presenter/dialog_presenter.dart
import 'package:flutter/material.dart';
import 'package:flutter_suika_game/domain/game_state.dart';
import 'package:flutter_suika_game/route/navigator_key.dart';
import 'package:flutter_suika_game/src/suika_manager.dart';
import 'package:get_it/get_it.dart';

class DialogPresenter {
  Future<void> showGameOverDialog(BuildContext context, int score) async {
    final currentContext = navigatorKey.currentContext;
    if (currentContext == null) return;

    // computeSuikaOutcome의 결과를 Map으로 반환
    final outcome = computeSuikaOutcome('Suika Game', suikaGameManager);
    final result = {
      'gameName': outcome.gameName,
      'totalScore': score,
      'fatigueIncrease': outcome.fatigueIncrease,
      'pointsEarned': outcome.pointsEarned,
      'fatigueMessage': outcome.fatigueMessage,
    };

    // 게임창 닫고 결과 전달
    Navigator.of(context).pop(result);

    // 게임 상태 리셋
    suikaGameManager.resetSession();
    GetIt.I.get<GameState>().reset();
  }
}
