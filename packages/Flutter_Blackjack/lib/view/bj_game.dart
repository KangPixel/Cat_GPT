//bj_game.dart

import 'package:flutter/material.dart';
import 'package:flutter_blackjack_pkg/services/game_service.dart';
import 'package:flutter_blackjack_pkg/services/game_service_impl.dart';
import 'package:flutter_blackjack_pkg/widgets/card.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:flutter_blackjack_pkg/services/blackjack_manager.dart';

class BlackJackGame extends StatefulWidget {
  const BlackJackGame({Key? key}) : super(key: key);

  @override
  State<BlackJackGame> createState() => _BlackJackGameState();
}

class _BlackJackGameState extends State<BlackJackGame> {
  final GameService _gameService = GameServiceImpl();
  final List<int> betOptions = [500, 1000, 2000, 5000, 10000];
  bool _isSettling = false;
  bool _hasGameStarted = false;
  @override
  void initState() {
    super.initState();
    // initialWallet getter를 통해 접근
    _gameService.getPlayer().wallet = blackjackManager.initialWallet;
    print('BlackJackGame initState - 초기 금액: ${blackjackManager.initialWallet}');
  }

  @override
  Widget build(BuildContext context) {
    final gameState = _gameService.getGameState();
    final bool isPlayerActive = (gameState == GameState.playerActive);
    final int wallet = _gameService.getPlayer().wallet;
    final bool hasPlayedAtLeastOneRound =
        _gameService.getPlayer().won > 0 || _gameService.getPlayer().lose > 0;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.green[800],
        appBar: AppBar(
          title: const Text('Blackjack'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // 그냥 뒤로 나가기만 수행
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // 딜러 카드
            SizedBox(
              height: 180,
              width: _gameService.getDealer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in _gameService.getDealer().hand)
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
                      _gameService.drawCard();
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
                          _gameService.endTurn();
                        } else {
                          _startNewGame();
                        }
                        setState(() {});
                      },
                      child: Text(isPlayerActive ? "Finish" : "New Game"),
                    ),
                    const SizedBox(height: 10),
                    if (!isPlayerActive && _hasGameStarted) ...[
                      Text(
                        "승자: ${_gameService.getWinner()}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                      Text(
                        "딜러: ${_gameService.getScore(_gameService.getDealer())}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'cursive',
                        ),
                      ),
                      Text(
                        "You: ${_gameService.getScore(_gameService.getPlayer())}",
                        style: const TextStyle(
                          fontSize: 20,
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
                  onPressed: (!_hasGameStarted ||
                          isPlayerActive ||
                          !hasPlayedAtLeastOneRound ||
                          _isSettling)
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
                    Text("Won: ${_gameService.getPlayer().won}"),
                    Text("Lost: ${_gameService.getPlayer().lose}"),
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
                              (option == _gameService.getPlayer().bet);
                          final bool canAfford = wallet >= option;
                          final bool isDisabled = isPlayerActive || !canAfford;

                          return Tooltip(
                            message: !canAfford
                                ? '잔액 부족'
                                : isPlayerActive
                                    ? '게임 진행 중'
                                    : '베팅 가능',
                            child: ElevatedButton(
                              onPressed: isDisabled ||
                                      (_hasGameStarted && !isPlayerActive)
                                  ? null
                                  : () {
                                      setState(() {
                                        _gameService.getPlayer().bet = option;
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
              width: _gameService.getPlayer().hand.length * 90,
              child: FlatCardFan(
                children: [
                  for (var card in _gameService.getPlayer().hand)
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
    final int currentBet = _gameService.getPlayer().bet;
    _gameService.startNewGame();
    _gameService.getPlayer().bet = currentBet;
    setState(() {
      _hasGameStarted = true;
    });
  }

  void _onPressSettlement() {
    if (_isSettling || !_hasGameStarted) return;

    setState(() {
      _isSettling = true;
    });

    final currentWallet = _gameService.getPlayer().wallet;
    print('정산 시점 - 현재 금액: $currentWallet');

    if (mounted) {
      Navigator.pop(context, currentWallet);
    }
  }

  @override
  void dispose() {
    if (!_isSettling && _hasGameStarted) {
      blackjackManager.endSession();
    }
    super.dispose();
  }
}
