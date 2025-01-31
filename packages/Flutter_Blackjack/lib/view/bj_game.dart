//bj_game.dart
import 'package:flutter/material.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';
import 'package:flutter_blackjack_pkg/widgets/card.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart';

class BlackJackGame extends StatefulWidget {
  final GameService gameService;
  const BlackJackGame({Key? key, required this.gameService}) : super(key: key);
  @override
  State<BlackJackGame> createState() => _BlackJackGameState();
}

class _BlackJackGameState extends State<BlackJackGame> {
  final List<int> betOptions = [500, 1000, 2000, 5000, 10000];
  bool _isSettling = false;
  bool _hasGameStarted = false;

  @override
  void initState() {
    super.initState();
    // 저장된 상태가 없을 때만 초기화
    if (blackjackManager.getSavedState() == null) {
      widget.gameService.getPlayer().wallet = blackjackManager.initialWallet;
      widget.gameService.getPlayer().bet = betOptions[0];
    }
    // 이전 게임이 진행 중이었다면 그 상태 복원
    final savedState = blackjackManager.getSavedState();
    if (savedState != null &&
        savedState['gameState'] == GameState.playerActive) {
      _hasGameStarted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameService.getGameState();
    final bool isPlayerActive = (gameState == GameState.playerActive);
    final int wallet = widget.gameService.getPlayer().wallet;
    final bool hasPlayedAtLeastOneRound =
        widget.gameService.getPlayer().won > 0 ||
            widget.gameService.getPlayer().lose > 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // 단순히 화면만 닫기
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.green[800],
        appBar: AppBar(
          title: const Text('Blackjack'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // 단순히 화면만 닫기
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // 딜러 카드
            SizedBox(
              height: 180,
              width: widget.gameService.getDealer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in widget.gameService.getDealer().hand)
                    CardAnimatedWidget(card, isPlayerActive, 3.0),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 중앙 (히트 + Finish/NewGame + 정산)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 히트
                GestureDetector(
                  onTap: () {
                    if (isPlayerActive) {
                      widget.gameService.drawCard();
                      setState(() {});
                    }
                  },
                  child: SizedBox(
                    width: 150,
                    child: FlatCardFan(
                      children: [
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_1), true),
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_2), true),
                        cardWidget(
                            PlayingCard(Suit.joker, CardValue.joker_2), true),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (isPlayerActive) {
                          _onGameEnd();
                        } else {
                          setState(() {
                            _startNewGame();
                          });
                        }
                      },
                      child: Text(isPlayerActive ? "Finish" : "New Game"),
                    ),
                    const SizedBox(height: 10),
                    if (!isPlayerActive && _hasGameStarted) ...[
                      Text(
                        "승자: ${widget.gameService.getWinner()}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                      Text(
                        "딜러: ${widget.gameService.getScore(widget.gameService.getDealer())}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                      Text(
                        "You: ${widget.gameService.getScore(widget.gameService.getPlayer())}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                    ]
                  ],
                ),

                // 정산 버튼
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: (isPlayerActive ||
                          _isSettling ||
                          !hasPlayedAtLeastOneRound)
                      ? null
                      : _onPressSettlement,
                  child: const Text("정산"),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 승/패, 베팅 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("Won: ${widget.gameService.getPlayer().won}"),
                    Text("Lost: ${widget.gameService.getPlayer().lose}"),
                  ],
                ),
                const SizedBox(width: 30),

                // 베팅 버튼들
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        "Bet Options",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: betOptions.map((option) {
                          final bool isSelected =
                              (option == widget.gameService.getPlayer().bet);
                          final bool canAfford = wallet >= option;
                          final bool isPlayingCurrentRound =
                              isPlayerActive; // 한 판이 진행중인지 여부

                          return Tooltip(
                            message: !canAfford
                                ? '잔액 부족'
                                : isPlayingCurrentRound
                                    ? '게임 진행 중에는 베팅을 변경할 수 없습니다'
                                    : '베팅 가능',
                            child: ElevatedButton(
                              onPressed: (!canAfford ||
                                      isPlayingCurrentRound) // 현재 판이 진행중이면 베팅 변경 불가
                                  ? null
                                  : () {
                                      setState(() {
                                        widget.gameService.getPlayer().bet =
                                            option;
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? Colors.orange
                                    : canAfford
                                        ? Colors.blueGrey
                                        : Colors.red.shade200,
                                disabledBackgroundColor: isSelected
                                    ? Colors.orange.shade200
                                    : canAfford
                                        ? Colors.grey.shade400
                                        : Colors.red.shade100,
                              ),
                              child: Text(
                                '$option',
                                style: TextStyle(
                                  color: canAfford
                                      ? Colors.white
                                      : Colors.grey[800],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 플레이어 카드
            SizedBox(
              height: 180,
              width: widget.gameService.getPlayer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in widget.gameService.getPlayer().hand)
                    CardAnimatedWidget(card, false, 3.0),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 지갑
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wallet),
                const SizedBox(width: 7.5),
                Text(
                  "$wallet",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _startNewGame() {
    widget.gameService.startNewGame();
    _hasGameStarted = true;
    // 새 게임 시작할 때의 상태를 저장
    blackjackManager.saveGameState(
        player: widget.gameService.getPlayer(),
        dealer: widget.gameService.getDealer(),
        gameState: widget.gameService.getGameState());
  }

  void _onGameEnd() {
    widget.gameService.endTurn();
    setState(() {});
  }

  void _onPressSettlement() {
    if (_isSettling || !_hasGameStarted) return;
    setState(() {
      _isSettling = true;
    });
    final currentWallet = widget.gameService.getPlayer().wallet;

    // 게임 상태 초기화
    widget.gameService.resetGameState();
    // blackjackManager의 저장된 상태도 초기화
    blackjackManager.clearSavedState();

    if (mounted) {
      // 정산 완료 표시와 함께 wallet 전달
      Navigator.pop(context, currentWallet);
    }
  }

  @override
  void dispose() {
    // 세션 종료 로직 제거
    super.dispose();
  }
}
